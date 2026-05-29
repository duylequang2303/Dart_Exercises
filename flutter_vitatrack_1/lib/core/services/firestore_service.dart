import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> setDocument(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(docId).set(data);
    } catch (e) {
      throw Exception('Lỗi khi lưu dữ liệu vào $collection: $e');
    }
  }

  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật dữ liệu trong $collection: $e');
    }
  }

  Future<Map<String, dynamic>?> getDocument(String collection, String docId) async {
    try {
      final doc = await _firestore.collection(collection).doc(docId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi khi tải dữ liệu từ $collection: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCollection(String collection) async {
    try {
      final querySnapshot = await _firestore.collection(collection).get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách dữ liệu từ $collection: $e');
    }
  }

  Future<void> deleteDocument(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      throw Exception('Lỗi khi xóa dữ liệu khỏi $collection: $e');
    }
  }

  Stream<Map<String, dynamic>?> streamDocument(String collection, String docId) {
    try {
      return _firestore.collection(collection).doc(docId).snapshots().map((doc) {
        return doc.data();
      });
    } catch (e) {
      throw Exception('Lỗi khi thiết lập luồng dữ liệu từ $collection: $e');
    }
  }
}

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
