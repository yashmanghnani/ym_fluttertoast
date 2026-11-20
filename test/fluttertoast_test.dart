// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ym_fluttertoast/fluttertoast.dart';

void main() {
  test('encodes colors and forwards platform toast arguments', () async {
    final MethodChannel channel = const MethodChannel(
      'PonnamKarthik/fluttertoast',
    );
    MethodCall? receivedCall;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          receivedCall = call;
          return true;
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    final bool? result = await Fluttertoast.showToast(
      msg: 'Hello',
      gravity: ToastGravity.TOP,
      backgroundColor: const Color(0x80112233),
      textColor: Colors.white,
      webPosition: 'center',
    );

    expect(result, isTrue);
    expect(receivedCall?.method, 'showToast');
    final Map<Object?, Object?> arguments = Map<Object?, Object?>.from(
      receivedCall!.arguments as Map,
    );
    expect(arguments['msg'], 'Hello');
    expect(arguments['gravity'], 'top');
    expect(arguments['bgcolor'], 0x80112233);
    expect(arguments['textcolor'], Colors.white.toARGB32());
    expect(arguments['webPosition'], 'center');
  });

  testWidgets('renders and removes a custom toast', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: FToastBuilder(),
        home: const Scaffold(body: SizedBox.shrink()),
      ),
    );

    final FToast toast = FToast().init(tester.element(find.byType(Scaffold)));
    toast.showToast(
      child: const Text('Custom toast'),
      toastDuration: const Duration(minutes: 1),
    );
    await tester.pump();

    expect(find.text('Custom toast'), findsOneWidget);
    toast.removeCustomToast();
    await tester.pump();
    expect(find.text('Custom toast'), findsNothing);
  });
}
