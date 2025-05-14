class LoginResponse {
  final int? userId;
  final String? username;
  final int? roleId;
  final String? userType;
  final String? roleDescription;
  final bool? isPassReset;
  final String? result;
  final String? remark;

  LoginResponse({
    this.userId,
    this.username,
    this.roleId,
    this.userType,
    this.roleDescription,
    this.isPassReset,
    this.result,
    this.remark,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      userId: json['userId'] as int?,
      username: json['username'] as String?,
      roleId: json['roleId'] as int?,
      userType: json['userType'] as String? ?? "",
      roleDescription: json['roleDescription'] as String? ?? "",
      isPassReset: json['isPassReset'] as bool?,
      result: json['result'] as String?,
      remark: json['remark'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'Username': username,
      'RoleId': roleId,
      'UserType': userType,
      'RoleDescription': roleDescription,
      'IsPassReset': isPassReset,
      'Result': result,
      'Remark': remark,
    };
  }
}