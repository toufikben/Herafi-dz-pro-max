import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/order_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/order_service.dart';
import '../../../../services/current_user_provider.dart';

/// شاشة طلبات الحرفي: قبول / رفض / إنهاء
class CraftsmanOrdersScreen extends ConsumerWidget {
  const CraftsmanOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final uid = user?.uid ?? ref.watch(authServiceProvider).currentUid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('يرجى تسجيل الدخول')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('طلبات العمل')),
      body: StreamBuilder<List<OrderModel>>(
        stream: ref.read(orderServiceProvider).watchCraftsmanOrders(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting &&
              !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'تعذر تحميل الطلبات. تحقق من Firebase والفهارس.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            );
          }
          final orders = snap.data ?? [];
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_rounded,
                      size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text('لا توجد طلبات بعد',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, i) {
              final o = orders[i];
              return _CraftsmanOrderCard(order: o);
            },
          );
        },
      ),
    );
  }
}

class _CraftsmanOrderCard extends ConsumerWidget {
  final OrderModel order;
  const _CraftsmanOrderCard({required this.order});

  String get _statusAr {
    switch (order.status) {
      case OrderStatus.pending:
        return 'جديد';
      case OrderStatus.accepted:
        return 'مقبول';
      case OrderStatus.rejected:
        return 'مرفوض';
      case OrderStatus.inProgress:
        return 'جاري';
      case OrderStatus.completed:
        return 'مكتمل';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.accepted:
      case OrderStatus.inProgress:
        return AppColors.info;
      case OrderStatus.completed:
        return AppColors.success;
      case OrderStatus.rejected:
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  Future<void> _update(WidgetRef ref, OrderStatus status) async {
    await ref.read(orderServiceProvider).updateStatus(order.id, status);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusAr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _statusColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '#${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(order.description,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 6),
          Text('${order.wilaya} • ${order.commune}',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          if (order.address != null && order.address!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(order.address!,
                style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
          ],
          if (order.status == OrderStatus.pending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _update(ref, OrderStatus.rejected),
                    child: const Text('رفض'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _update(ref, OrderStatus.accepted),
                    child: const Text('قبول'),
                  ),
                ),
              ],
            ),
          ],
          if (order.status == OrderStatus.accepted ||
              order.status == OrderStatus.inProgress) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (order.status == OrderStatus.accepted)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _update(ref, OrderStatus.inProgress),
                      child: const Text('بدء التنفيذ'),
                    ),
                  ),
                if (order.status == OrderStatus.accepted)
                  const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _update(ref, OrderStatus.completed),
                    child: const Text('إنهاء الخدمة'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
