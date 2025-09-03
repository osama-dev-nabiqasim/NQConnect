import 'package:get/get.dart';

class UserController extends GetxController {
  var employeeId = ''.obs;
  var userName = ''.obs;
  var role = ''.obs;

  void setUserData(String id, String name, String userRole) {
    employeeId.value = id;
    userName.value = name;
    role.value = userRole;
  }

  void clearUserData() {
    employeeId.value = '';
    userName.value = '';
    role.value = '';
  }
}
