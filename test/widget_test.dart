import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:fuel_tracker_app/main.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App starts and displays home page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FuelTrackerApp());

    // Verify that our app has the correct title
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('My Statistics'),
      ),
      findsOneWidget,
    );
  });
}
