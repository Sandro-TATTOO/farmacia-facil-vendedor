// Configurações do Firebase para o app Vendedor
// Usa o mesmo projeto Firebase do app Usuário (farmacia-facil-b980c)
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.windows:
        return web;
      default:
        return web;
    }
  }

  // Web — usado no GitHub Pages e Chrome
  static const FirebaseOptions web = FirebaseOptions(
    apiKey:            'AIzaSyBSisjjD_iwCd4VIfKM4wYrX_O2HlHgQyI',
    appId:             '1:705931971359:web:8a7bb93e5ceb5ab2cabe2a',
    messagingSenderId: '705931971359',
    projectId:         'farmacia-facil-b980c',
    authDomain:        'farmacia-facil-b980c.firebaseapp.com',
    storageBucket:     'farmacia-facil-b980c.firebasestorage.app',
    measurementId:     'G-PJMMZ77FSM',
  );

  // Android — para quando publicar no celular
  static const FirebaseOptions android = FirebaseOptions(
    apiKey:            'AIzaSyCjHj5Z3bClvc_wl-3kUvop6BFmoyarAK8',
    appId:             '1:705931971359:android:d5996baebbb5b662cabe2a',
    messagingSenderId: '705931971359',
    projectId:         'farmacia-facil-b980c',
    storageBucket:     'farmacia-facil-b980c.firebasestorage.app',
  );
}
