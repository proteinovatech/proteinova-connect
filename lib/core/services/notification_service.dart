import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proteinova_connect/core/config/api_config.dart';

class NotificationService {
  /// Setup firebase notifications
  static Future<void> setupAdminNotifications() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // Request permission
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      // Subscribe admin topic
      await messaging.subscribeToTopic("admins");

      print("Subscribed to admins topic");

      // Get FCM token
      String? token = await messaging.getToken();

      if (token != null) {
        print("FCM TOKEN: $token");

        // Save token to backend
        await saveFcmTokenToBackend(token);
      }

      // Token refresh listener
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        saveFcmTokenToBackend(newToken);
      });

      // Foreground notification listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          print("Notification: ${message.notification?.title}");

          print("Body: ${message.notification?.body}");
        }
      });
    } catch (e) {
      print("Setup Notification Error: $e");
    }
  }

  /// Send admin approval notification
  static Future<void> sendAdminApprovalNotification({
    required String saleId,
    required String branchName,
    required int totalEggs,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/send-admin-notification'),
        headers: {'Content-Type': 'application/json'},

        body: jsonEncode({
          'saleId': saleId,

          'branchName': branchName,

          'totalEggs': totalEggs,
        }),
      );

      print("STATUS CODE: ${response.statusCode}");

      print("RESPONSE: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Admin notification request sent successfully");
      } else {
        print("Failed notification request");
      }
    } catch (e) {
      print("Send Notification Error: $e");
    }
  }

  /// Save FCM token into backend
  static Future<void> saveFcmTokenToBackend(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getInt('user_id');

      final branchId = prefs.getInt('branch_id');

      if (userId == null) {
        print("User not logged in");

        return;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/update-fcm-token'),

        headers: {'Content-Type': 'application/json'},

        body: jsonEncode({
          'userId': userId,

          'fcmToken': token,

          'branchId': branchId,
        }),
      );

      print("TOKEN SAVE STATUS: ${response.statusCode}");

      print("TOKEN SAVE RESPONSE: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("FCM token saved successfully");
      } else {
        print("Failed saving token");
      }
    } catch (e) {
      print("Save Token Error: $e");
    }
  }
}
