# Keep Flutter plugin classes (R8 was stripping shared_preferences' Pigeon API methods)
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class dev.flutter.pigeon.** { *; }
-keepclassmembers class * { @androidx.annotation.Keep *; }
-dontwarn io.flutter.embedding.**
