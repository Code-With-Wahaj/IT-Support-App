import 'push_helper_stub.dart'
    if (dart.library.html) 'push_helper_web.dart';

Future<void> requestPushPermission() => requestPushPermissionImpl();

Future<void> showPlatformNotification(String title, String body) =>
    showPlatformNotificationImpl(title, body);
