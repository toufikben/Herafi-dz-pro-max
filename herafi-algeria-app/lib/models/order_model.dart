import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending,    // في انتظار قبول الحرفي
  accepted,   // تم القبول
  rejected,   // مرفوض
  inProgress, // جاري التنفيذ
  completed,  // مكتمل
  cancelled,  // ملغي
}

class OrderModel extends Equatable {
  final String id;
  final String customerId;
  final String craftsmanId;
  final String categoryId;
  final String description;
  final String wilaya;
  final String commune;
  final String? address;
  final DateTime? preferredTime; // null = فوري
  final OrderStatus status;
  final int? customerRating; // 1-5
  final int? craftsmanRating; // 1-5 (تقييم الزبون من الحرفي)
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  const OrderModel({
    required this.id,
    required this.customerId,
    required this.craftsmanId,
    required this.categoryId,
    required this.description,
    required this.wilaya,
    required this.commune,
    this.address,
    this.preferredTime,
    this.status = OrderStatus.pending,
    this.customerRating,
    this.craftsmanRating,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      customerId: map['customerId'] ?? '',
      craftsmanId: map['craftsmanId'] ?? '',
      categoryId: map['categoryId'] ?? '',
      description: map['description'] ?? '',
      wilaya: map['wilaya'] ?? '',
      commune: map['commune'] ?? '',
      address: map['address'],
      preferredTime: map['preferredTime'] != null
          ? DateTime.parse(map['preferredTime'])
          : null,
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      customerRating: map['customerRating'],
      craftsmanRating: map['craftsmanRating'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'craftsmanId': craftsmanId,
      'categoryId': categoryId,
      'description': description,
      'wilaya': wilaya,
      'commune': commune,
      'address': address,
      'preferredTime': preferredTime?.toIso8601String(),
      'status': status.name,
      'customerRating': customerRating,
      'craftsmanRating': craftsmanRating,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  OrderModel copyWith({
    OrderStatus? status,
    int? customerRating,
    int? craftsmanRating,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return OrderModel(
      id: id,
      customerId: customerId,
      craftsmanId: craftsmanId,
      categoryId: categoryId,
      description: description,
      wilaya: wilaya,
      commune: commune,
      address: address,
      preferredTime: preferredTime,
      status: status ?? this.status,
      customerRating: customerRating ?? this.customerRating,
      craftsmanRating: craftsmanRating ?? this.craftsmanRating,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [id, status, customerRating];
}
