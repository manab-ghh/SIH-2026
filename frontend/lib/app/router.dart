import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/catalog/catalog_result_screen.dart';
import '../features/catalog/voice_catalog_screen.dart';
import '../features/chatbot/chatbot_screen.dart';
import '../features/home/home_screen.dart';
import '../features/image_studio/image_studio_screen.dart';
import '../features/marketplace/marketplace_dashboard_screen.dart';
import '../features/marketplace/marketplace_publish_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/orders/order_detail_screen.dart';
import '../features/orders/orders_screen.dart';
import '../features/pricing/smart_pricing_screen.dart';
import '../features/products/add_product_hub_screen.dart';
import '../features/products/product_detail_screen.dart';
import '../features/products/product_form_screen.dart';
import '../features/products/product_list_screen.dart';
import '../features/products/product_preview_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/search/visual_search_screen.dart';
import '../features/splash/splash_screen.dart';
import 'theme/app_colors.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Splash & Onboarding
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // Main App Shell with Bottom Navigation Bar
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar:
              _AppBottomNavigationBar(currentLocation: state.uri.path),
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) => const ProductListScreen(),
        ),
        GoRoute(
          path: '/visual-search',
          builder: (context, state) => const VisualSearchScreen(),
        ),
        GoRoute(
          path: '/orders',
          builder: (context, state) => const OrdersScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),

    // Product & AI Feature Sub-Screens
    GoRoute(
      path: '/add-product-hub',
      builder: (context, state) => const AddProductHubScreen(),
    ),
    GoRoute(
      path: '/products/new',
      builder: (context, state) => const AddProductHubScreen(),
    ),
    GoRoute(
      path: '/product-form',
      builder: (context, state) {
        final id = state.uri.queryParameters['id'];
        return ProductFormScreen(
            productId: id, queryParams: state.uri.queryParameters);
      },
    ),
    GoRoute(
      path: '/product-preview/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ProductPreviewScreen(productId: id);
      },
    ),
    GoRoute(
      path: '/product-detail/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ProductDetailScreen(productId: id);
      },
    ),
    GoRoute(
      path: '/image-studio',
      builder: (context, state) {
        final path = state.uri.queryParameters['path'] ??
            'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&q=80&w=800';
        return ImageStudioScreen(imagePath: path);
      },
    ),
    GoRoute(
      path: '/voice-catalog',
      builder: (context, state) => const VoiceCatalogScreen(),
    ),
    GoRoute(
      path: '/catalog-result',
      builder: (context, state) => const CatalogResultScreen(),
    ),
    GoRoute(
      path: '/smart-pricing',
      builder: (context, state) =>
          SmartPricingScreen(initialData: state.uri.queryParameters),
    ),
    GoRoute(
      path: '/marketplace-publish/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return MarketplacePublishScreen(productId: id);
      },
    ),
    GoRoute(
      path: '/order-detail/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return OrderDetailScreen(orderId: id);
      },
    ),
    GoRoute(
      path: '/marketplace-dashboard',
      builder: (context, state) => const MarketplaceDashboardScreen(),
    ),
    GoRoute(
      path: '/chatbot',
      builder: (context, state) => const ChatbotScreen(),
    ),
  ],
);

class _AppBottomNavigationBar extends StatelessWidget {
  final String currentLocation;

  const _AppBottomNavigationBar({required this.currentLocation});

  int _calculateSelectedIndex() {
    if (currentLocation.startsWith('/home')) return 0;
    if (currentLocation.startsWith('/products')) return 1;
    if (currentLocation.startsWith('/visual-search')) return 2;
    if (currentLocation.startsWith('/orders')) return 3;
    if (currentLocation.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex();

    return NavigationBar(
      selectedIndex: selectedIndex,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primaryContainer,
      surfaceTintColor: Colors.transparent,
      elevation: 4,
      height: 65,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/products');
            break;
          case 2:
            context.go('/visual-search');
            break;
          case 3:
            context.go('/orders');
            break;
          case 4:
            context.go('/profile');
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon:
              Icon(Icons.inventory_2_rounded, color: AppColors.primary),
          label: 'Products',
        ),
        NavigationDestination(
          icon: Icon(Icons.image_search_outlined),
          selectedIcon:
              Icon(Icons.image_search_rounded, color: AppColors.primary),
          label: 'Search',
        ),
        NavigationDestination(
          icon: Icon(Icons.shopping_bag_outlined),
          selectedIcon:
              Icon(Icons.shopping_bag_rounded, color: AppColors.primary),
          label: 'Orders',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
          label: 'Profile',
        ),
      ],
    );
  }
}
