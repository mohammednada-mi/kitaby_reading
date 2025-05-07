// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitaby_flutter/main.dart'; // Import your main app file
import 'package:kitaby_flutter/providers/book_provider.dart';
import 'package:kitaby_flutter/providers/challenge_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Mock SharedPreferences

void
main() {
  testWidgets(
    'App starts and displays Home Screen title',
    (
      WidgetTester
      tester,
    ) async {
      // Provide mock data for SharedPreferences if your providers depend on it during init
      SharedPreferences.setMockInitialValues(
        {},
      ); // Mock empty storage

      // Build our app and trigger a frame.
      // Wrap with providers needed at the root
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create:
                  (
                    _,
                  ) =>
                      BookProvider(),
            ),
            ChangeNotifierProvider(
              create:
                  (
                    _,
                  ) =>
                      ChallengeProvider(),
            ),
          ],
          child:
              const KitabyApp(), // Use your main App widget
        ),
      );

      // Wait for the app to settle
      await tester.pumpAndSettle();

      // Verify that the home screen title ('كتابي') is present.
      expect(
        find.text(
          'كتابي',
        ),
        findsOneWidget,
      ); // Check AppBar title
      // expect(find.text('التحدي النشط'), findsOneWidget); // Check for a known widget on the home screen

      // Example: Verify drawer icon is present
      expect(
        find.byIcon(
          Icons.menu,
        ),
        findsOneWidget,
      );

      // Example: Tap the drawer icon and verify drawer opens (if applicable)
      // await tester.tap(find.byIcon(Icons.menu));
      // await tester.pumpAndSettle(); // Wait for drawer animation
      // expect(find.text('التصنيفات'), findsOneWidget); // Check for a drawer item
    },
  );
}
