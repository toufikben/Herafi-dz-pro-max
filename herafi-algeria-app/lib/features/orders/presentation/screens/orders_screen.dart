import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/order_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/order_service.dart';
import '../../../../services/current_user_provider.dart';
import '../widgets/rating_dialog.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final uid =
        currentUser?.uid ?? ref.watch(authServiceProvider).currentUid;

    return Scaffold(
      appBar: AppBar(title: const Text('طلباتي')),
      body: uid == null
          ? const Center(child: Text('يرجى تسجيل الدخول'))
          : DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textTertiary,
                    indicatorColor: AppColors.primary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                    tabs: const [
                      Tab(text: 'الجارية'),
                      Tab(text: 'المكتملة'),
                      Tab(text: 'الملغاة'),
                    ],
                  ),
                  Expanded(
                    child: StreamBuilder<List<OrderModel>>(
                      stream: ref
                          .read(orderServiceProvider)
                          .watchCustomerOrders(uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'تعذر تحميل الطلبات. تحقق من Firebase والفهارس.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.textSecondary),
                              ),
                            ),
                          );
                        }
                        final orders = snapshot.data ?? [];
                        final active = orders
                            .where((o) =>
                                o.status == OrderStatus.pending ||
                                o.status == OrderStatus.accepted ||
                                o.status == OrderStatus.inProgress)
                            .toList();
                        final completed = orders
                            .where((o) => o.status == OrderStatus.completed)
                            .toList();
                        final cancelled = orders
                            .where((o) =>
                                o.status == OrderStatus.cancelled ||
                                o.status == OrderStatus.rejected)
                            .toList();

                        return TabBarView(
                          children: [
                            _OrdersList(orders: active, statusLabel: 'جاري'),
                            _OrdersList(
                                orders: completed, statusLabel: 'مكتمل'),
                            _OrdersList(
                                orders: cancelled, statusLabel: 'ملغي'),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _OrdersList extends ConsumerWidget {
  final List<OrderModel> orders;
  final String statusLabel;

  const _OrdersList({required this.orders, required this.statusLabel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded,
                size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text('لا توجد طلبات',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final isCompleted = order.status == OrderStatus.completed;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success.withOpacity(0.12)
                          : AppColors.info.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isCompleted
                            ? AppColors.success
                            : AppColors.info,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '#${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                    style: TextStyle(
                        color: AppColors.textTertiary, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(order.description,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 6),
              Text('${order.wilaya} • ${order.commune}',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              if (isCompleted) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (order.customerRating != null) ...[
                      const Text('تقييمك: ', style: TextStyle(fontSize: 13)),
                      ...List.generate(
                        5,
                        (i) => Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: i < order.customerRating!
                              ? AppColors.star
                              : AppColors.starEmpty,
                        ),
                      ),
                    ] else
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => RatingDialog(
                              craftsmanName: 'الحرفي',
                              onSubmit: (rating) async {
                                try {
                                  await ref
                                      .read(orderServiceProvider)
                                      .rateOrder(
                                        orderId: order.id,
                                        craftsmanId: order.craftsmanId,
                                        rating: rating,
                                      );
                                } catch (_) {}
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'تم تسجيل تقييم $rating نجوم'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                        child: const Text('تقييم الآن',
                            style: TextStyle(fontSize: 13)),
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
