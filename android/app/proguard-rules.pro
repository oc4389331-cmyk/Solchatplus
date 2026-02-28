# ProGuard rules for Zego SDK
-dontwarn com.itgsa.opensdk.mediaunit.KaraokeMediaHelper

# Ignore warnings for classes that may be missing in Jackson databind
-dontwarn java.beans.Transient
-dontwarn org.w3c.dom.bootstrap.DOMImplementationRegistry
-dontwarn com.fasterxml.jackson.databind.**
