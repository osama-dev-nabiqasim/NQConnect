// ignore_for_file: sort_child_properties_last, await_only_futures
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nqconnect/controllers/suggestion_management_controller.dart';
import 'package:nqconnect/models/suggestion_model.dart';
import 'package:nqconnect/utils/responsive.dart';

class SuggestionManagementScreen extends StatelessWidget {
  final SuggestionManagementController controller = Get.put(
    SuggestionManagementController(),
  );

  SuggestionManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Suggestion Management",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.appbarColor[0],
        centerTitle: true,
        actions: [
          Obx(() {
            if (controller.isSelecting.value) {
              return IconButton(
                icon: const Icon(Icons.cancel, color: Colors.white),
                onPressed: () {
                  controller.clearSelection();
                  controller.isSelecting.value = false;
                },
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.checklist, color: Colors.white),
                onPressed: () => controller.isSelecting.value = true,
              );
            }
          }),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(context),
          Obx(() {
            if (controller.isSelecting.value) {
              return _buildBulkActionBar();
            } else {
              return const SizedBox.shrink();
            }
          }),
          Expanded(child: _buildSuggestionsList()),
        ],
      ),
      floatingActionButton: Obx(() {
        if (controller.isSelecting.value) {
          return FloatingActionButton(
            onPressed: () => controller.selectAll(),
            child: const Icon(Icons.select_all),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                _buildFilterChip('Active', 'active'),
                const SizedBox(width: 8),
                _buildFilterChip('Archived', 'archived'),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search suggestions...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => controller.searchQuery.value = value,
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildDepartmentFilter(),
                  const SizedBox(width: 8),
                  _buildCategoryFilter(),
                  const SizedBox(width: 8),
                  _buildStatusFilter(),
                  const SizedBox(width: 8),
                  _buildDateFilter(),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.filter_alt_off),
                    onPressed: () => controller.resetFilters(),
                    tooltip: 'Reset Filters',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Obx(
      () => ChoiceChip(
        label: Text(label),
        selected: controller.currentView.value == value,
        onSelected: (_) => controller.currentView.value = value,
      ),
    );
  }

  Widget _buildDepartmentFilter() {
    return Obx(
      () => DropdownButton<String>(
        value: controller.selectedDepartment.value,
        items: controller.availableDepartments.map((dept) {
          return DropdownMenuItem(
            value: dept,
            child: Text(dept == 'all' ? 'All Departments' : dept),
          );
        }).toList(),
        onChanged: (value) => controller.selectedDepartment.value = value!,
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Obx(
      () => DropdownButton<String>(
        value: controller.selectedCategory.value,
        items: controller.availableCategories.map((cat) {
          return DropdownMenuItem(
            value: cat,
            child: Text(cat == 'all' ? 'All Categories' : cat),
          );
        }).toList(),
        onChanged: (value) => controller.selectedCategory.value = value!,
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Obx(
      () => DropdownButton<String>(
        value: controller.selectedStatus.value,
        items: controller.availableStatuses.map((status) {
          return DropdownMenuItem(
            value: status,
            child: Text(status == 'all' ? 'All Status' : status),
          );
        }).toList(),
        onChanged: (value) => controller.selectedStatus.value = value!,
      ),
    );
  }

  Widget _buildDateFilter() {
    return OutlinedButton(
      onPressed: () async {
        final DateTimeRange? picked = await showDateRangePicker(
          context: Get.context!,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          controller.selectedDateRange.value = [picked.start, picked.end];
        }
      },
      child: const Text('Date Range'),
    );
  }

  Widget _buildBulkActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => Text(
              '${controller.selectedSuggestions.length} selected',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            children: [
              // IconButton(
              //   icon: const Icon(Icons.check, color: Colors.green),
              //   onPressed: () => _showBulkActionDialog('Approved'),
              // ),
              // IconButton(
              //   icon: const Icon(Icons.close, color: Colors.red),
              //   onPressed: () => _showBulkActionDialog('Rejected'),
              // ),
              // IconButton(
              //   icon: const Icon(Icons.archive, color: Colors.orange),
              //   onPressed: () => controller.bulkArchive(true),
              // ),
              IconButton(
                icon: Icon(
                  controller.currentView.value == 'archived'
                      ? Icons.unarchive
                      : Icons.archive,
                  color: Colors.orange,
                ),
                onPressed: () {
                  final isArchivedTab =
                      controller.currentView.value == 'archived';
                  controller.bulkArchive(!isArchivedTab);
                  //  → if user is on Archived tab, pass false (unarchive)
                  //    else pass true (archive)
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () {
                  Get.defaultDialog(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 28,
                    ),
                    backgroundColor: Colors.blue.shade100,
                    title: 'Delete',
                    middleText: 'Delete selected suggestions?',
                    textCancel: 'Cancel',
                    textConfirm: 'Delete',
                    confirmTextColor: Colors.white,
                    onConfirm: () async {
                      final ids = controller.selectedSuggestions.toList();
                      await controller.suggestionController
                          .bulkDeleteSuggestions(ids);
                      controller.clearSelection();
                      Get.back();
                      Get.snackbar(
                        'Deleted',
                        '${ids.length} suggestions deleted',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // void _showBulkActionDialog(String action) {
  //   final commentsController = TextEditingController();
  //   Get.dialog(
  //     AlertDialog(
  //       title: Text('$action Selected Suggestions'),
  //       content: TextField(
  //         controller: commentsController,
  //         decoration: const InputDecoration(
  //           hintText: 'Add comments (optional)',
  //           border: OutlineInputBorder(),
  //         ),
  //         maxLines: 3,
  //       ),
  //       actions: [
  //         TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
  //         TextButton(
  //           onPressed: () {
  //             controller.bulkUpdateStatus(action, commentsController.text);
  //             Get.back();
  //             Get.snackbar('$action complete', 'Selected suggestions updated');
  //           },
  //           child: Text(action),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSuggestionsList() {
    return Obx(() {
      final suggestions = controller.filteredSuggestions
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (controller.suggestionController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (suggestions.isEmpty) {
        return const Center(child: Text('No suggestions found'));
      }

      return ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return _buildSuggestionCard(suggestion);
        },
      );
    });
  }

  Widget _buildSuggestionCard(Suggestion suggestion) {
    return Obx(() {
      final isUpdating =
          controller.suggestionController.isLoading.value &&
          controller.suggestionController.suggestions.any(
            (s) => s.id.toString() == suggestion.id.toString(),
          );
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          leading: controller.isSelecting.value
              ? Checkbox(
                  value: controller.selectedSuggestions.contains(
                    suggestion.id.toString(),
                  ),
                  onChanged: (_) =>
                      controller.toggleSelection(suggestion.id.toString()),
                )
              : _buildStatusIcon(suggestion.status),
          title: Text(
            suggestion.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                suggestion.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'By: ${suggestion.employeeName} • ${suggestion.department}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                'Category: ${suggestion.category} • ${suggestion.likes} 👍',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                'Created: ${suggestion.createdAt.toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: isUpdating
              ? const CircularProgressIndicator(strokeWidth: 2)
              : !controller.isSelecting.value
              ? PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Text('View Details'),
                    ),
                    PopupMenuItem(
                      value: 'approve',
                      child: Text(
                        suggestion.status == 'Approved'
                            ? 'Already Approved'
                            : 'Approve',
                      ),
                      enabled: suggestion.status != 'Approved',
                    ),
                    PopupMenuItem(
                      value: 'reject',
                      child: Text(
                        suggestion.status == 'Rejected'
                            ? 'Already Rejected'
                            : 'Reject',
                      ),
                      enabled: suggestion.status != 'Rejected',
                    ),
                    PopupMenuItem(
                      value: 'archive',
                      child: Text(
                        suggestion.isArchived ? 'Unarchive' : 'Archive',
                      ),
                    ),
                  ],
                  onSelected: (value) => _handlePopupAction(value, suggestion),
                )
              : null,
          onTap: () {
            if (controller.isSelecting.value) {
              controller.toggleSelection(suggestion.id.toString());
            } else {
              _showSuggestionDetails(suggestion);
            }
          },
          onLongPress: () => controller.isSelecting.value = true,
        ),
      );
    });
  }

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'Approved':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'Rejected':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.access_time, color: Colors.orange);
    }
  }

  void _handlePopupAction(String action, Suggestion suggestion) {
    switch (action) {
      case 'view':
        _showSuggestionDetails(suggestion);
        break;
      case 'approve':
        controller.suggestionController
            .updateSuggestionStatus(
              suggestion.id.toString(),
              'Approved',
              controller.userController.userName.value,
              'Approved via management console',
            )
            .then((_) {
              Get.snackbar(
                'Approved',
                '${suggestion.title} approved successfully',
                backgroundColor: Colors.green,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            });
        break;
      case 'reject':
        controller.suggestionController
            .updateSuggestionStatus(
              suggestion.id.toString(),
              'Rejected',
              controller.userController.userName.value,
              'Rejected via management console',
            )
            .then((_) {
              Get.snackbar(
                'Rejected',
                '${suggestion.title} rejected successfully',
                backgroundColor: Colors.red,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            });
        break;
      case 'archive':
        controller.suggestionController.archiveSuggestion(
          suggestion.id.toString(),
          !suggestion.isArchived,
        );
        break;
    }
  }

  void _showSuggestionDetails(Suggestion suggestion) {
    Get.dialog(
      AlertDialog(
        title: Text(suggestion.title),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(suggestion.description),
                const SizedBox(height: 16),
                Text('Employee: ${suggestion.employeeName}'),
                Text('Department: ${suggestion.department}'),
                Text('Category: ${suggestion.category}'),
                Text('Status: ${suggestion.status}'),
                Text(
                  'Likes: ${suggestion.likes} • Dislikes: ${suggestion.dislikes}',
                ),
                const SizedBox(height: 16),
                if (suggestion.reviewedBy != null) ...[
                  Text('Reviewed by: ${suggestion.reviewedBy}'),
                  Text(
                    'Reviewed at: ${suggestion.reviewedAt?.toString().split(' ')[0]}',
                  ),
                  if (suggestion.reviewComments != null)
                    Text('Comments: ${suggestion.reviewComments}'),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Status History:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (suggestion.statusHistory.isNotEmpty)
                  ...suggestion.statusHistory.map(
                    (history) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(history.status),
                      subtitle: Text(
                        'By ${history.changedBy} on ${history.changedAt.toString().split(' ')[0]}',
                      ),
                      trailing: history.comments != null
                          ? Text(history.comments!)
                          : null,
                    ),
                  )
                else
                  const Text('No status history available'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }
}
