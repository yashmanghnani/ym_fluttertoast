import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Signature for custom gravity handling for a toast.
typedef ToastPositionMapping = Widget? Function(
  Widget child,
  ToastGravity? gravity,
);

/// Toast duration constants used by the platform toast implementation.
enum Toast {
  /// Show a short toast (Android-controlled duration).
  LENGTH_SHORT,

  /// Show a long toast (Android-controlled duration).
  LENGTH_LONG,
}

/// Position of a toast on the screen.
enum ToastGravity {
  TOP,
  BOTTOM,
  CENTER,
  TOP_LEFT,
  TOP_RIGHT,
  BOTTOM_LEFT,
  BOTTOM_RIGHT,
  CENTER_LEFT,
  CENTER_RIGHT,
  SNACKBAR,
  NONE,
}

/// Platform toast API for Android, iOS, and web.
class Fluttertoast {
  /// Method channel shared by the platform implementations.
  static const MethodChannel _channel = MethodChannel(
    'PonnamKarthik/fluttertoast',
  );

  /// Hide the currently visible platform toast.
  static Future<bool?> cancel() => _channel.invokeMethod<bool>('cancel');

  /// Show [msg] using the platform toast implementation.
  ///
  /// Android supports [toastLength], while iOS and web use
  /// [timeInSecForIosWeb]. Custom styling is best supported on web and on
  /// Android versions before Android 11, where custom system toast views are
  /// restricted by the OS.
  static Future<bool?> showToast({
    required String msg,
    Toast? toastLength,
    int timeInSecForIosWeb = 1,
    double? fontSize,
    String? fontAsset,
    ToastGravity? gravity,
    Color? backgroundColor,
    Color? textColor,
    bool webShowClose = false,
    String webBgColor = 'linear-gradient(to right, #00b09b, #96c93d)',
    String webPosition = 'right',
  }) {
    final String length = toastLength == Toast.LENGTH_LONG ? 'long' : 'short';
    final String platformGravity = switch (gravity) {
      ToastGravity.TOP => 'top',
      ToastGravity.CENTER => 'center',
      _ => 'bottom',
    };

    final Color? resolvedBackground =
        backgroundColor ??
        (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
            ? Colors.black
            : null);
    final Color? resolvedText =
        textColor ??
        (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
            ? Colors.white
            : null);

    final Map<String, Object?> arguments = <String, Object?>{
      'msg': msg,
      'length': length,
      'time': timeInSecForIosWeb,
      'gravity': platformGravity,
      'bgcolor': resolvedBackground?.toARGB32(),
      'iosBgcolor': resolvedBackground?.toARGB32(),
      'textcolor': resolvedText?.toARGB32(),
      'iosTextcolor': resolvedText?.toARGB32(),
      'fontSize': fontSize,
      'fontAsset': fontAsset,
      'webShowClose': webShowClose,
      'webBgColor': webBgColor,
      'webPosition': webPosition,
    };

    return _channel.invokeMethod<bool>('showToast', arguments);
  }
}

/// Signature for positioning a custom toast widget.
typedef PositionedToastBuilder = Widget Function(
  BuildContext context,
  Widget child,
  ToastGravity? gravity,
);

/// Controller for queued, fully-customizable Flutter overlay toasts.
///
/// The existing factory is intentionally kept as a singleton for backwards
/// compatibility. Call [init] with a context below an [Overlay] before use.
class FToast {
  static final FToast _instance = FToast._internal();

  factory FToast() => _instance;

  FToast._internal();

  BuildContext? context;
  OverlayEntry? _entry;
  final List<_ToastEntry> _overlayQueue = <_ToastEntry>[];
  Timer? _timer;
  Timer? _fadeTimer;

  /// Set the context used to find the overlay.
  FToast init(BuildContext context) {
    _instance.context = context;
    return _instance;
  }

  void _showOverlay() {
    if (_overlayQueue.isEmpty) {
      _entry = null;
      return;
    }

    final BuildContext? toastContext = context;
    if (toastContext == null) {
      removeQueuedCustomToasts();
      throw StateError(
        'Context is null. Call FToast().init(context) before showing a toast.',
      );
    }
    if (!toastContext.mounted) {
      removeQueuedCustomToasts();
      return;
    }

    late final OverlayState overlay;
    try {
      overlay = Overlay.of(toastContext);
    } on FlutterError {
      removeQueuedCustomToasts();
      throw StateError(
        'No Overlay was found. Initialize FToast with a context below an '
        'Overlay, or add FToastBuilder() to MaterialApp.builder.',
      );
    }

    final _ToastEntry toastEntry = _overlayQueue.removeAt(0);
    _entry = toastEntry.entry;
    overlay.insert(toastEntry.entry);

    _timer = Timer(toastEntry.duration, () {
      _fadeTimer = Timer(toastEntry.fadeDuration, removeCustomToast);
    });
  }

  /// Remove the visible toast and display the next queued toast, if any.
  void removeCustomToast() {
    _timer?.cancel();
    _fadeTimer?.cancel();
    _timer = null;
    _fadeTimer = null;

    final OverlayEntry? entry = _entry;
    _entry = null;
    entry?.remove();
    _showOverlay();
  }

  /// Remove the visible toast and every toast waiting in the queue.
  void removeQueuedCustomToasts() {
    _timer?.cancel();
    _fadeTimer?.cancel();
    _timer = null;
    _fadeTimer = null;
    _overlayQueue.clear();

    final OverlayEntry? entry = _entry;
    _entry = null;
    entry?.remove();
  }

  /// Queue a custom toast widget.
  void showToast({
    required Widget child,
    PositionedToastBuilder? positionedToastBuilder,
    Duration toastDuration = const Duration(seconds: 2),
    ToastGravity? gravity,
    Duration fadeDuration = const Duration(milliseconds: 350),
    bool ignorePointer = false,
    bool isDismissible = false,
  }) {
    final BuildContext? toastContext = context;
    if (toastContext == null) {
      throw StateError(
        'Context is null. Call FToast().init(context) before showing a toast.',
      );
    }
    if (toastDuration.isNegative || fadeDuration.isNegative) {
      throw ArgumentError('Toast durations cannot be negative.');
    }

    ToastGravity? resolvedGravity = gravity;
    if (resolvedGravity == ToastGravity.BOTTOM &&
        toastContext.mounted &&
        MediaQuery.viewInsetsOf(toastContext).bottom != 0) {
      resolvedGravity = ToastGravity.CENTER;
    }

    final Widget toastChild = _ToastStateFul(
      duration: toastDuration,
      fadeDuration: fadeDuration,
      ignorePointer: ignorePointer,
      onDismiss: isDismissible ? removeCustomToast : null,
      child: child,
    );
    final OverlayEntry entry = OverlayEntry(
      builder: (BuildContext overlayContext) {
        final PositionedToastBuilder? builder = positionedToastBuilder;
        if (builder != null) {
          return builder(overlayContext, toastChild, resolvedGravity);
        }
        return _getPositionWidgetBasedOnGravity(
          toastChild,
          resolvedGravity,
          overlayContext,
        );
      },
    );

    _overlayQueue.add(
      _ToastEntry(
        entry: entry,
        duration: toastDuration,
        fadeDuration: fadeDuration,
      ),
    );
    if (_timer == null) {
      _showOverlay();
    }
  }

  Widget _getPositionWidgetBasedOnGravity(
    Widget child,
    ToastGravity? gravity,
    BuildContext buildContext,
  ) {
    switch (gravity) {
      case ToastGravity.TOP:
        return Positioned(top: 100, left: 24, right: 24, child: child);
      case ToastGravity.TOP_LEFT:
        return Positioned(top: 100, left: 24, child: child);
      case ToastGravity.TOP_RIGHT:
        return Positioned(top: 100, right: 24, child: child);
      case ToastGravity.CENTER:
        return Positioned(
          top: 50,
          bottom: 50,
          left: 24,
          right: 24,
          child: child,
        );
      case ToastGravity.CENTER_LEFT:
        return Positioned(top: 50, bottom: 50, left: 24, child: child);
      case ToastGravity.CENTER_RIGHT:
        return Positioned(top: 50, bottom: 50, right: 24, child: child);
      case ToastGravity.BOTTOM_LEFT:
        return Positioned(bottom: 50, left: 24, child: child);
      case ToastGravity.BOTTOM_RIGHT:
        return Positioned(bottom: 50, right: 24, child: child);
      case ToastGravity.SNACKBAR:
        return Positioned(
          bottom: MediaQuery.viewInsetsOf(buildContext).bottom,
          left: 0,
          right: 0,
          child: child,
        );
      case ToastGravity.NONE:
        return Positioned.fill(child: child);
      case ToastGravity.BOTTOM:
      case null:
        return Positioned(bottom: 50, left: 24, right: 24, child: child);
    }
  }
}

/// Add the overlay needed by [FToast] to a [MaterialApp] or [CupertinoApp].
// ignore: non_constant_identifier_names
TransitionBuilder FToastBuilder() {
  return (BuildContext context, Widget? child) =>
      _FToastHolder(child: child ?? const SizedBox.shrink());
}

class _FToastHolder extends StatelessWidget {
  const _FToastHolder({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: <OverlayEntry>[
        OverlayEntry(builder: (BuildContext context) => child),
      ],
    );
  }
}

class _ToastEntry {
  const _ToastEntry({
    required this.entry,
    required this.duration,
    required this.fadeDuration,
  });

  final OverlayEntry entry;
  final Duration duration;
  final Duration fadeDuration;
}

class _ToastStateFul extends StatefulWidget {
  const _ToastStateFul({
    required this.child,
    required this.duration,
    required this.fadeDuration,
    required this.ignorePointer,
    required this.onDismiss,
  });

  final Widget child;
  final Duration duration;
  final Duration fadeDuration;
  final bool ignorePointer;
  final VoidCallback? onDismiss;

  @override
  State<_ToastStateFul> createState() => _ToastStateFulState();
}

class _ToastStateFulState extends State<_ToastStateFul>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.fadeDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
    _timer = Timer(widget.duration, _hide);
  }

  void _hide() {
    if (mounted) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      behavior: HitTestBehavior.translucent,
      child: IgnorePointer(
        ignoring: widget.ignorePointer,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Material(color: Colors.transparent, child: widget.child),
          ),
        ),
      ),
    );
  }
}
