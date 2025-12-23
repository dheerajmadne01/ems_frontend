import 'package:emp_management/employee/profile/model/employee_profile_model.dart';
import 'package:emp_management/employee/profile/repo/employee_profile_repo.dart';
import 'package:get/get.dart';

class EmployeeProfileController extends GetxController {
  EmployeeProfileController() : _repo = EmployeeRepository();

  final EmployeeRepository _repo;

  final isLoading = false.obs;
  final profile = Rxn<EmployeeProfileModel>();
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile({bool showLoader = true}) async {
    try {
      if (showLoader) {
        isLoading.value = true;
      }
      error.value = '';
      profile.value = await _repo.getEmployeeProfile();
    } catch (e) {
      error.value = e.toString();
    } finally {
      if (showLoader) {
        isLoading.value = false;
      }
    }
  }
}
