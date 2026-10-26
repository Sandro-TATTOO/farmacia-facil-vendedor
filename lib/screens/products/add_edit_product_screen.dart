import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/products_provider.dart';
import '../../models/product_model.dart';
import '../../app/theme.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  final String? productId; // null = novo produto
  const AddEditProductScreen({super.key, this.productId});

  @override
  ConsumerState<AddEditProductScreen> createState() =>
      _AddEditProductScreenState();
}

class _AddEditProductScreenState
    extends ConsumerState<AddEditProductScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _descCtrl    = TextEditingController();
  final _priceCtrl   = TextEditingController();
  final _stockCtrl   = TextEditingController();

  String _category = 'Analgésico';
  bool   _requiresPrescription = false;
  bool   _isLoading = false;

  static const _categories = [
    'Analgésico', 'Antibiótico', 'Anti-inflamatório',
    'Antihistamínico', 'Antifúngico', 'Vitamina',
    'Suplemento', 'Dermatológico', 'Oftalmológico',
    'Cardiovascular', 'Gastrointestinal', 'Outros',
  ];

  bool get _isEditing => widget.productId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final products = ref.read(productsProvider);
        final product = products
            .where((p) => p.id == widget.productId)
            .firstOrNull;
        if (product != null) {
          _nameCtrl.text  = product.name;
          _descCtrl.text  = product.description;
          _priceCtrl.text = product.price.toStringAsFixed(2);
          _stockCtrl.text = '${product.stock}';
          setState(() {
            _category = product.category;
            _requiresPrescription = product.requiresPrescription;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose();
    _priceCtrl.dispose(); _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final price = double.tryParse(
            _priceCtrl.text.replaceAll(',', '.')) ??
        0;
    final stock = int.tryParse(_stockCtrl.text) ?? 0;

    final product = ProductModel(
      id:                   widget.productId ?? '',
      pharmacyId:           FirebaseAuth.instance.currentUser?.uid ?? '',
      name:                 _nameCtrl.text.trim(),
      description:          _descCtrl.text.trim(),
      category:             _category,
      price:                price,
      stock:                stock,
      requiresPrescription: _requiresPrescription,
      isActive:             true,
      createdAt:            DateTime.now(),
    );

    try {
      if (_isEditing) {
        await ref.read(productsProvider.notifier).updateProduct(product);
      } else {
        await ref.read(productsProvider.notifier).addProduct(product);
      }
      if (mounted) context.go('/products');
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar produto' : 'Novo produto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/products'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nome do produto',
                    prefixIcon: Icon(Icons.medication_outlined),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Descrição (opcional)',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Categoria
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Preço (R\$)',
                          prefixIcon: Icon(Icons.attach_money),
                          hintText: '0,00',
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Informe o preço' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _stockCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Estoque',
                          prefixIcon: Icon(Icons.inventory_outlined),
                          hintText: '0',
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Informe o estoque' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Requer receita
                SwitchListTile(
                  value: _requiresPrescription,
                  onChanged: (v) =>
                      setState(() => _requiresPrescription = v),
                  title: const Text('Requer receita médica'),
                  subtitle: const Text(
                      'Produto controlado ou de venda restrita'),
                  activeColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  tileColor: Colors.white,
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(_isEditing ? 'Salvar alterações' : 'Adicionar produto'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
