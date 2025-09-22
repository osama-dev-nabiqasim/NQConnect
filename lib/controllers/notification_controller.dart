import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nqconnect/controllers/user_controller.dart';
import 'package:nqconnect/services/socket_service.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationController extends GetxController {
  final notifications = <AppNotification>[].obs;
  final isLoading = false.obs;
  final ApiService _api = ApiService();
  Timer? _timer; // 👈 add
  final SocketService _socket = SocketService();
  // -------------------- For Emulator---------------------------------------
  final String baseUrl = 'http://10.0.2.2:5000/api';

  // ------------------ For physical device  -------------------------------------
  // final String baseUrl = 'http://10.10.5.126:5000/api';

  @override
  void onInit() {
    super.onInit();
    // First fetch on start
    final userId = Get.find<UserController>().employeeId.value;
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
      _timer = Timer.periodic(const Duration(seconds: 30), (_) {
        fetchNotifications(userId);
      });
    }
  }

  @override
  void onClose() {
    _socket.dispose();
    _timer?.cancel(); // 👈 stop timer when controller disposed
    super.onClose();
  }

  Future<void> fetchNotifications(String userId) async {
    try {
      isLoading.value = true;
      final data = await _api.getNotifications(userId);
      notifications.value = data
          .map<AppNotification>((e) => AppNotification.fromJson(e))
          .toList();
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
    final response = await http.post(
      Uri.parse("$baseUrl/mark-all-read"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"user_id": userId}),
    );
    if (response.statusCode == 200) {
      // Update local notifications
      for (var n in notifications) {
        n.isRead = true;
      }
      notifications.refresh();
    }
  }

  // BULK DELETE
  Future<void> bulkDelete(List<int> ids) async {
    final response = await http.post(
      Uri.parse("$baseUrl/bulk-delete"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"ids": ids}),
    );
    if (response.statusCode == 200) {
      notifications.removeWhere((n) => ids.contains(n.id));
    }
  }

  // MARK SINGLE AS READ
  Future<void> markAsRead(int id) async {
    // optional, call your existing endpoint for single notification
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index].isRead = true;
      notifications.refresh();
    }
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}
