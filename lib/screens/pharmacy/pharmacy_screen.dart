import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../app/theme.dart';

class PharmacyScreen extends ConsumerStatefulWidget {
  const PharmacyScreen({super.key});

  @override
  ConsumerState<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends ConsumerState<PharmacyScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _nameCtrl        = TextEditingController();
  final _ownerCtrl       = TextEditingController();
  final _phoneCtrl       = TextEditingController();
  final _addressCtrl     = TextEditingController();
  final _cityCtrl        = TextEditingController();
  final _stateCtrl       = TextEditingController();
  final _zipCtrl         = TextEditingController();
  final _hoursCtrl       = TextEditingController();
  bool _hasDelivery      = false;
  bool _editing          = false;
  bool _isLoading        = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final vendor = ref.read(vendorAuthProvider).vendor;
    if (vendor == null) return;
    _nameCtrl.text    = vendor.name;
    _ownerCtrl.text   = vendor.ownerName;
    _phoneCtrl.text   = vendor.phone;
    _addressCtrl.text = vendor.address;
    _cityCtrl.text    = vendor.city;
    _stateCtrl.text   = vendor.state;
    _zipCtrl.text     = vendor.zipCode;
    _hoursCtrl.text   = vendor.openingHours;
    _hasDelivery      = vendor.hasDelivery;
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _ownerCtrl.dispose();
    _phoneCtrl.dispose(); _addressCtrl.dispose();
    _cityCtrl.dispose(); _stateCtrl.dispose();
    _zipCtrl.dispose(); _hoursCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // Atualização no Firestore será implementada
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() { _isLoading = false; _editing = false; });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados atualizados com sucesso!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth   = ref.watch(vendorAuthProvider);
    final vendor = auth.vendor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Farmácia'),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.white),
              onPressed: () => setState(() => _editing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() => _editing = false);
                _loadData();
              },
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Status da farmácia
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: vendor?.isApproved == true
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: vendor?.isApproved == true
                        ? Colors.green.shade200
                        : Colors.orange.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      vendor?.isApproved == true
                          ? Icons.verified
                          : Icons.hourglass_top,
                      color: vendor?.isApproved == true
                          ? AppTheme.success
                          : Colors.orange,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      vendor?.statusLabel ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: vendor?.isApproved == true
                            ? AppTheme.success
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildField(_nameCtrl,    'Nome da farmácia'),
              _buildField(_ownerCtrl,   'Nome do responsável'),
              _buildField(_phoneCtrl,   'Telefone',
                  type: TextInputType.phone),
              _buildField(_addressCtrl, 'Endereço'),
              Row(
                children: [
                  Expanded(child: _buildField(_cityCtrl,  'Cidade')),
                  const SizedBox(width: 12),
                  SizedBox(width: 80,
                      child: _buildField(_stateCtrl, 'UF')),
                ],
              ),
              _buildField(_zipCtrl,   'CEP',
                  type: TextInputType.number),
              _buildField(_hoursCtrl, 'Horário de funcionamento',
                  hint: 'Ex: Seg-Sex 8h-20h'),

              // Entrega
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SwitchListTile(
                  value: _hasDelivery,
                  onChanged: _editing
                      ? (v) => setState(() => _hasDelivery = v)
                      : null,
                  title: const Text('Faz entrega'),
                  activeColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  tileColor: Colors.white,
                ),
              ),

              if (_editing) ...[
                ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Salvar alterações'),
                ),
                const SizedBox(height: 16),
              ],

              // Dados de acesso (só leitura)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Dados de acesso',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.email_outlined,
                              size: 16, color: AppTheme.textGrey),
                          const SizedBox(width: 8),
                          Text(vendor?.email ?? '',
                              style: const TextStyle(
                                  color: AppTheme.textGrey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label, {
    TextInputType? type,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        readOnly: !_editing,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: _editing ? Colors.white : Colors.grey.shade50,
        ),
        validator: (v) =>
            v == null || v.isEmpty ? 'Campo obrigatório' : null,
      ),
    );
  }
}
