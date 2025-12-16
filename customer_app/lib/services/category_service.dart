import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryService {
  final _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getCategories() {
    return _db.collection('categories').snapshots();
  }
}
