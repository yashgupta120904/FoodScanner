# Basic Flutter & R8 ke liye
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Avoiding common AndroidX issues
-keep class androidx.** { *; }
-dontwarn androidx.**

# Keep all public classes/methods (test ke liye)
-keep class * {
    public *;
}
# OkHttp
-keep class com.squareup.okhttp.** { *; }
-dontwarn com.squareup.okhttp.**

# gRPC
-keep class io.grpc.** { *; }
-dontwarn io.grpc.**

# AnnotatedType
-keep class java.lang.reflect.AnnotatedType { *; }

# SplitCompat shit
-keep class com.google.android.play.core.splitcompat.SplitCompatApplication { *; }
-dontwarn com.google.android.play.core.**