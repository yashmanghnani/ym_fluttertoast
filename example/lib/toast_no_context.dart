import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ym_fluttertoast/fluttertoast.dart';

class ToastNoContext extends StatelessWidget {
  const ToastNoContext({super.key});

  void _showLongToast() {
    unawaited(
      Fluttertoast.showToast(
        msg: 'This is a long toast',
        toastLength: Toast.LENGTH_LONG,
        fontSize: 18,
      ),
    );
  }

  void _showWebColoredToast() {
    unawaited(
      Fluttertoast.showToast(
        msg: 'This is a colored toast with a five-second duration',
        toastLength: Toast.LENGTH_SHORT,
        webBgColor: '#e74c3c',
        textColor: Colors.black,
        timeInSecForIosWeb: 5,
      ),
    );
  }

  void _showColoredToast() {
    unawaited(
      Fluttertoast.showToast(
        msg: 'This is a colored short toast',
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      ),
    );
  }

  void _showShortToast() {
    unawaited(
      Fluttertoast.showToast(
        msg: 'This is a short toast',
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
      ),
    );
  }

  void _showTopShortToast() {
    unawaited(
      Fluttertoast.showToast(
        msg: 'This is a top short toast',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
      ),
    );
  }

  void _showCenterShortToast() {
    unawaited(
      Fluttertoast.showToast(
        msg: 'This is a center short toast',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
      ),
    );
  }

  void _cancelToast() {
    unawaited(Fluttertoast.cancel());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Platform toasts')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              _ExampleButton(
                label: 'Show long toast',
                onPressed: _showLongToast,
              ),
              _ExampleButton(
                label: 'Show short toast',
                onPressed: _showShortToast,
              ),
              _ExampleButton(
                label: 'Show center short toast',
                onPressed: _showCenterShortToast,
              ),
              _ExampleButton(
                label: 'Show top short toast',
                onPressed: _showTopShortToast,
              ),
              _ExampleButton(
                label: 'Show colored toast',
                onPressed: _showColoredToast,
              ),
              _ExampleButton(
                label: 'Show web colored toast',
                onPressed: _showWebColoredToast,
              ),
              _ExampleButton(label: 'Cancel toasts', onPressed: _cancelToast),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExampleButton extends StatelessWidget {
  const _ExampleButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ElevatedButton(onPressed: onPressed, child: Text(label)),
    );
  }
}
