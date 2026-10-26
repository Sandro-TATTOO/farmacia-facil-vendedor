import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/orders_provider.dart';
import '../../models/order_model.dart';
import '../../app/theme.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = [
    (label: 'Novos',       status: OrderStatus.pending),
    (label: 'Confirmados', status: OrderStatus.confirmed),
    (label: 'Preparando',  status: OrderStatus.preparing),
    (label: 'Prontos',     status: OrderStatus.ready),
    (label: 'Entregues',   status: OrderStatus.delivered),
    (label: 'Cancelados',  status: OrderStatus.cancelled),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ref.read(ordersProvider.notifier).loadOrders(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: _tabs.map((t) {
            final count = orders
                .where((o) => o.status == t.status)
                .length;
            return Tab(
              child: Row(
                children: [
                  Text(t.label),
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((t) {
          final filtered = orders
              .where((o) => o.status == t.status)
              .toList();
          return _OrdersList(orders: filtered);
        }).toList(),
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  final List<OrderModel> orders;
  const _OrdersList({required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 60, color: Colors.grey),
            SizedBox(height: 12),
            Text('Nenhum pedido aqui',
                style: TextStyle(color: AppTheme.textGrey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _OrderCard(order: orders[index]);
        },
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  Color get _statusColor {
    switch (order.status) {
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go('/orders/${order.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.userName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status.label,
                      style: TextStyle(
                          color: _statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${order.items.length} item(s) — R\$ ${order.totalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(color: AppTheme.textGrey),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    order.isDelivery
                        ? Icons.delivery_dining
                        : Icons.store_outlined,
                    size: 14,
                    color: AppTheme.textGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.isDelivery ? 'Entrega' : 'Retirada',
                    style: const TextStyle(
                        color: AppTheme.textGrey, fontSize: 13),
                  ),
                ],
              ),
              if (order.status == OrderStatus.pending) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => ref
                            .read(ordersProvider.notifier)
                            .updateOrderStatus(
                                order.id, OrderStatus.cancelled),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Recusar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => ref
                            .read(ordersProvider.notifier)
                            .updateOrderStatus(
                                order.id, OrderStatus.confirmed),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.success,
                          minimumSize: const Size(0, 44),
                        ),
                        child: const Text('Confirmar'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
