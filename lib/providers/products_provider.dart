import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';

class ProductsNotifier extends Notifier<List<ProductModel>> {
  final _firestore = FirebaseFirestore.instance;
  final _auth      = FirebaseAuth.instance;

  String? get _pharmacyId => _auth.currentUser?.uid;

  CollectionReference? get _collection {
    if (_pharmacyId == null) return null;
    return _firestore
        .collection('pharmacies')
        .doc(_pharmacyId)
        .collection('products');
  }

  @override
  List<ProductModel> build() {
    Future.microtask(loadProducts);
    return [];
  }

  Future<void> loadProducts() async {
    if (_collection == null) return;
    try {
      final snapshot = await _collection!
          .orderBy('name')
          .get();

      state = snapshot.docs.map((doc) {
        return ProductModel.fromMap({'id': doc.id, ...doc.data() as Map<String, dynamic>});
      }).toList();

      _log('Produtos carregados: ${state.length}');
    } catch (e) {
      _log('Erro ao carregar produtos: $e');
    }
  }

  Future<void> addProduct(ProductModel product) async {
    if (_collection == null) return;
    try {
      final map = product.toMap()..remove('id');
      final docRef = await _collection!.add(map);
      final newProduct = ProductModel.fromMap({'id': docRef.id, ...map});
      state = [newProduct, ...state];
      _log('Produto adicionado: ${product.name}');
    } catch (e) {
      _log('Erro ao adicionar produto: $e');
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    if (_collection == null) return;
    try {
      final map = product.toMap()..remove('id');
      await _collection!.doc(product.id).update(map);
      state = state.map((p) => p.id == product.id ? product : p).toList();
      _log('Produto atualizado: ${product.name}');
    } catch (e) {
      _log('Erro ao atualizar produto: $e');
    }
  }

  Future<void> updateStock(String productId, int newStock) async {
    if (_collection == null) return;
    try {
      await _collection!.doc(productId).update({'stock': newStock});
      state = state.map((p) {
        if (p.id == productId) return p.copyWith(stock: newStock);
        return p;
      }).toList();
    } catch (e) {
      _log('Erro ao atualizar estoque: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    if (_collection == null) return;
    try {
      await _collection!.doc(productId).delete();
      state = state.where((p) => p.id != productId).toList();
    } catch (e) {
      _log('Erro ao deletar produto: $e');
    }
  }

  void _log(String msg) {
    if (kDebugMode) debugPrint('[Products] $msg');
  }
}

final productsProvider = NotifierProvider<ProductsNotifier, List<ProductModel>>(
  ProductsNotifier.new,
);
