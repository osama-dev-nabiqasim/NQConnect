// ignore_for_file: use_key_in_widget_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nqconnect/controllers/notification_controller.dart';
import 'package:nqconnect/controllers/user_controller.dart';
import 'package:nqconnect/utils/responsive.dart';

class NotificationsPage extends StatefulWidget {
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with WidgetsBindingObserver {
  final NotificationController controller = Get.put(NotificationController());
  final userController = Get.find<UserController>();

  final RxBool isSelecting = false.obs;
  final RxSet<int> selectedNotifications = <int>{}.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // controller.fetchNotifications(userController.employeeId.value);
    _loadNotifications();
  }

  void _loadNotifications() {
    controller.fetchNotifications(userController.employeeId.value);
  }

  /// 🔄 When app comes back to foreground, re-fetch notifications
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadNotifications();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Obx(() {
          return AppBar(
            backgroundColor: AppColors.appbarColor[0],
            title: Text('Notifications'),
            actions: [
              // MARK ALL AS READ BUTTON
              if (!isSelecting.value)
                IconButton(
                  icon: Icon(Icons.mark_email_read),
                  tooltip: "Mark all as read",
                  onPressed: () async {
                    await controller.markAllAsRead(
                      userController.employeeId.value,
                    );
                    _showSnack("Notifications marked as read");
                  },
                ),
              // DELETE BUTTON when selecting
              if (isSelecting.value)
                IconButton(
                  icon: Icon(Icons.delete),
                  tooltip: "Delete selected",
                  onPressed: () async {
                    if (selectedNotifications.isEmpty) return;
                    print(
                      "Delete button pressed, selectedIds=$selectedNotifications",
                    );
                    await controller.bulkDelete(selectedNotifications.toList());
                    _showSnack("Selected notifications deleted");
                    selectedNotifications.clear();
                    isSelecting.value = false;
                  },
                ),
            ],
          );
        }),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.notifications.isEmpty) {
          print("No notifications found");
          return Center(child: Text('No new notification'));
        }

        return RefreshIndicator(
          onRefresh: () async => _loadNotifications(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.notifications.length,
            itemBuilder: (context, i) {
              final n = controller.notifications[i];
              final isSelected = selectedNotifications.contains(n.id);

              return GestureDetector(
                onLongPress: () {
                  print("Long press on notification id=${n.id}");
                  isSelecting.value = true;
                  selectedNotifications.add(n.id);
                },
                child: Obx(() {
                  final isSelected = selectedNotifications.contains(n.id);
                  return ListTile(
                    title: Text(
                      n.title,
                      style: TextStyle(
                        // color: AppColors.primaryColor.first,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(n.message),
                    trailing: isSelecting.value
                        ? Checkbox(
                            value: isSelected,
                            onChanged: (v) {
                              print(
                                "Checkbox changed for id=${n.id}, value=$v",
                              );

                              if (v == true) {
                                selectedNotifications.add(n.id);
                              } else {
                                selectedNotifications.remove(n.id);
                              }
                            },
                          )
                        : n.isRead
                        ? null
                        : Icon(Icons.fiber_new, color: Colors.red),
                    onTap: () {
                      if (isSelecting.value) {
                        print("Tapped in selection mode on id=${n.id}");

                        if (isSelected) {
                          selectedNotifications.remove(n.id);
                        } else {
                          selectedNotifications.add(n.id);
                        }
                      } else {
                        print("Tapped to mark as read id=${n.id}");
                        controller.markAsRead(n.id);
                        _showSnack("Notification marked as read");
                      }
                    },
                  );
                }),
              );
            },
          ),
        );
      }),
    );
  }
}
