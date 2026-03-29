import 'dart:io' show Platform;

bool get isMobileNativeApp => Platform.isIOS || Platform.isAndroid;

bool get isIOSApp => Platform.isIOS;

bool get isAndroidApp => Platform.isAndroid;
