class ResetPasswordRequest {

  final String username;
  final String newPassword;

  ResetPasswordRequest({

    required this.username,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {

    "Username": username,
    "NewPassword": newPassword,
  };
}
