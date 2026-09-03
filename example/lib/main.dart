import 'package:fluttertoast_example/toast_context.dart';
import 'package:fluttertoast_example/toast_no_context.dart';
import 'package:ym_fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    MaterialApp(
      builder: FToastBuilder(),
      home: const MyApp(),
      navigatorKey: navigatorKey,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Toast')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const ToastNoContext(),
                  ),
                );
              },
              child: const Text('Flutter Toast No Context'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const ToastContext(),
                  ),
                );
              },
              child: const Text('Flutter Toast Context'),
            ),
          ],
        ),
      ),
    );
  }
}
