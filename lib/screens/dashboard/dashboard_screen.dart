import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/orders_provider.dart';
import '../../models/order_model.dart';
import '../../app/theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth    = ref.watch(vendorAuthProvider);
    final orders  = ref.watch(ordersProvider);
    final pending = orders.where((o) => o.status == OrderStatus.pending).toList();
    final today   = ref.read(ordersProvider.notifier).todayOrders;
    final revenue = ref.read(ordersProvider.notifier).todayRevenue;

    return Scaffold(
      appBar: AppBar(
        title: Text(auth.vendor?.name ?? 'Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => ref.read(ordersProvider.notifier).loadOrders(),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await ref.read(vendorAuthProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(ordersProvider.notifier).loadOrders(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumo do dia
              const Text('Resumo de hoje',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _SummaryCard(
                    icon: Icons.pending_actions,
                    label: 'Novos pedidos',
                    value: '${pending.length}',
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  _SummaryCard(
                    icon: Icons.receipt_long,
                    label: 'Pedidos hoje',
                    value: '${today.length}',
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 12),
                  _SummaryCard(
                    icon: Icons.attach_money,
                    label: 'Faturamento',
                    value: 'R\$ ${revenue.toStringAsFixed(0)}',
                    color: AppTheme.success,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Alertas de novos pedidos
              if (pending.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.notification_important,
                          color: Colors.orange.shade700),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${pending.length} pedido(s) aguardando sua confirmação!',
                          style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/orders'),
                        child: const Text('Ver'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Ações rápidas
              const Text('Ações rápidas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _ActionCard(
                    icon: Icons.receipt_long,
                    label: 'Pedidos',
                    color: AppTheme.primary,
                    badge: pending.length,
                    onTap: () => context.go('/orders'),
                  ),
                  _ActionCard(
                    icon: Icons.inventory_2,
                    label: 'Produtos',
                    color: Colors.purple,
                    onTap: () => context.go('/products'),
                  ),
                  _ActionCard(
                    icon: Icons.store,
                    label: 'Minha Farmácia',
                    color: AppTheme.success,
                    onTap: () => context.go('/pharmacy'),
                  ),
                  _ActionCard(
                    icon: Icons.bar_chart,
                    label: 'Relatórios',
                    color: Colors.teal,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Últimos pedidos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Últimos pedidos',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => context.go('/orders'),
                    child: const Text('Ver todos'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (orders.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Nenhum pedido ainda',
                        style: TextStyle(color: AppTheme.textGrey)),
                  ),
                )
              else
                ...orders.take(5).map((order) => _OrderPreviewCard(order: order)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;

  const _SummaryCard({
    required this.icon, required this.label,
    required this.value, required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(color: AppTheme.textGrey, fontSize: 11),
              textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final int badge;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon, required this.label,
    required this.color, required this.onTap, this.badge = 0,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
          if (badge > 0)
            Positioned(
              top: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
                child: Text('$badge',
                    style: const TextStyle(color: Colors.white, fontSize: 11)),
              ),
            ),
        ],
      ),
    ),
  );
}

class _OrderPreviewCard extends StatelessWidget {
  final OrderModel order;
  const _OrderPreviewCard({required this.order});

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
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: _statusColor.withValues(alpha: 0.15),
        child: Icon(Icons.receipt, color: _statusColor),
      ),
      title: Text(order.userName,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
          '${order.items.length} item(s) • R\$ ${order.totalPrice.toStringAsFixed(2)}'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(order.status.label,
            style: TextStyle(color: _statusColor, fontSize: 11,
                fontWeight: FontWeight.bold)),
      ),
    ),
  );
}
