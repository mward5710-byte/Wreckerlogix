// Basic widget test for WreckerLogix.
// This file exists in the repo so that `flutter create .` (used in CI
// to generate platform folders) does not overwrite it with a default
// test that references a non-existent `MyApp` class.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wreckerlogix/main.dart';

void main() {
  testWidgets('WreckerLogixApp renders', (WidgetTester tester) async {
    await tester.pumpWidget(const WreckerLogixApp());
    // App should render without errors and show title in the app bar or body.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
