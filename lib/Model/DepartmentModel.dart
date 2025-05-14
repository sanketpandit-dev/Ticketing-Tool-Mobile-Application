class Department {
  final int departmentId;
  final String departmentName;

  Department({
    required this.departmentId,
    required this.departmentName,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      departmentId: json['dept_mast_id'] as int,
      departmentName: json['dept_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dept_mast_id': departmentId,
      'dept_name': departmentName,
    };
  }
} 