// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:ym_fluttertoast/fluttertoast.dart';

class ToastContext extends StatefulWidget {
  const ToastContext({super.key});

  @override
  State<ToastContext> createState() => _ToastContextState();
}

class _ToastContextState extends State<ToastContext> {
  final FToast fToast = FToast();
  final Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(25)),
      color: Colors.greenAccent,
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.check),
        SizedBox(width: 12),
        Text('This is a custom toast'),
      ],
    ),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fToast.init(context);
  }

  void _showToast() {
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }

  void _showBuilderToast() {
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.TOP_LEFT,
      toastDuration: const Duration(seconds: 2),
      positionedToastBuilder: (context, child, gravity) {
        return Positioned(top: 16, left: 16, child: child);
      },
    );
  }

  void _showToastCancel() {
    final Widget toastWithButton = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(25)),
        color: Colors.redAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Flexible(
            child: Text(
              'This is a custom toast with a close button.',
              style: TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            color: Colors.white,
            onPressed: fToast.removeCustomToast,
          ),
        ],
      ),
    );
    fToast.showToast(
      child: toastWithButton,
      gravity: ToastGravity.CENTER,
      toastDuration: const Duration(seconds: 50),
    );
  }

  void _queueToasts() {
    for (final ToastGravity gravity in <ToastGravity>[
      ToastGravity.CENTER,
      ToastGravity.BOTTOM,
      ToastGravity.TOP,
      ToastGravity.CENTER,
      ToastGravity.TOP,
    ]) {
      fToast.showToast(
        child: toast,
        gravity: gravity,
        toastDuration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom toasts')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _ExampleButton(label: 'Show custom toast', onPressed: _showToast),
          _ExampleButton(
            label: 'Show custom toast via builder',
            onPressed: _showBuilderToast,
          ),
          _ExampleButton(
            label: 'Custom toast with close button',
            onPressed: _showToastCancel,
          ),
          _ExampleButton(label: 'Queue toasts', onPressed: _queueToasts),
          _ExampleButton(
            label: 'Cancel visible toast',
            onPressed: fToast.removeCustomToast,
          ),
          _ExampleButton(
            label: 'Remove queued toasts',
            onPressed: fToast.removeQueuedCustomToasts,
          ),
        ],
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
