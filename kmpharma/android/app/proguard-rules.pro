# Flutter Local Notifications - Preserve Gson TypeToken
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep public class * implements java.lang.reflect.Type

# Keep generic signatures for Gson
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod

# Keep data classes used by flutter_local_notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
