import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class FirestoreService extends GetxService {
  FirebaseFirestore? get _firestore {
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseFirestore.instance;
      }
    } catch (e) {
      debugPrint('FirebaseFirestore.instance error: $e');
    }
    return null;
  }

  FirebaseFirestore? get instance => _firestore;

  /// الحصول على مرجع لمجموعة (CollectionReference)
  CollectionReference<Map<String, dynamic>>? collection(String path) {
    return _firestore?.collection(path);
  }

  /// الحصول على مرجع لمستند (DocumentReference)
  DocumentReference<Map<String, dynamic>>? doc(String path) {
    return _firestore?.doc(path);
  }

  /// مرجع مجموعة المستخدمين
  CollectionReference<Map<String, dynamic>>? get usersCollection =>
      _firestore?.collection('users');

  /// حفظ أو تحديث بيانات المستخدم
  Future<void> saveUserProfile({
    required String uid,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    final users = usersCollection;
    if (users == null) return;
    try {
      final payload = {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (!merge) {
        payload['createdAt'] = FieldValue.serverTimestamp();
      }
      await users.doc(uid).set(payload, SetOptions(merge: merge));
    } catch (e) {
      debugPrint('Firestore saveUserProfile error: $e');
      rethrow;
    }
  }

  /// جلب بيانات مستخدم
  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserProfile(String uid) async {
    final users = usersCollection;
    if (users == null) return null;
    try {
      return await users.doc(uid).get();
    } catch (e) {
      debugPrint('Firestore getUserProfile error: $e');
      rethrow;
    }
  }

  /// استماع لبيانات المستخدم بالوقت الفعلي
  Stream<DocumentSnapshot<Map<String, dynamic>>>? userProfileStream(String uid) {
    return usersCollection?.doc(uid).snapshots();
  }

  /// إضافة مستند جديد إلى مجموعة مع توليد معرف تلقائي
  Future<DocumentReference<Map<String, dynamic>>?> addDocument({
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return null;
    try {
      final payload = {
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      return await firestore.collection(collectionPath).add(payload);
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
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      final payload = {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await firestore.collection(collectionPath).doc(docId).update(payload);
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
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      await firestore.collection(collectionPath).doc(docId).delete();
    } catch (e) {
      debugPrint('Firestore deleteDocument error: $e');
      rethrow;
    }
  }
}
