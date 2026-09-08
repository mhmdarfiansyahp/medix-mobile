import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medix_fe/main.dart';

void main() {
  testWidgets('Medix login screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MedixApp());
    expect(find.text('Medix'), findsOneWidget);
    expect(find.text('Pharmacy Management System'), findsOneWidget);
    expect(find.byIcon(Icons.medication), findsOneWidget);
  });
}