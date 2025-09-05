import 'package:get/get.dart';

class UserController extends GetxController {
  var employeeId = ''.obs;
  var userName = ''.obs;
  var role = ''.obs;
  var department = ''.obs;

  void setUserData(String id, String name, String userRole, String dept) {
    employeeId.value = id;
    userName.value = name;
    role.value = userRole;
    department.value = dept;
  }

  void clearUserData() {
    employeeId.value = '';
    userName.value = '';
    role.value = '';
    department.value = '';
  }
}
