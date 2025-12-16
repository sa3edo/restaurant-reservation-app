// customer_model.dart
class Customer {
  final String uid;
  final String email;
  final String name;
  final String phone;

  Customer({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'email': email, 'name': name, 'phone': phone};
  }
}
