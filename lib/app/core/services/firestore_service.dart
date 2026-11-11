import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class FirestoreService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseFirestore get instance => _firestore;

  /// الحصول على مرجع لمجموعة (CollectionReference)
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  /// الحصول على مرجع لمستند (DocumentReference)
  DocumentReference<Map<String, dynamic>> doc(String path) {
    return _firestore.doc(path);
  }

  /// مرجع مجموعة المستخدمين
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firestore.collection('users');

  /// حفظ أو تحديث بيانات المستخدم
  Future<void> saveUserProfile({
    required String uid,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    try {
      final payload = {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (!merge) {
        payload['createdAt'] = FieldValue.serverTimestamp();
      }
      await usersCollection.doc(uid).set(payload, SetOptions(merge: merge));
    } catch (e) {
      debugPrint('Firestore saveUserProfile error: $e');
      rethrow;
    }
  }

  /// جلب بيانات مستخدم
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) async {
    try {
      return await usersCollection.doc(uid).get();
    } catch (e) {
      debugPrint('Firestore getUserProfile error: $e');
      rethrow;
    }
  }

  /// استماع لبيانات المستخدم بالوقت الفعلي
  Stream<DocumentSnapshot<Map<String, dynamic>>> userProfileStream(String uid) {
    return usersCollection.doc(uid).snapshots();
  }

  /// إضافة مستند جديد إلى مجموعة مع توليد معرف تلقائي
  Future<DocumentReference<Map<String, dynamic>>> addDocument({
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    try {
      final payload = {
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      return await _firestore.collection(collectionPath).add(payload);
    } catch (e) {
      debugPrint('Firestore addDocument error: $e');
      rethrow;
    }
  }

  /// تحديث مستند محدد
  Future<void> updateDocument({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final payload = {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await _firestore.collection(collectionPath).doc(docId).update(payload);
    } catch (e) {
      debugPrint('Firestore updateDocument error: $e');
      rethrow;
    }
  }

  /// حذف مستند
  Future<void> deleteDocument({
    required String collectionPath,
    required String docId,
  }) async {
    try {
      await _firestore.collection(collectionPath).doc(docId).delete();
    } catch (e) {
      debugPrint('Firestore deleteDocument error: $e');
      rethrow;
    }
  }
}
