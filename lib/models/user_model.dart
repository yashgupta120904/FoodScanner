// ignore_for_file: file_names

class UserModel {
  final String uId;
  final String fullName;
  final String email;
  final String phone;
  final String Password;

  UserModel({
    required this.uId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.Password,
  });

  // Serialize the UserModel instance to a JSON map
  Map<String, dynamic> toMap() {
    return {
      'uId': uId,
      'fullName':fullName,
      'email': email,
      'phone': phone,
      'Password':Password,
    };
  }

  // Create a UserModel instance from a JSON map
  factory UserModel.fromMap(Map<String, dynamic> json) {
    return UserModel(
      uId: json['uId'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      Password: json['Password'],
    );
  }
}