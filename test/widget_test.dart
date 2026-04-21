// This file prevents `flutter create .` (used in CI to generate platform
// folders) from overwriting it with a default that references `MyApp`.
// The actual app entry point is WreckerLogixApp in lib/main.dart.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wreckerlogix/main.dart';

void main() {
  testWidgets('WreckerLogixApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WreckerLogixApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
