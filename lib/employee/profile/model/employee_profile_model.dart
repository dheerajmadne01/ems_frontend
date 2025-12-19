class EmployeeProfileModel {
  final String id;
  final String empId;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? dept;
  final String? jobRole;
  final String role;
  final double salary;
  final String? profilePhoto;

  EmployeeProfileModel({
    required this.id,
    required this.empId,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.dept,
    this.jobRole,
    required this.role,
    required this.salary,
    this.profilePhoto,
  });

  factory EmployeeProfileModel.fromJson(Map<String, dynamic> json) {
    return EmployeeProfileModel(
      id: json['id'],
      empId: json['emp_id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      dept: json['dept'],
      jobRole: json['job_role'],
      role: json['role'],
      salary: double.tryParse(json['salary'].toString()) ?? 0.0,
      profilePhoto: json['profile_photo'],
    );
  }

}
