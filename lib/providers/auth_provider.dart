import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vendor_model.dart';

class VendorAuthState {
  final VendorModel? vendor;
  final bool isLoading;
  final String? errorMessage;

  const VendorAuthState({
    this.vendor,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isLoggedIn   => vendor != null;
  bool get isApproved   => vendor?.isApproved ?? false;
  bool get isPending    => isLoggedIn && !isApproved;

  VendorAuthState copyWith({
    VendorModel? vendor,
    bool clearVendor = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) => VendorAuthState(
    vendor:       clearVendor ? null : (vendor ?? this.vendor),
    isLoading:    isLoading   ?? this.isLoading,
    errorMessage: clearError  ? null : (errorMessage ?? this.errorMessage),
  );
}

class VendorAuthNotifier extends Notifier<VendorAuthState> {
  final _auth      = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _ignoreNextAuthChange = false;

  @override
  VendorAuthState build() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    return const VendorAuthState(isLoading: true);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (_ignoreNextAuthChange) {
      _ignoreNextAuthChange = false;
      return;
    }
    if (user == null) {
      state = const VendorAuthState();
      return;
    }
    // Só carrega se ainda não tiver vendor no estado
    if (state.vendor == null) {
      await _loadVendor(user.uid);
    }
  }

  Future<void> _loadVendor(String uid) async {
    try {
      final doc = await _firestore.collection('pharmacies').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        state = VendorAuthState(
          vendor: VendorModel.fromMap({'id': uid, ...doc.data()!}),
        );
      } else {
        state = const VendorAuthState();
      }
    } catch (e) {
      _log('Erro ao carregar farmácia: $e');
      state = const VendorAuthState();
    }
  }

  // ── Cadastro da Farmácia ──────────────────────────────────────────────────
  Future<bool> register({
    required String pharmacyName,
    required String ownerName,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String city,
    required String state,
    required String zipCode,
  }) async {
    this.state = this.state.copyWith(isLoading: true, clearError: true);

    if (pharmacyName.isEmpty || email.isEmpty || password.isEmpty) {
      this.state = this.state.copyWith(
          isLoading: false, errorMessage: 'Preencha todos os campos');
      return false;
    }
    if (password.length < 6) {
      this.state = this.state.copyWith(
          isLoading: false,
          errorMessage: 'Senha deve ter pelo menos 6 caracteres');
      return false;
    }

    try {
      _ignoreNextAuthChange = true;

      final credential = await _auth.createUserWithEmailAndPassword(
        email:    email.trim().toLowerCase(),
        password: password,
      );

      final uid = credential.user!.uid;

      final vendor = VendorModel(
        id:           uid,
        name:         pharmacyName.trim(),
        ownerName:    ownerName.trim(),
        email:        email.trim().toLowerCase(),
        phone:        phone.trim(),
        address:      address.trim(),
        city:         city.trim(),
        state:        state.trim(),
        zipCode:      zipCode.trim(),
        openingHours: '',
        hasDelivery:  false,
        isApproved:   false, // aguarda aprovação do admin
        isActive:     true,
        createdAt:    DateTime.now(),
      );

      await _firestore.collection('pharmacies').doc(uid).set(vendor.toMap());

      _log('Cadastro OK — aguardando aprovação: ${vendor.email}');
      this.state = VendorAuthState(vendor: vendor);
      return true;

    } on FirebaseAuthException catch (e) {
      _ignoreNextAuthChange = false;
      this.state = this.state.copyWith(
          isLoading: false,
          errorMessage: _translateError(e.code));
      return false;
    } catch (e) {
      _ignoreNextAuthChange = false;
      _log('Erro no cadastro: $e');
      this.state = this.state.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao cadastrar. Tente novamente.');
      return false;
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(
          isLoading: false, errorMessage: 'Preencha e-mail e senha');
      return false;
    }

    try {
      _ignoreNextAuthChange = true;

      final credential = await _auth.signInWithEmailAndPassword(
        email:    email.trim().toLowerCase(),
        password: password,
      );

      await _loadVendor(credential.user!.uid);
      return true;

    } on FirebaseAuthException catch (e) {
      _ignoreNextAuthChange = false;
      state = state.copyWith(
          isLoading: false, errorMessage: _translateError(e.code));
      return false;
    } catch (e) {
      _ignoreNextAuthChange = false;
      state = state.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao fazer login. Tente novamente.');
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
    state = const VendorAuthState();
  }

  // ── Verifica se foi aprovado ──────────────────────────────────────────────
  Future<void> refreshVendorStatus() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _loadVendor(uid);
  }

  String _translateError(String code) {
    switch (code) {
      case 'email-already-in-use':  return 'Este e-mail já está cadastrado.';
      case 'invalid-email':         return 'E-mail inválido.';
      case 'weak-password':         return 'Senha muito fraca.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':    return 'E-mail ou senha incorretos.';
      case 'too-many-requests':     return 'Muitas tentativas. Aguarde.';
      case 'network-request-failed':return 'Sem conexão com a internet.';
      default:                      return 'Erro ($code). Tente novamente.';
    }
  }

  void _log(String msg) {
    if (kDebugMode) debugPrint('[VendorAuth] $msg');
  }
}

final vendorAuthProvider = NotifierProvider<VendorAuthNotifier, VendorAuthState>(
  VendorAuthNotifier.new,
);
