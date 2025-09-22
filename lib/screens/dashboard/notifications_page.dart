// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nqconnect/controllers/notification_controller.dart';
import 'package:nqconnect/controllers/user_controller.dart';
import 'package:nqconnect/utils/responsive.dart';

class NotificationsPage extends StatefulWidget {
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationController controller = Get.put(NotificationController());
  final userController = Get.find<UserController>();

  final RxBool isSelecting = false.obs;
  final RxSet<int> selectedNotifications = <int>{}.obs;

  @override
  void initState() {
    super.initState();
    controller.fetchNotifications(userController.employeeId.value);
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
                  onPressed: () =>
                      controller.markAllAsRead(userController.employeeId.value),
                ),
              // DELETE BUTTON when selecting
              if (isSelecting.value)
                IconButton(
                  icon: Icon(Icons.delete),
                  tooltip: "Delete selected",
                  onPressed: () async {
                    if (selectedNotifications.isEmpty) return;
                    await controller.bulkDelete(selectedNotifications.toList());
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
          return Center(child: Text('No notifications'));
        }

        return ListView.builder(
          itemCount: controller.notifications.length,
          itemBuilder: (context, i) {
            final n = controller.notifications[i];
            final isSelected = selectedNotifications.contains(n.id);

            return GestureDetector(
              onLongPress: () {
                isSelecting.value = true;
                selectedNotifications.add(n.id);
              },
              child: Obx(
                () => ListTile(
                  title: Text(n.title),
                  subtitle: Text(n.message),
                  trailing: isSelecting.value
                      ? Checkbox(
                          value: isSelected,
                          onChanged: (v) {
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
                      if (isSelected) {
                        selectedNotifications.remove(n.id);
                      } else {
                        selectedNotifications.add(n.id);
                      }
                    } else {
                      controller.markAsRead(n.id);
                    }
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
