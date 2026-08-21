import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';

class AdminStats {
  final int customersCount;
  final int craftsmenCount;
  final int todayOrdersCount;
  final double averageRating;
  final Map<String, int> topCategories;
  final Map<String, int> topWilayas;
  final int pendingOrders;
  final int completedOrders;

  const AdminStats({
    required this.customersCount,
    required this.craftsmenCount,
    required this.todayOrdersCount,
    required this.averageRating,
    required this.topCategories,
    required this.topWilayas,
    required this.pendingOrders,
    required this.completedOrders,
  });
}

/// خدمة إحصائيات الأدمن من Firestore
class AdminStatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AdminStats> fetchStats() async {
    try {
      final usersSnap =
          await _firestore.collection(AppConstants.usersCollection).get();
      final ordersSnap =
          await _firestore.collection(AppConstants.ordersCollection).get();

      int customers = 0;
      int craftsmen = 0;
      double ratingSum = 0;
      int ratingCount = 0;
      final wilayaCount = <String, int>{};

      for (final doc in usersSnap.docs) {
        final data = doc.data();
        final role = data['role'] as String? ?? 'customer';
        if (role == UserRole.customer.name) {
          customers++;
        } else if (role == UserRole.craftsman.name ||
            role == UserRole.company.name ||
            role == UserRole.group.name) {
          craftsmen++;
          final r = (data['rating'] ?? 0.0).toDouble();
          final c = (data['ratingCount'] ?? 0) as int;
          if (c > 0) {
            ratingSum += r * c;
            ratingCount += c;
          }
        }
        final wilaya = data['wilaya'] as String?;
        if (wilaya != null && wilaya.isNotEmpty) {
          wilayaCount[wilaya] = (wilayaCount[wilaya] ?? 0) + 1;
        }
      }

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      int todayOrders = 0;
      int pending = 0;
      int completed = 0;
      final categoryCount = <String, int>{};

      for (final doc in ordersSnap.docs) {
        final data = doc.data();
        final createdAtStr = data['createdAt'] as String?;
        if (createdAtStr != null) {
          final created = DateTime.tryParse(createdAtStr);
          if (created != null && created.isAfter(startOfDay)) {
            todayOrders++;
          }
        }
        final status = data['status'] as String? ?? '';
        if (status == OrderStatus.pending.name ||
            status == OrderStatus.accepted.name ||
            status == OrderStatus.inProgress.name) {
          pending++;
        } else if (status == OrderStatus.completed.name) {
          completed++;
        }
        final cat = data['categoryId'] as String? ?? 'other';
        categoryCount[cat] = (categoryCount[cat] ?? 0) + 1;
      }

      // ترتيب الأعلى
      final sortedCats = Map.fromEntries(
        categoryCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)),
      );
      final sortedWilayas = Map.fromEntries(
        wilayaCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)),
      );

      return AdminStats(
        customersCount: customers,
        craftsmenCount: craftsmen,
        todayOrdersCount: todayOrders,
        averageRating:
            ratingCount > 0 ? double.parse((ratingSum / ratingCount).toStringAsFixed(1)) : 0,
        topCategories: Map.fromEntries(sortedCats.entries.take(5)),
        topWilayas: Map.fromEntries(sortedWilayas.entries.take(5)),
        pendingOrders: pending,
        completedOrders: completed,
      );
    } catch (e) {
      // قيم افتراضية عند الفشل
      return const AdminStats(
        customersCount: 0,
        craftsmenCount: 0,
        todayOrdersCount: 0,
        averageRating: 0,
        topCategories: {},
        topWilayas: {},
        pendingOrders: 0,
        completedOrders: 0,
      );
    }
  }

  /// جلب كل المستخدمين (للأدمن)
  Future<List<Map<String, dynamic>>> fetchAllUsers({String? roleFilter}) async {
    try {
      Query q = _firestore.collection(AppConstants.usersCollection);
      if (roleFilter != null && roleFilter != 'all') {
        if (roleFilter == 'craftsman') {
          q = q.where('role', whereIn: [
            UserRole.craftsman.name,
            UserRole.company.name,
            UserRole.group.name,
          ]);
        } else {
          q = q.where('role', isEqualTo: roleFilter);
        }
      }
      final snap = await q.limit(100).get();
      return snap.docs.map((d) {
        final data = d.data() as Map<String, dynamic>;
        data['uid'] = d.id;
        return data;
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// حظر / إلغاء حظر مستخدم
  Future<void> setBlocked(String uid, bool blocked) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
      'isBlocked': blocked,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// توثيق حرفي
  Future<void> setVerified(String uid, bool verified) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
      'isVerified': verified,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}

final adminStatsServiceProvider =
    Provider<AdminStatsService>((ref) => AdminStatsService());
