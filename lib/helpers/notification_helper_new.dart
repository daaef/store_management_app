import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationHelper {
  NotificationHelper._();

  static const String _appId = 'your-onesignal-app-id'; // Replace with actual OneSignal App ID

  static Future<void> initialize() async {
    try {
      // Initialize OneSignal
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.initialize(_appId);

      // Request notification permissions
      await OneSignal.Notifications.requestPermission(true);

      // Set up notification handlers
      OneSignal.Notifications.addForegroundWillDisplayListener(_onForegroundWillDisplay);
      OneSignal.Notifications.addClickListener(_onNotificationClicked);

      if (kDebugMode) {
        print('OneSignal initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize OneSignal: $e');
      }
    }
  }

  static void _onForegroundWillDisplay(OSNotificationWillDisplayEvent event) {
    // Display notification when app is in foreground
    // The notification will be displayed by default, no need to call complete
    
    if (kDebugMode) {
      print('Foreground notification received: ${event.notification.title}');
    }
  }

  static void _onNotificationClicked(OSNotificationClickEvent event) {
    // Handle notification click
    final notification = event.notification;
    
    if (kDebugMode) {
      print('Notification clicked: ${notification.title}');
    }

    // Handle navigation based on notification data
    _handleNotificationNavigation(notification.additionalData);
  }

  static void _handleNotificationNavigation(Map<String, dynamic>? data) {
    if (data == null) return;

    // Handle different notification types
    final String? type = data['type'] as String?;
    final String? orderId = data['order_id'] as String?;

    switch (type) {
      case 'new_order':
        // Navigate to order details or refresh orders list
        if (kDebugMode) {
          print('New order notification: $orderId');
        }
        break;
      case 'order_update':
        // Handle order status update
        if (kDebugMode) {
          print('Order update notification: $orderId');
        }
        break;
      default:
        if (kDebugMode) {
          print('Unknown notification type: $type');
        }
    }
  }

  static Future<void> setExternalUserId(String? userId) async {
    if (userId == null || userId.isEmpty) return;
    
    try {
      await OneSignal.login(userId);
      if (kDebugMode) {
        print('OneSignal external user ID set: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to set OneSignal external user ID: $e');
      }
    }
  }

  static Future<void> removeExternalUserId() async {
    try {
      await OneSignal.logout();
      if (kDebugMode) {
        print('OneSignal external user ID removed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to remove OneSignal external user ID: $e');
      }
    }
  }

  static Future<void> sendTag(String key, String value) async {
    try {
      await OneSignal.User.addTags({key: value});
      if (kDebugMode) {
        print('OneSignal tag sent: $key = $value');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to send OneSignal tag: $e');
      }
    }
  }

  static Future<void> removeTag(String key) async {
    try {
      await OneSignal.User.removeTags([key]);
      if (kDebugMode) {
        print('OneSignal tag removed: $key');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to remove OneSignal tag: $e');
      }
    }
  }

  static Future<String?> getPlayerId() async {
    try {
      final user = OneSignal.User;
      return user.pushSubscription.id;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get OneSignal player ID: $e');
      }
      return null;
    }
  }

  static Future<bool> hasPermission() async {
    try {
      return await OneSignal.Notifications.permission;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to check OneSignal permission: $e');
      }
      return false;
    }
  }
}
