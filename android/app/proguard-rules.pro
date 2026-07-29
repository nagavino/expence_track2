# Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Ignore warnings for Play Core and deferred components
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
-dontwarn com.google.android.play.core.**

# Keep model classes from being obfuscated/shrunk if needed by Hive or reflection
-keep class com.example.expence_track.features.auth.model.** { *; }
-keep class com.example.expence_track.features.expense.model.** { *; }
