# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep public class com.google.firebase.messaging.FirebaseMessagingService
-keep public class com.google.firebase.iid.FirebaseInstanceIdService

# Fix R8 missing class errors
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
-dontwarn io.flutter.plugins.sharedpreferences.MessagesAsyncPigeonUtils
-dontwarn io.flutter.plugins.sharedpreferences.StringListLookupResultType

# Fluttertoast keep rules
-keep class io.github.ponnamkarthik.toast.fluttertoast.** { *; }
-dontwarn io.github.ponnamkarthik.toast.fluttertoast.**
