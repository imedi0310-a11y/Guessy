package com.dzd.guessy

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.speech.RecognizerIntent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pending: MethodChannel.Result? = null
    private val reqSpeech = 4321

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "guessy/speech").setMethodCallHandler { call, result ->
            if (call.method == "listen") {
                val lang = call.argument<String>("lang") ?: "ar-DZ"
                val prompt = call.argument<String>("prompt") ?: ""
                val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                    putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                    putExtra(RecognizerIntent.EXTRA_LANGUAGE, lang)
                    putExtra(RecognizerIntent.EXTRA_LANGUAGE_PREFERENCE, lang)
                    putExtra(RecognizerIntent.EXTRA_PROMPT, prompt)
                    putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
                }
                try {
                    pending?.success(null)
                    pending = result
                    startActivityForResult(intent, reqSpeech)
                } catch (e: ActivityNotFoundException) {
                    pending = null
                    result.error("no_recognizer", e.message, null)
                } catch (e: Exception) {
                    pending = null
                    result.error("speech_error", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == reqSpeech) {
            val r = pending
            pending = null
            if (resultCode == Activity.RESULT_OK) {
                val list = data?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)
                r?.success(list?.firstOrNull())
            } else {
                r?.success(null)
            }
        }
    }
}
