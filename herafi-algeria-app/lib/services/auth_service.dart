import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

/// خدمة المصادقة باستخدام Firebase Auth (Phone OTP)
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _verificationId;
  int? _resendToken;

  User? get firebaseUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  String? get currentUid => _auth.currentUser?.uid;

  /// إرسال رمز OTP إلى رقم الهاتف
  Future<void> sendOtp({
    required String phone,
    required void Function(String verificationId) onCodeSent,
    required void Function(FirebaseAuthException e) onError,
    void Function(PhoneAuthCredential credential)? onAutoVerify,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        if (onAutoVerify != null) {
          onAutoVerify(credential);
        } else {
          await _auth.signInWithCredential(credential);
        }
      },
      verificationFailed: onError,
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
      forceResendingToken: _resendToken,
    );
  }

  /// التحقق من رمز OTP وتسجيل الدخول
  Future<UserModel> verifyOtp({
    required String smsCode,
    String? verificationId,
  }) async {
    final id = verificationId ?? _verificationId;
    if (id == null) {
      throw Exception('لم يتم إرسال رمز التحقق بعد');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: id,
      smsCode: smsCode,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      throw Exception('فشل تسجيل الدخول');
    }

    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .get();

    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, user.uid);
    }

    final newUser = UserModel(
      uid: user.uid,
      phone: user.phoneNumber ?? '',
      role: UserRole.customer,
      isVerified: true,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(newUser.toMap());

    return newUser;
  }

  Future<UserModel> signInWithCredential(PhoneAuthCredential credential) async {
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) throw Exception('فشل تسجيل الدخول');

    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .get();

    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, user.uid);
    }

    final newUser = UserModel(
      uid: user.uid,
      phone: user.phoneNumber ?? '',
      role: UserRole.customer,
      isVerified: true,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(newUser.toMap());

    return newUser;
  }

  Future<UserModel?> getCurrentUserProfile() async {
    final uid = currentUid;
    if (uid == null) return null;

    final doc =
        await _firestore.collection(AppConstants.usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, uid);
  }

  Future<void> updateProfile(UserModel user) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(user.toMap(), SetOptions(merge: true));
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _verificationId = null;
    _resendToken = null;
  }

  Future<void> deleteAccount() async {
    final uid = currentUid;
    if (uid == null) return;

    await _firestore.collection(AppConstants.usersCollection).doc(uid).delete();
    await _auth.currentUser?.delete();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
