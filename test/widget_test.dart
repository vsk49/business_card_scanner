import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:business_card_scanner/main.dart';

void main() {
  testWidgets('Home page shows title, description, and camera button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BusinessCardScannerApp());

    expect(find.text('Home'), findsOneWidget);
    expect(
      find.text('Want a faster way to save business contacts? Here you are!'),
      findsOneWidget,
    );
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.camera), findsOneWidget);
  });
}
