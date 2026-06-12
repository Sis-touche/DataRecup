import 'package:flutter/material.dart';
import 'package:recupdata/Root/app_root.dart';
import 'package:recupdata/Root/app_router.dart'; // attention : importe le bon fichier

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appRouter = AppRouter();
  runApp(DataRecup(appRouter: appRouter));
}

class DataRecup extends StatelessWidget {
  final AppRouter appRouter;
  const DataRecup({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "DataRecup",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primarySwatch: Colors.green,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
      ),
      routerConfig: appRouter.router,
    );
  }
}