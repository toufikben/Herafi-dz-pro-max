import 'package:cloud_firestore/cloud_firestore.dart';

class AdminStats {
  final int customersCount;
  final int craftsmenCount;
  final int todayOrdersCount;
  final int completedOrders;
  final int pendingOrders;
  final double averageRating;
  final Map<String, int> topCategories;
  final Map<String, int> topWilayas;

  AdminStats({
    required this.customersCount,
    required this.craftsmenCount,
    required this.todayOrdersCount,
    required this.completedOrders,
    required this.pendingOrders,
    required this.averageRating,
    required this.topCategories,
    required this.topWilayas,
  });
}

class AdminStatsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<AdminStats> fetchStats() async {
    final users = await _db.collection('users').get();
    final orders = await _db.collection('orders').get();
    
    int customers = 0;
    int craftsmen = 0;
    Map<String, int> categories = {};
    Map<String, int> wilayas = {};
    double totalRating = 0;
    int ratedCount = 0;

    for (var doc in users.docs) {
      final data = doc.data();
      final role = data['role'] as String?;
      if (role == 'craftsman' || role == 'company' || role == 'group') {
        craftsmen++;
        final specs = data['specialties'] as List?;
        if (specs != null) {
          for (var s in specs) {
            categories[s.toString()] = (categories[s.toString()] ?? 0) + 1;
          }
        }
        final rating = data['rating'] as num?;
        if (rating != null && rating > 0) {
          totalRating += rating.toDouble();
          ratedCount++;
        }
      } else {
        customers++;
      }
      final w = data['wilaya'] as String?;
      if (w != null) {
        wilayas[w] = (wilayas[w] ?? 0) + 1;
      }
    }

    int completed = 0;
    int pending = 0;
    int today = 0;
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    for (var doc in orders.docs) {
      final data = doc.data();
      final status = data['status'] as String?;
      if (status == 'completed') completed++;
      if (status == 'pending') pending++;
      
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      if (createdAt != null && createdAt.isAfter(startOfToday)) {
        today++;
      }
    }

    return AdminStats(
      customersCount: customers,
      craftsmenCount: craftsmen,
      todayOrdersCount: today,
      completedOrders: completed,
      pendingOrders: pending,
      averageRating: ratedCount > 0 ? totalRating / ratedCount : 0,
      topCategories: categories,
      topWilayas: wilayas,
    );
  }

  Future<List<Map<String, dynamic>>> fetchAllUsers({String? roleFilter}) async {
    Query query = _db.collection('users').orderBy('createdAt', descending: true);
    if (roleFilter != null && roleFilter != 'all') {
      if (roleFilter == 'craftsman') {
        query = query.where('role', whereIn: ['craftsman', 'company', 'group']);
      } else {
        query = query.where('role', isEqualTo: roleFilter);
      }
    }
    final snap = await query.get();
    return snap.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return <String, dynamic>{...data, 'uid': doc.id};
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchAllOrders() async {
    final snap = await _db.collection('orders').orderBy('createdAt', descending: true).get();
    return snap.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return <String, dynamic>{...data, 'id': doc.id};
    }).toList();
  }

  Future<Map<String, Map<String, dynamic>>> fetchUsersByIds(List<String> ids) async {
    if (ids.isEmpty) return {};
    final Map<String, Map<String, dynamic>> results = {};
    final snap = await _db.collection('users').get();
    for (var doc in snap.docs) {
      if (ids.contains(doc.id)) {
        final data = doc.data() as Map<String, dynamic>;
        results[doc.id] = <String, dynamic>{...data, 'uid': doc.id};
      }
    }
    return results;
  }

  Future<void> setVerified(String uid, bool verified) async {
    await _db.collection('users').doc(uid).update({'isVerified': verified});
  }

  Future<void> setBlocked(String uid, bool blocked) async {
    await _db.collection('users').doc(uid).update({'isActive': !blocked});
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db.collection('orders').doc(orderId).update({'status': status});
  }
}
