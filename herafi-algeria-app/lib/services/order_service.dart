import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import '../core/constants/app_constants.dart';
import 'user_service.dart';

/// خدمة الطلبات عبر Firestore
class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();

  CollectionReference get _orders =>
      _firestore.collection(AppConstants.ordersCollection);

  Future<OrderModel> createOrder({
    required String customerId,
    required String craftsmanId,
    required String categoryId,
    required String description,
    required String wilaya,
    required String commune,
    String? address,
    DateTime? preferredTime,
  }) async {
    final docRef = _orders.doc();

    final order = OrderModel(
      id: docRef.id,
      customerId: customerId,
      craftsmanId: craftsmanId,
      categoryId: categoryId,
      description: description,
      wilaya: wilaya,
      commune: commune,
      address: address,
      preferredTime: preferredTime,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );

    await docRef.set(order.toMap());
    return order;
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    final data = <String, dynamic>{
      'status': status.name,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (status == OrderStatus.completed) {
      data['completedAt'] = DateTime.now().toIso8601String();
    }

    await _orders.doc(orderId).update(data);
  }

  Future<void> rateOrder({
    required String orderId,
    required String craftsmanId,
    required int rating,
  }) async {
    await _orders.doc(orderId).update({
      'customerRating': rating,
      'updatedAt': DateTime.now().toIso8601String(),
    });

    await _userService.updateCraftsmanRating(
      craftsmanId: craftsmanId,
      newRating: rating,
    );
  }

  Stream<List<OrderModel>> watchCustomerOrders(String customerId) {
    return _orders
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                OrderModel.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  Stream<List<OrderModel>> watchCraftsmanOrders(String craftsmanId) {
    return _orders
        .where('craftsmanId', isEqualTo: craftsmanId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                OrderModel.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  Future<OrderModel?> getOrder(String orderId) async {
    final doc = await _orders.doc(orderId).get();
    if (!doc.exists) return null;
    return OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
}

final orderServiceProvider = Provider<OrderService>((ref) => OrderService());
