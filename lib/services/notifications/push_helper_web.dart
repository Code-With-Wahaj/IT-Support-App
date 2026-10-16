// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> requestPushPermissionImpl() async {
  try {
    if (html.Notification.supported && html.Notification.permission != 'granted') {
      await html.Notification.requestPermission();
    }
  } catch (_) {}
}

Future<void> showPlatformNotificationImpl(String title, String body) async {
  try {
    if (html.Notification.supported) {
      if (html.Notification.permission == 'granted') {
        html.Notification(title, body: body, icon: 'icons/Icon-192.png');
      } else if (html.Notification.permission != 'denied') {
        final perm = await html.Notification.requestPermission();
        if (perm == 'granted') {
          html.Notification(title, body: body, icon: 'icons/Icon-192.png');
        }
      }
    }
  } catch (_) {}
}
