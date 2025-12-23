import 'package:emp_management/admin/attendence/model/attendance_models.dart';
import 'package:emp_management/admin/attendence/repo/attendance_repository.dart';
import 'package:emp_management/services/toast_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


class AttendanceController extends GetxController {
  final AttendanceRepository _repo;

  AttendanceController() : _repo = AttendanceRepository();

  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxList<EmployeeModel> employees = <EmployeeModel>[].obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  String selectedDateLabel = ''; // optional

  @override
  void onInit() {
    super.onInit();
    loadAttendance();
  }

  Future<void> loadAttendance({DateTime? date, bool showLoader = true}) async {
    try {
      if (showLoader) {
        isLoading.value = true;
      } else {
        isRefreshing.value = true;
      }
      final effectiveDate = date ?? selectedDate.value;
      selectedDate.value = effectiveDate;

      final data =
          await _repo.fetchEmployeesWithPunches(date: effectiveDate);
      employees.assignAll(data);
    } catch (e) {
      ToastService.showError(_getErrorMessage(e));
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      final message = error.toString();
      if (message.startsWith('Exception: ')) {
        return message.substring(11);
      }
      return message;
    }
    return error.toString();
  }

  // Helpers ----------------------------------------------------------

  DateTime _todayLocalDateOnly() {
    final d = selectedDate.value;
    return DateTime(d.year, d.month, d.day);
  }

  bool _isSameLocalDate(DateTime d, DateTime other) {
    return d.year == other.year && d.month == other.month && d.day == other.day;
  }

  AttendanceStatus computeTodayStatus(EmployeeModel e) {
    final today = _todayLocalDateOnly();
    final onLeave = e.leaves.any((lv) {
      if (lv.from == null && lv.to == null) return false;
      final from = lv.from ?? today;
      final to = lv.to ?? today;
      return !today.isBefore(DateTime(from.year, from.month, from.day)) &&
             !today.isAfter(DateTime(to.year, to.month, to.day));
    });

    if (onLeave) {
      return AttendanceStatus(
        status: 'On Leave',
        punchIn: null,
        punchOut: null,
        leave: e.leaves.firstWhere((lv) {
          if (lv.from == null && lv.to == null) return false;
          final from = lv.from ?? today;
          final to = lv.to ?? today;
          return !today.isBefore(DateTime(from.year, from.month, from.day)) &&
                 !today.isAfter(DateTime(to.year, to.month, to.day));
        }),
      );
    }

    // Find punches for today
    final todaysPunches = e.punches.where((p) {
      final dt = p.punchInTime ?? p.punchOutTime;
      if (dt == null) return false;
      return _isSameLocalDate(dt, today);
    }).toList();

    // Find punch in (IN) earliest
    PunchModel? punchIn;
    PunchModel? punchOut;

    // Prefer explicit punch_in_time and type IN
    final inPunches = todaysPunches.where((p) => p.type.toUpperCase() == 'IN' && p.punchInTime != null).toList()
      ..sort((a, b) => a.punchInTime!.compareTo(b.punchInTime!));
    if (inPunches.isNotEmpty) punchIn = inPunches.first;

    final outPunches = todaysPunches.where((p) => p.type.toUpperCase() == 'OUT' && p.punchOutTime != null).toList()
      ..sort((a, b) => b.punchOutTime!.compareTo(a.punchOutTime!));
    if (outPunches.isNotEmpty) punchOut = outPunches.first;

    if (punchIn != null) {
      return AttendanceStatus(
        status: 'Present',
        punchIn: punchIn,
        punchOut: punchOut,
        leave: null,
      );
    }

    // No punchIn and no leave => Absent
    return AttendanceStatus(status: 'Absent', punchIn: null, punchOut: null, leave: null);
  }

  String formatTime(DateTime dt) {
    return DateFormat.jm().format(dt); // e.g., 9:15 AM
  }
}

class AttendanceStatus {
  final String status; // Present / Absent / On Leave
  final PunchModel? punchIn;
  final PunchModel? punchOut;
  final LeaveModel? leave;

  AttendanceStatus({
    required this.status,
    this.punchIn,
    this.punchOut,
    this.leave,
  });
}
