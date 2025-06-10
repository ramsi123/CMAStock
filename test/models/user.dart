class User {
  final String name;
  final String email;
  final String imageId;
  final String imageUrl;
  final String role;
  final bool notification;
  final String stockAlertAmount;
  final String stockAlertUnit;

  User({
    required this.name,
    required this.email,
    required this.imageId,
    required this.imageUrl,
    required this.role,
    required this.notification,
    required this.stockAlertAmount,
    required this.stockAlertUnit,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'imageId': imageId,
      'imageUrl': imageUrl,
      'role': role,
      'notification': notification,
      'stockAlertAmount': stockAlertAmount,
      'stockAlertUnit': stockAlertUnit,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'] as String,
      email: map['email'] as String,
      imageId: map['imageId'] as String,
      imageUrl: map['imageUrl'] as String,
      role: map['role'] as String,
      notification: map['notification'] as bool,
      stockAlertAmount: map['stockAlertAmount'] as String,
      stockAlertUnit: map['stockAlertUnit'] as String,
    );
  }
}
