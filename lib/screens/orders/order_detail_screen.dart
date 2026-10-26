import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/orders_provider.dart';
import '../../models/order_model.dart';
import '../../app/theme.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:    return Colors.orange;
      case OrderStatus.confirmed:  return Colors.blue;
      case OrderStatus.preparing:  return Colors.purple;
      case OrderStatus.ready:      return Colors.teal;
      case OrderStatus.delivering: return Colors.indigo;
      case OrderStatus.delivered:  return AppTheme.success;
      case OrderStatus.cancelled:  return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final order  = orders.where((o) => o.id == orderId).firstOrNull;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pedido')),
        body: const Center(child: Text('Pedido não encontrado')),
      );
    }

    final color = _statusColor(order.status);

    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #${order.id.substring(0, 6).toUpperCase()}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/orders'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status atual
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: color),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status atual',
                          style: TextStyle(color: color, fontSize: 12)),
                      Text(order.status.label,
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Dados do cliente
            _Section(title: 'Cliente', children: [
              _InfoRow(icon: Icons.person_outlined, text: order.userName),
              _InfoRow(
                icon: order.isDelivery
                    ? Icons.delivery_dining
                    : Icons.store_outlined,
                text: order.isDelivery
                    ? 'Entrega — ${order.deliveryAddress}'
                    : 'Retirada na farmácia',
              ),
            ]),
            const SizedBox(height: 16),

            // Itens do pedido
            _Section(
              title: 'Itens do pedido (${order.items.length})',
              children: [
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.medication_outlined,
                          size: 18, color: AppTheme.textGrey),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(item.productName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500)),
                      ),
                      Text('${item.quantity}x',
                          style:
                              const TextStyle(color: AppTheme.textGrey)),
                      const SizedBox(width: 8),
                      Text(
                        'R\$ ${item.subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      'R\$ ${order.totalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.primary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Ações de atualização de status
            if (order.status != OrderStatus.delivered &&
                order.status != OrderStatus.cancelled) ...[
              const Text('Atualizar status',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ..._nextStatuses(order.status).map((nextStatus) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(ordersProvider.notifier)
                            .updateOrderStatus(order.id, nextStatus);
                        context.go('/orders');
                      },
                      icon: Icon(_statusIcon(nextStatus)),
                      label: Text('Marcar como: ${nextStatus.label}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _statusColor(nextStatus),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  )),
              if (order.status == OrderStatus.pending)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref
                          .read(ordersProvider.notifier)
                          .updateOrderStatus(
                              order.id, OrderStatus.cancelled);
                      context.go('/orders');
                    },
                    icon: const Icon(Icons.cancel_outlined,
                        color: Colors.red),
                    label: const Text('Cancelar pedido',
                        style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  List<OrderStatus> _nextStatuses(OrderStatus current) {
    switch (current) {
      case OrderStatus.pending:    return [OrderStatus.confirmed];
      case OrderStatus.confirmed:  return [OrderStatus.preparing];
      case OrderStatus.preparing:  return [OrderStatus.ready];
      case OrderStatus.ready:
        return [OrderStatus.delivering, OrderStatus.delivered];
      case OrderStatus.delivering: return [OrderStatus.delivered];
      default: return [];
    }
  }

  IconData _statusIcon(OrderStatus s) {
    switch (s) {
      case OrderStatus.confirmed:  return Icons.check_circle_outline;
      case OrderStatus.preparing:  return Icons.restaurant_outlined;
      case OrderStatus.ready:      return Icons.inventory_outlined;
      case OrderStatus.delivering: return Icons.delivery_dining;
      case OrderStatus.delivered:  return Icons.done_all;
      default: return Icons.update;
    }
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppTheme.textDark)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textGrey),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
