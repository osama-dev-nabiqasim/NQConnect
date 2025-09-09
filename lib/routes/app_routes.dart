// lib/routes/app_routes.dart
import 'package:get/get.dart';
import 'package:nqconnect/controllers/user_controller.dart';
import 'package:nqconnect/screens/admin_screens/AnalyticsScreen.dart';
import 'package:nqconnect/screens/auth_screens/reset_password_screens/EnterOtpScreen.dart';
import 'package:nqconnect/screens/auth_screens/reset_password_screens/ResetPasswordScreen.dart';
import 'package:nqconnect/screens/auth_screens/reset_password_screens/forgot_password.dart';
import 'package:nqconnect/screens/dashboard/dashboard_screen.dart';
import 'package:nqconnect/screens/auth_screens/login_screen.dart';
import 'package:nqconnect/screens/employee_screens/suggestion_screens/MySuggestionsScreen.dart';
import 'package:nqconnect/screens/employee_screens/suggestion_screens/VoteOnSuggestion_Screen.dart';
import 'package:nqconnect/screens/manager_screens/ApproveRejectScreen.dart';
import 'package:nqconnect/screens/manager_screens/SuggestionInsights_Screen.dart';
import 'package:nqconnect/screens/placeholder_screen.dart';
import 'package:nqconnect/screens/employee_screens/suggestion_screens/EmployeeSuggestionFormScreen.dart';

class AppRoutes {
  static final List<GetPage> routes = [
    GetPage(name: '/login', page: () => LoginScreen()),
    GetPage(name: '/forgotpassword', page: () => ForgotPasswordScreen()),
    GetPage(name: '/enterotpscreen', page: () => EnterOtpScreen()),
    GetPage(name: '/suggestions', page: () => EmployeeSuggestionFormScreen()),
    GetPage(name: '/resetpasswordscreen', page: () => ResetPasswordScreen()),

    // GetPage(name: "/suggestion_list", page: () => SuggestionListScreen()),
    GetPage(name: '/dashboard', page: () => DashboardScreen()),

    // --------------------Employee Routes------------------------------------------
    GetPage(
      name: '/employee_overview',
      page: () => PlaceholderScreen(title: "Employee Overview"),
    ),
    GetPage(
      name: '/tasks',
      page: () => PlaceholderScreen(title: "My Tasks"),
    ),
    GetPage(
      name: '/suggestions',
      page: () => PlaceholderScreen(title: "Suggestion Box"),
    ),
    GetPage(name: '/votes', page: () => VoteOnSuggestionScreen()),
    GetPage(name: '/my_suggestions', page: () => MySuggestionsScreen()),

    // -------------------Manager Routes---------------------------------------------
    GetPage(
      name: '/team_overview',
      page: () => PlaceholderScreen(title: "Team Performance Overview"),
    ),
    GetPage(
      name: '/task_assignment',
      page: () => PlaceholderScreen(title: "Task Assignment"),
    ),
    GetPage(
      name: '/suggestion_insights',
      page: () => SuggestionInsightsScreen(),
    ),
    GetPage(
      name: '/approvals',
      page: () {
        final userController = Get.find<UserController>();
        return ApproveRejectScreen(
          managerDepartment: userController.department.value,
        );
      },
    ),
    GetPage(
      name: '/activity_feed',
      page: () => PlaceholderScreen(title: "Employee Activity Feed"),
    ),
    GetPage(
      name: '/notifications',
      page: () => PlaceholderScreen(title: "Notifications"),
    ),

    // ----------------------------Admin Routes----------------------------
    GetPage(name: '/suggestion_overview', page: () => AnalyticsDashboard()),
    GetPage(
      name: '/task_overview',
      page: () => PlaceholderScreen(title: "Task Overview"),
    ),
    GetPage(
      name: '/suggestion_management',
      page: () => PlaceholderScreen(title: "Suggestion Management"),
    ),
    GetPage(
      name: '/innovation_analytics',
      page: () => PlaceholderScreen(title: "Innovation Analytics"),
    ),
    GetPage(
      name: '/configurations',
      page: () => PlaceholderScreen(title: "Sections & Configurations"),
    ),
  ];
}
