import 'package:emp_management/admin/dashboard/model/admin_model.dart';
import 'package:emp_management/admin/settings/repo/settings_repo.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class SettingsController extends GetxController {
  final SettingsRepo repo = SettingsRepo();

  String name = "";
  String email = "";
  String? phone;
  double lat = 0;
  double lng = 0;
  int range = 0;

  bool loading = true;
  bool notificationsEnabled = false;

  @override
  void onInit() {
    fetchAdminData();
    super.onInit();
  }

  Future<void> fetchAdminData() async {

    AdminModel? admin = await repo.getAdminData();

    if (admin != null) {
      name = admin.name;
      email = admin.email;
      phone = admin.phoneNumber;
      lat = admin.companyLat;
      lng = admin.companyLng;
      range = admin.rangeInMeter;
    }

    loading = false;
    update();
  }
}
