package com.dzd.guessy

import android.Manifest
import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Voice questions:
 *  1) in-app SpeechRecognizer (no popup, live text) when the phone has a recognition service,
 *  2) otherwise the system voice-input dialog (RecognizerIntent),
 *  3) otherwise a clear error code back to Dart.
 */
class MainActivity : FlutterActivity() {
    private var pending: MethodChannel.Result? = null
    private var channel: MethodChannel? = null
    private var recognizer: SpeechRecognizer? = null
    private var lang = "ar-DZ"
    private var prompt = ""
    private var triedFallbackLang = false
    private val reqSpeech = 4321
    private val reqMic = 4322

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val ch = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "guessy/speech")
        channel = ch
        ch.setMethodCallHandler { call, result ->
            when (call.method) {
                "listen" -> {
                    finish(null) // a previous call still waiting -> close it
                    lang = call.argument<String>("lang") ?: "ar-DZ"
                    prompt = call.argument<String>("prompt") ?: ""
                    triedFallbackLang = false
                    pending = result
                    if (Build.VERSION.SDK_INT >= 23 &&
                        checkSelfPermission(Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
                        requestPermissions(arrayOf(Manifest.permission.RECORD_AUDIO), reqMic)
                    } else {
                        start()
                    }
                }
                "stop" -> {
                    try { recognizer?.stopListening() } catch (_: Exception) {}
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != reqMic) return
        if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) start()
        else fail("mic_denied")
    }

    private fun start() {
        if (SpeechRecognizer.isRecognitionAvailable(this)) {
            try {
                startInApp()
                return
            } catch (_: Exception) {
                destroyRecognizer()
            }
        }
        startDialog()
    }

    private fun intent(l: String) = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
        putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
        putExtra(RecognizerIntent.EXTRA_LANGUAGE, l)
        putExtra(RecognizerIntent.EXTRA_LANGUAGE_PREFERENCE, l)
        putExtra("android.speech.extra.EXTRA_ADDITIONAL_LANGUAGES", arrayOf(l.substringBefore('-')))
        putExtra(RecognizerIntent.EXTRA_PROMPT, prompt)
        putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 5)
        putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
        putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, packageName)
    }

    private fun startInApp() {
        destroyRecognizer()
        val r = SpeechRecognizer.createSpeechRecognizer(this)
        recognizer = r
        r.setRecognitionListener(object : RecognitionListener {
            override fun onReadyForSpeech(params: Bundle?) { channel?.invokeMethod("state", "ready") }
            override fun onBeginningOfSpeech() { channel?.invokeMethod("state", "speaking") }
            override fun onRmsChanged(rmsdB: Float) {}
            override fun onBufferReceived(buffer: ByteArray?) {}
            override fun onEndOfSpeech() { channel?.invokeMethod("state", "thinking") }
            override fun onEvent(eventType: Int, params: Bundle?) {}
            override fun onPartialResults(partialResults: Bundle?) {
                val t = partialResults?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)?.firstOrNull()
                if (!t.isNullOrBlank()) channel?.invokeMethod("partial", t)
            }
            override fun onResults(results: Bundle?) {
                // all alternatives, best first, one per line: the app picks the one it understands
                val t = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)?.filter { it.isNotBlank() }?.joinToString("\n")
                destroyRecognizer()
                finish(t)
            }
            override fun onError(error: Int) {
                destroyRecognizer()
                when (error) {
                    // 12/13 = language not supported / not downloaded (API 31+) -> retry in generic Arabic etc.
                    12, 13 -> if (!triedFallbackLang) {
                        triedFallbackLang = true
                        lang = fallback(lang)
                        try { startInApp() } catch (_: Exception) { startDialog() }
                    } else startDialog()
                    SpeechRecognizer.ERROR_NO_MATCH, SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> fail("no_speech")
                    SpeechRecognizer.ERROR_NETWORK, SpeechRecognizer.ERROR_NETWORK_TIMEOUT, 11 -> fail("network")
                    SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> fail("mic_denied")
                    // busy / client / server error -> the system dialog usually still works
                    else -> startDialog()
                }
            }
        })
        r.startListening(intent(lang))
    }

    private fun fallback(l: String) = when (l.substringBefore('-')) {
        "ar" -> "ar-SA"; "fr" -> "fr-FR"; "es" -> "es-ES"; "pt" -> "pt-PT"; else -> "en-US"
    }

    private fun startDialog() {
        try {
            startActivityForResult(intent(lang), reqSpeech)
        } catch (e: ActivityNotFoundException) {
            fail("no_recognizer")
        } catch (e: Exception) {
            fail("speech_error")
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != reqSpeech) return
        if (resultCode == Activity.RESULT_OK) {
            finish(data?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)?.filter { it.isNotBlank() }?.joinToString("\n"))
        } else {
            finish(null)
        }
    }

    private fun finish(text: String?) {
        val r = pending
        pending = null
        try { r?.success(text) } catch (_: Exception) {}
    }

    private fun fail(code: String) {
        val r = pending
        pending = null
        try { r?.error(code, code, null) } catch (_: Exception) {}
    }

    private fun destroyRecognizer() {
        try { recognizer?.destroy() } catch (_: Exception) {}
        recognizer = null
    }

    override fun onDestroy() {
        destroyRecognizer()
        super.onDestroy()
    }
}
