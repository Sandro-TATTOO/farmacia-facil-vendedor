import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../app/theme.dart';

// Tela exibida quando o vendedor cadastrou mas ainda não foi aprovado
class PendingScreen extends ConsumerWidget {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(vendorAuthProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.hourglass_top_rounded,
                    size: 50, color: Colors.orange.shade700),
              ),
              const SizedBox(height: 24),
              const Text(
                'Aguardando aprovação',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark),
              ),
              const SizedBox(height: 12),
              Text(
                'Sua farmácia ${auth.vendor?.name ?? ''} foi cadastrada com sucesso!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textGrey, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nossa equipe irá analisar e aprovar sua conta em breve. Você receberá uma confirmação por e-mail.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textGrey),
              ),
              const SizedBox(height: 36),

              // Botão para verificar se já foi aprovado
              ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(vendorAuthProvider.notifier)
                      .refreshVendorStatus();
                  if (context.mounted) {
                    final updated = ref.read(vendorAuthProvider);
                    if (updated.isApproved) {
                      context.go('/dashboard');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ainda aguardando aprovação...'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Verificar status'),
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: () async {
                  await ref.read(vendorAuthProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
                child: const Text('Sair da conta',
                    style: TextStyle(color: AppTheme.textGrey)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
