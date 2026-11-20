// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fluttertoast_example/main.dart';
import 'package:ym_fluttertoast/fluttertoast.dart';

void main() {
  testWidgets('renders the example home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(builder: FToastBuilder(), home: const MyApp()),
    );

    expect(find.text('Flutter Toast No Context'), findsOneWidget);
    expect(find.text('Flutter Toast Context'), findsOneWidget);
  });
}
