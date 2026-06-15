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
          path: RouteNames.dashboard,
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: RouteNames.newForm,
          name: 'newForm',
          builder: (context, state) => const SurveyFormScreen(), // ficheId = null
        ),
        GoRoute(
          path: RouteNames.editForm,
          name: 'editForm',
          builder: (context, state) {
            final idStr = state.pathParameters['id'];
            final ficheId = int.tryParse(idStr ?? '');
            return SurveyFormScreen(ficheId: ficheId);
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 20),
              Text('Erreur 404',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              Text('Page non trouvée',
                  style: Theme.of(context).textTheme.bodyLarge),
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