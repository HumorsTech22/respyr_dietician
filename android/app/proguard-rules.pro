# Fix androidx.window R8 issue
-keep class androidx.window.** { *; }
-dontwarn androidx.window.**

-keep class androidx.window.extensions.** { *; }
-dontwarn androidx.window.extensions.**

-keep class androidx.window.sidecar.** { *; }
-dontwarn androidx.window.sidecar.**