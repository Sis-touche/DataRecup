import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recupdata/Features/Dashboard/Dashboardscreen.dart';
import 'package:recupdata/Features/Form/fromrecup.dart';
import 'package:recupdata/Features/Launch/launchScreen.dart';
import 'package:recupdata/Root/root_name.dart';

class AppRouter {
  late final GoRouter router;

  AppRouter() {
    router = _createRouter();
  }

  GoRouter _createRouter() {
    return GoRouter(
      initialLocation: RouteNames.home,
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: RouteNames.home,
          name: 'home',
          builder: (context, state) => const LaunchScreen(),
        ),
        GoRoute(
          path: RouteNames.register,
          name: 'register',
          builder: (context, state) => const SurveyFormScreen(),
        ),
        GoRoute(
          path: RouteNames.dashboard,
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        // Ajoute les autres routes plus tard (dashboard, etc.)
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 20),
              Text('Erreur 404', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              Text('Page non trouvée', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go(RouteNames.home),
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}