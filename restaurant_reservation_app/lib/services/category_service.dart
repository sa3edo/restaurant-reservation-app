// services/category_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryService {
  final _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getCategories() {
    return _db.collection('categories').snapshots();
  }

  Future<void> addCategory(String name) {
    return _db.collection('categories').add({'name': name});
  }

  Future<void> deleteCategory(String id) {
    return _db.collection('categories').doc(id).delete();
  }
}
