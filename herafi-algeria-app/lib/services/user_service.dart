import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

/// خدمة إدارة المستخدمين والحرفيين عبر Firestore
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _users =>
      _firestore.collection(AppConstants.usersCollection);

  /// جلب مستخدم بالمعرف
  Future<UserModel?> getUserById(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
  }

  /// تحديث بيانات مستخدم
  Future<void> updateUser(UserModel user) async {
    await _users.doc(user.uid).set(
          user.copyWith(updatedAt: DateTime.now()).toMap(),
          SetOptions(merge: true),
        );
  }

  /// البحث عن حرفيين حسب الفلاتر
  Future<List<UserModel>> searchCraftsmen({
    String? categoryId,
    String? wilaya,
    String? commune,
    double minRating = 0,
    bool verifiedOnly = false,
    String? query,
    int limit = 20,
  }) async {
    Query q = _users.where('role', whereIn: [
      UserRole.craftsman.name,
      UserRole.company.name,
      UserRole.group.name,
    ]);

    if (wilaya != null && wilaya.isNotEmpty) {
      q = q.where('wilaya', isEqualTo: wilaya);
    }

    if (verifiedOnly) {
      q = q.where('isVerified', isEqualTo: true);
    }

    q = q.where('isActive', isEqualTo: true);
    q = q.where('isBlocked', isEqualTo: false);

    // Firestore يحتاج فهارس مركبة لبعض الاستعلامات
    // نرتب حسب التقييم ونفلتر محلياً الباقي إن لزم
    final snapshot = await q.limit(limit * 2).get();

    var results = snapshot.docs
        .map((d) => UserModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();

    // فلترة محلية للتخصص والتقييم والبحث النصي
    if (categoryId != null && categoryId.isNotEmpty) {
      results = results
          .where((u) => u.specialties.contains(categoryId))
          .toList();
    }

    if (commune != null && commune.isNotEmpty) {
      results = results.where((u) => u.commune == commune).toList();
    }

    if (minRating > 0) {
      results = results.where((u) => u.rating >= minRating).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final qLower = query.trim().toLowerCase();
      results = results.where((u) {
        final name = (u.fullName ?? '').toLowerCase();
        final bio = (u.bio ?? '').toLowerCase();
        return name.contains(qLower) || bio.contains(qLower);
      }).toList();
    }

    // ترتيب حسب التقييم
    results.sort((a, b) => b.rating.compareTo(a.rating));

    return results.take(limit).toList();
  }

  /// جلب حرفيين مميزين (أعلى تقييم)
  Future<List<UserModel>> getFeaturedCraftsmen({int limit = 10}) async {
    final snapshot = await _users
        .where('role', whereIn: [
          UserRole.craftsman.name,
          UserRole.company.name,
          UserRole.group.name,
        ])
        .where('isActive', isEqualTo: true)
        .where('isBlocked', isEqualTo: false)
        .orderBy('rating', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((d) => UserModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  /// تحديث تقييم الحرفي بعد تقييم جديد
  Future<void> updateCraftsmanRating({
    required String craftsmanId,
    required int newRating,
  }) async {
    final ref = _users.doc(craftsmanId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(ref);
      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      final currentRating = (data['rating'] ?? 0.0).toDouble();
      final currentCount = (data['ratingCount'] ?? 0) as int;

      final newCount = currentCount + 1;
      final newAvg =
          ((currentRating * currentCount) + newRating) / newCount;

      transaction.update(ref, {
        'rating': double.parse(newAvg.toStringAsFixed(1)),
        'ratingCount': newCount,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    });
  }
}

final userServiceProvider = Provider<UserService>((ref) => UserService());
