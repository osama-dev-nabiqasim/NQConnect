// ignore_for_file: avoid_print, await_only_futures

import 'package:get/get.dart';
import 'package:nqconnect/controllers/user_controller.dart';
import 'package:nqconnect/services/event_api_service.dart';

class EventAnalyticsController extends GetxController {
  final isLoading = true.obs;

  final totalEvents = 0.obs;
  final upcomingEvents = 0.obs;
  final completedEvents = 0.obs;
  final totalAttendees = 0.obs;

  final averageRsvpRate = 0.0.obs;
  final mostPopularCategory = ''.obs;
  final bestAttendedEventTitle = ''.obs;

  final categoryBreakdown = <String, int>{}.obs;
  final monthlyTrend = <String, int>{}.obs;
  final topAttendedEvents = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    try {
      final token =
          await UserController().token; // jahan aap token save karte ho
      final data = await EventApiService().fetchAnalytics();

      totalEvents.value = data['totalEvents'] ?? 0;
      upcomingEvents.value = data['upcomingEvents'] ?? 0;
      completedEvents.value = data['completedEvents'] ?? 0;
      totalAttendees.value = data['totalAttendees'] ?? 0;

      if (data['topAttendedEvents'] != null) {
        topAttendedEvents.value = List<Map<String, dynamic>>.from(
          data['topAttendedEvents'],
        );
      }

      // category breakdown
      final cat = <String, int>{};
      if (data['categoryBreakdown'] != null) {
        for (var row in data['categoryBreakdown']) {
          cat[row['Category']] = row['count'];
        }
      }
      categoryBreakdown.value = cat;

      // monthly trend
      final mt = <String, int>{};
      for (var row in data['monthlyTrend']) {
        mt[row['month']] = row['count'];
      }
      monthlyTrend.value = mt;

      // extra metrics example
      if (cat.isNotEmpty) {
        mostPopularCategory.value = cat.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
      }

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      // Get.snackbar('Error', e.toString());
      print(e);
    }
  }
}
