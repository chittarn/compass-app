import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:compass_app/features/compass/presentation/compass_screen.dart';

void main() {
  testWidgets('CompassScreen renders with default UI', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CompassScreen(),
        ),
      ),
    );

    // Verify basic screen components are present
    expect(find.byType(CompassScreen), findsOneWidget);
    expect(find.text('COMPASS'), findsOneWidget);
  });
}
