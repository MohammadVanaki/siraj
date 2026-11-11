import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class FirebaseAuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Rx<User?> currentUser = Rx<User?>(null);

  bool get isLoggedIn => currentUser.value != null;
  String? get uid => currentUser.value?.uid;
  String? get email => currentUser.value?.email;
  String? get displayName => currentUser.value?.displayName;

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _auth.currentUser;
    currentUser.bindStream(_auth.authStateChanges());
  }

  /// تسجيل حساب جديد بالبريد الإلكتروني وكلمة المرور
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (displayName != null && displayName.trim().isNotEmpty) {
        await credential.user?.updateDisplayName(displayName.trim());
        await credential.user?.reload();
        currentUser.value = _auth.currentUser;
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuth register error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    }
  }

  /// تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuth sign-in error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('FirebaseAuth sign-out error: $e');
      rethrow;
    }
  }

  /// إرسال بريد استعادة كلمة المرور
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuth reset password error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    }
  }

  /// ترجمة رسائل الخطأ الشائعة إلى العربية
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'لم يتم العثور على حساب مرتبط بهذا البريد الإلكتروني.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'كلمة المرور غير صحيحة أو بيانات الاعتماد غير صالحة.';
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مسجل بالفعل بحساب آخر.';
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني المدخل غير صحيحة.';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً، يرجى اختيار كلمة مرور أقوى.';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب من قبل الإدارة.';
      case 'too-many-requests':
        return 'تم إرسال طلبات كثيرة جداً، يرجى المحاولة بعد قليل.';
      case 'network-request-failed':
        return 'تعذر الاتصال بالخادم، يرجى التأكد من اتصال الإنترنت.';
      default:
        return e.message ?? 'حدث خطأ في عملية تسجيل الدخول، يرجى المحاولة لاحقاً.';
    }
  }
}
