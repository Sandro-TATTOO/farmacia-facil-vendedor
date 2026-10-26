import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../app/theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey              = GlobalKey<FormState>();
  final _pharmacyNameCtrl     = TextEditingController();
  final _ownerNameCtrl        = TextEditingController();
  final _emailCtrl            = TextEditingController();
  final _phoneCtrl            = TextEditingController();
  final _addressCtrl          = TextEditingController();
  final _cityCtrl             = TextEditingController();
  final _stateCtrl            = TextEditingController();
  final _zipCodeCtrl          = TextEditingController();
  final _passwordCtrl         = TextEditingController();
  final _confirmPasswordCtrl  = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _pharmacyNameCtrl.dispose(); _ownerNameCtrl.dispose();
    _emailCtrl.dispose(); _phoneCtrl.dispose();
    _addressCtrl.dispose(); _cityCtrl.dispose();
    _stateCtrl.dispose(); _zipCodeCtrl.dispose();
    _passwordCtrl.dispose(); _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(vendorAuthProvider.notifier).register(
      pharmacyName: _pharmacyNameCtrl.text.trim(),
      ownerName:    _ownerNameCtrl.text.trim(),
      email:        _emailCtrl.text.trim(),
      password:     _passwordCtrl.text,
      phone:        _phoneCtrl.text.trim(),
      address:      _addressCtrl.text.trim(),
      city:         _cityCtrl.text.trim(),
      state:        _stateCtrl.text.trim(),
      zipCode:      _zipCodeCtrl.text.trim(),
    );

    if (success && mounted) context.go('/pending');
  }

  Widget _field(TextEditingController ctrl, String label,
      {TextInputType? type, String? hint, bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(labelText: label, hintText: hint),
        validator: required
            ? (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(vendorAuthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Farmácia'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
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
                // Aviso de aprovação
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Após o cadastro, sua conta passará por aprovação. Você será notificado quando estiver liberada.',
                          style: TextStyle(color: Colors.blue, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text('Dados da Farmácia',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                        color: AppTheme.textDark)),
                const SizedBox(height: 12),

                _field(_pharmacyNameCtrl, 'Nome da farmácia'),
                _field(_ownerNameCtrl,    'Nome do responsável'),
                _field(_phoneCtrl, 'Telefone', type: TextInputType.phone,
                    hint: '(11) 99999-9999'),
                _field(_addressCtrl, 'Endereço completo',
                    hint: 'Rua, número, bairro'),

                Row(
                  children: [
                    Expanded(child: _field(_cityCtrl,  'Cidade')),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 80,
                      child: _field(_stateCtrl, 'UF',
                          hint: 'SP'),
                    ),
                  ],
                ),
                _field(_zipCodeCtrl, 'CEP', type: TextInputType.number,
                    hint: '00000-000'),

                const SizedBox(height: 8),
                const Text('Acesso',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                        color: AppTheme.textDark)),
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                    decoration: const InputDecoration(
                      labelText: 'E-mail de acesso',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Informe o e-mail';
                      if (!v.contains('@')) return 'E-mail inválido';
                      return null;
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Informe a senha';
                      if (v.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _confirmPasswordCtrl,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirmar senha',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (v) =>
                        v != _passwordCtrl.text ? 'Senhas não conferem' : null,
                  ),
                ),

                if (auth.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(auth.errorMessage!,
                        style: TextStyle(color: Colors.red.shade700)),
                  ),

                ElevatedButton(
                  onPressed: auth.isLoading ? null : _register,
                  child: auth.isLoading
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Cadastrar farmácia'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
