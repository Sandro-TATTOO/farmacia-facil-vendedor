import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/products_provider.dart';
import '../../models/product_model.dart';
import '../../app/theme.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () =>
                ref.read(productsProvider.notifier).loadProducts(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/products/add'),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text('Adicionar', style: TextStyle(color: Colors.white)),
      ),
      body: products.isEmpty
          ? const _EmptyProducts()
          : Column(
              children: [
                // Resumo
                Container(
                  color: AppTheme.primary,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      _StatChip(
                        label: 'Total',
                        value: '${products.length}',
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      _StatChip(
                        label: 'Disponíveis',
                        value:
                            '${products.where((p) => p.isAvailable).length}',
                        color: Colors.greenAccent,
                      ),
                      const SizedBox(width: 12),
                      _StatChip(
                        label: 'Sem estoque',
                        value:
                            '${products.where((p) => p.stock == 0).length}',
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    itemBuilder: (context, index) =>
                        _ProductCard(product: products[index]),
                  ),
                ),
              ],
            ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatChip(
      {required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(width: 4),
            Text(label,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      );
}

class _ProductCard extends ConsumerWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockColor = product.stock == 0
        ? Colors.red
        : product.stock < 10
            ? Colors.orange
            : AppTheme.success;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Ícone categoria
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.medication,
                  color: AppTheme.primary, size: 26),
            ),
            const SizedBox(width: 14),
            // Dados
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(product.category,
                      style: const TextStyle(
                          color: AppTheme.textGrey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(product.formattedPrice,
                          style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: stockColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Estoque: ${product.stock}',
                          style: TextStyle(
                              color: stockColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Ações
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'stock',
                  child: Row(children: [
                    Icon(Icons.inventory_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Atualizar estoque'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outline,
                        size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Remover',
                        style: TextStyle(color: Colors.red)),
                  ]),
                ),
              ],
              onSelected: (value) async {
                if (value == 'edit') {
                  context.go('/products/edit/${product.id}');
                } else if (value == 'stock') {
                  _showStockDialog(context, ref, product);
                } else if (value == 'delete') {
                  await ref
                      .read(productsProvider.notifier)
                      .deleteProduct(product.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStockDialog(
      BuildContext context, WidgetRef ref, ProductModel product) {
    final ctrl = TextEditingController(text: '${product.stock}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Atualizar estoque'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Produto: ${product.name}'),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantidade em estoque',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newStock = int.tryParse(ctrl.text) ?? product.stock;
              ref
                  .read(productsProvider.notifier)
                  .updateStock(product.id, newStock);
              Navigator.pop(ctx);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inventory_2_outlined,
            size: 70, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        const Text('Nenhum produto cadastrado',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Adicione produtos para que os clientes\npossam fazer pedidos.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textGrey)),
      ],
    ),
  );
}
