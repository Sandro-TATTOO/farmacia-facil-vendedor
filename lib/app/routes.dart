import 'package:go_router/go_router.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/pending_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/orders/order_detail_screen.dart';
import '../screens/products/products_screen.dart';
import '../screens/products/add_edit_product_screen.dart';
import '../screens/pharmacy/pharmacy_screen.dart';
import '../screens/shared/main_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (c, s) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (c, s) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (c, s) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/pending',
      builder: (c, s) => const PendingScreen(),
    ),

    // Rotas protegidas com barra de navegação
    ShellRoute(
      builder: (c, s, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (c, s) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/orders',
          builder: (c, s) => const OrdersScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (c, s) => OrderDetailScreen(
                orderId: s.pathParameters['id'] ?? '',
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/products',
          builder: (c, s) => const ProductsScreen(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (c, s) => const AddEditProductScreen(),
            ),
            GoRoute(
              path: 'edit/:id',
              builder: (c, s) => AddEditProductScreen(
                productId: s.pathParameters['id'],
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/pharmacy',
          builder: (c, s) => const PharmacyScreen(),
        ),
      ],
    ),
  ],
);
