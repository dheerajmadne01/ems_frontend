class EmployeeModel {
  final String id;
  final String empId;
  final String name;
  final String email;
  final String role;
  final String salary;
  final String? jobRole;
  final String? department;
  final String? phone;

  EmployeeModel({
    required this.id,
    required this.empId,
    required this.name,
    required this.email,  
    required this.role,
    required this.salary,
    this.jobRole,
    this.department,
    this.phone,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json["id"] as String,
      empId: json["emp_id"] as String,
      name: json["name"] as String,
      email: json["email"] as String,
      role: json["role"] as String,
      salary: json["salary"] as String,
      phone: json["phone_number"] as String?,
      jobRole: json["job_role"] as String?,
      department: json["dept"] as String?,
    );
  }
}
