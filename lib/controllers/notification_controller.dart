// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nqconnect/controllers/user_controller.dart';
import 'package:nqconnect/services/socket_service.dart';
import 'package:nqconnect/utils/api_constants.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationController extends GetxController {
  final notifications = <AppNotification>[].obs;
  final isLoading = false.obs;
  final ApiService _api = ApiService();
  // Timer? _timer; // 👈 add
  final SocketService _socket = SocketService();
  // -------------------- For Emulator---------------------------------------
  // final String baseUrl = 'http://10.0.2.2:5000/api';

  // ------------------ For physical device  -------------------------------------
  // final String baseUrl = 'http://10.10.5.188:5000/api';
  final String baseUrl = ApiConstants.baseUrl;

  // ------------------ For physical device  -------------------------------------
  // final String baseUrl = 'http://10.10.5.126:5000/api';

  @override
  void onInit() {
    super.onInit();
    // First fetch on start
    final userId = Get.find<UserController>().employeeId.value;
    print("NotificationController: onInit, userId=$userId");
    if (userId.isNotEmpty) {
      fetchNotifications(userId);
      _socket.connect(
        'http://10.0.2.2:5000',
        userId,
        onNotification: (data) {
          final n = AppNotification.fromJson(data);
          notifications.insert(0, n);
        },
      );
      // 👇 Start periodic refresh every 30 sec
      // _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      //   fetchNotifications(userId);
      // });
    }
  }

  @override
  void onClose() {
    _socket.dispose();
    // _timer?.cancel(); // 👈 stop timer when controller disposed
    super.onClose();
  }

  Future<void> fetchNotifications(String userId) async {
    try {
      print("Fetching notifications for userId=$userId...");
      isLoading.value = true;
      final data = await _api.getNotifications(userId);
      print("Fetched ${data.length} notifications from API");
      notifications.value = data
          .map<AppNotification>((e) => AppNotification.fromJson(e))
          .toList();
      print("Notifications updated in controller: ${notifications.length}");
    } catch (e) {
      print("Error fetching notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> markAsRead(int id) async {
  //   await _api.markNotificationRead(id.toString());
  //   final index = notifications.indexWhere((n) => n.id == id);
  //   if (index != -1) {
  //     notifications[index] = notifications[index].copyWith(isRead: true);
  //     // notifications.refresh(); // usually not needed when assigning to index, but safe to call if UI didn't update
  //   }
  // }
  // MARK ALL AS READ
  Future<void> markAllAsRead(String userId) async {
    print("markAllAsRead called for userId=$userId");
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/notifications/mark-all-read"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"user_id": userId}),
      );
      print("markAllAsRead API response: ${response.statusCode}");
      if (response.statusCode == 200) {
        notifications.value = notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
        print("All notifications marked as read locally");
      }
    } catch (e) {
      print("Error in markAllAsRead: $e");
    }
  }

  // BULK DELETE
  Future<void> bulkDelete(List<int> ids) async {
    print("bulkDelete called for ids=$ids");
    if (ids.isEmpty) {
      print("No notifications selected to delete");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/notifications/bulk-delete"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"ids": ids}),
      );
      print("bulkDelete API response: ${response.statusCode}");
      if (response.statusCode == 200) {
        notifications.removeWhere((n) => ids.contains(n.id));
        print("Deleted notifications locally: $ids");
      }
    } catch (e) {
      print("Error in bulkDelete: $e");
    }
  }

  // MARK SINGLE AS READ
  void markAsRead(int id) async {
    print("markAsRead called for id=$id");
    // optional, call your existing endpoint for single notification
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      notifications.refresh();
      print("Notification id=$id marked as read locally");
    }

    await _api.markNotificationRead(id.toString());
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}
