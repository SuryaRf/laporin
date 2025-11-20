import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laporin/providers/auth_provider.dart';
import 'package:laporin/providers/onboarding_provider.dart';
import 'package:laporin/screens/splash_screen.dart';
import 'package:laporin/screens/onboarding_screen.dart';
import 'package:laporin/screens/login_screen.dart';
import 'package:laporin/screens/register_screen.dart';
import 'package:laporin/screens/home_screen.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    refreshListenable: authProvider,
    debugLogDiagnostics: false,
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) async {
      final location = state.matchedLocation;
      final isAuthenticated = authProvider.isAuthenticated;
      final isOnboardingComplete = await OnboardingProvider.isOnboardingComplete();

      // Public routes (accessible without authentication)
      final publicRoutes = ['/', '/onboarding', '/login', '/register'];
      final isPublicRoute = publicRoutes.contains(location);

      // Allow splash screen to handle initial navigation
      if (location == '/') {
        return null;
      }

      // If authenticated, redirect away from auth screens
      if (isAuthenticated && (location == '/login' || location == '/register')) {
        return '/home';
      }

      // If authenticated, allow access to protected routes
      if (isAuthenticated) {
        return null;
      }

      // Not authenticated - handle onboarding flow
      if (!isOnboardingComplete && location != '/onboarding') {
        return '/onboarding';
      }

      // Not authenticated - redirect to login for protected routes
      if (!isPublicRoute) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Halaman tidak ditemukan',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Error: ${state.error}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Kembali ke Login'),
            ),
          ],
        ),
      ),
    ),
  );
}
