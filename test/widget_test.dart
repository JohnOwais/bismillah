import 'package:bismillah/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("Test for Bismillah App", (WidgetTester tester) async {
    await tester.pumpWidget(const Bismillah());
    expect(find.byType(Container), findsOneWidget);
  });
}
