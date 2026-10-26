import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';

class OrdersNotifier extends Notifier<List<OrderModel>> {
  final _firestore = FirebaseFirestore.instance;
  final _auth      = FirebaseAuth.instance;

  String? get _pharmacyId => _auth.currentUser?.uid;

  @override
  List<OrderModel> build() {
    Future.microtask(loadOrders);
    return [];
  }

  Future<void> loadOrders() async {
    if (_pharmacyId == null) return;
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('pharmacyId', isEqualTo: _pharmacyId)
          .get();

      final orders = snapshot.docs.map((doc) {
        return OrderModel.fromMap({'id': doc.id, ...doc.data()});
      }).toList();

      // Ordena localmente por data (mais recente primeiro)
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = orders;

      _log('Pedidos carregados: ${state.length}');
    } catch (e) {
      _log('Erro ao carregar pedidos: $e');
    }
  }

  // Atualiza status do pedido
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status':    newStatus.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      state = state.map((o) {
        if (o.id == orderId) {
          return o.copyWith(status: newStatus, updatedAt: DateTime.now());
        }
        return o;
      }).toList();

      _log('Pedido $orderId → ${newStatus.label}');
    } catch (e) {
      _log('Erro ao atualizar pedido: $e');
    }
  }

  // Pedidos por status
  List<OrderModel> byStatus(OrderStatus status) =>
      state.where((o) => o.status == status).toList();

  // Pedidos de hoje
  List<OrderModel> get todayOrders {
    final today = DateTime.now();
    return state.where((o) =>
      o.createdAt.year  == today.year &&
      o.createdAt.month == today.month &&
      o.createdAt.day   == today.day
    ).toList();
  }

  // Faturamento do dia
  double get todayRevenue => todayOrders
      .where((o) => o.status == OrderStatus.delivered)
      .fold(0, (sum, o) => sum + o.totalPrice);

  void _log(String msg) {
    if (kDebugMode) debugPrint('[Orders] $msg');
  }
}

final ordersProvider = NotifierProvider<OrdersNotifier, List<OrderModel>>(
  OrdersNotifier.new,
);
