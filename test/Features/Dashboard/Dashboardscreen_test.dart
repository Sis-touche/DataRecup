
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recupdata/Features/Dashboard/Dashboardscreen.dart';

void main() {
  testWidgets('DashboardScreen shows all the static UI elements', (WidgetTester tester) async {
    // Build the DashboardScreen widget.
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));

    // The screen shows a loading indicator at first.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // After the future in initState completes, the UI should be updated.
    // We use pumpAndSettle to wait for all animations and futures to complete.
    await tester.pumpAndSettle();

    // Now, the loading indicator should be gone.
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Check for the AppBar title
    expect(find.text('Tableau de bord'), findsOneWidget);

    // Check for the two main action cards
    expect(find.text('Remplir le formulaire'), findsOneWidget);
    expect(find.text('Mes fiches'), findsOneWidget);

    // Check for the security section
    expect(find.text('SÉCURITÉ & CONFIDENTIALITÉ'), findsOneWidget);
    expect(find.text('Paramètres de confidentialité'), findsOneWidget);
    expect(find.text('Journal des accès'), findsOneWidget);

    // Check for the footer text
    expect(find.textContaining('TOUTES LES SESSIONS SONT CHIFFRÉES'), findsOneWidget);
  });
}
