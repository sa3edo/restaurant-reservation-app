// services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createCustomer(Customer customer) async {
    await _db.collection('customers').doc(customer.uid).set(customer.toMap());
  }
}
