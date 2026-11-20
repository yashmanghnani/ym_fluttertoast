import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'dart:ui_web' as ui;

const String _channelName = 'PonnamKarthik/fluttertoast';
const String _defaultBackground = 'linear-gradient(to right, #00b09b, #96c93d)';

/// Web implementation backed by the bundled Toastify.js library.
class FluttertoastWebPlugin {
  FluttertoastWebPlugin() {
    _assetsReady = _injectCssAndJSLibraries();
  }

  late final Future<void> _assetsReady;
  final List<JSObject> _activeToasts = <JSObject>[];

  /// Register the method channel used by [Fluttertoast].
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      _channelName,
      const StandardMethodCodec(),
      registrar,
    );
    final FluttertoastWebPlugin instance = FluttertoastWebPlugin();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  /// Handle method calls from the Dart API.
  Future<Object?> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'showToast':
        await _assetsReady;
        _showToast(call.arguments);
        return true;
      case 'cancel':
        _cancelToasts();
        return true;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: "The web implementation does not support '${call.method}'.",
        );
    }
  }

  /// Exposes the idempotent asset-loading future for integrations that need it.
  Future<void> injectCssAndJSLibraries() => _assetsReady;

  Future<void> _injectCssAndJSLibraries() async {
    final web.Element? head = web.document.querySelector('head');
    if (head == null) {
      throw StateError('The browser document has no <head> element.');
    }

    if (web.document.querySelector('#fluttertoast-css') == null) {
      final String cssUrl = ui.assetManager.getAssetUrl(
        'packages/ym_fluttertoast/assets/toastify.css',
      );
      final web.HTMLLinkElement css = web.HTMLLinkElement()
        ..id = 'fluttertoast-css'
        ..rel = 'stylesheet'
        ..href = cssUrl;
      head.append(css);
    }

    if (globalContext.getProperty('Toastify'.toJS) == null) {
      final String jsUrl = ui.assetManager.getAssetUrl(
        'packages/ym_fluttertoast/assets/toastify.js',
      );
      final web.HTMLScriptElement script = web.HTMLScriptElement()
        ..id = 'fluttertoast-js'
        ..async = true
        ..src = jsUrl;
      final Future<void> loaded = script.onLoad.first.then<void>((_) {});
      head.append(script);
      await loaded;
    }
  }

  void _showToast(Object? rawArguments) {
    final Map<Object?, Object?> arguments = rawArguments is Map
        ? Map<Object?, Object?>.from(rawArguments)
        : <Object?, Object?>{};
    final Object? rawMessage = arguments['msg'];
    if (rawMessage is! String) {
      throw PlatformException(
        code: 'invalid_arguments',
        message: 'The toast message must be a String.',
      );
    }

    final String gravity = arguments['gravity'] == 'top' ? 'top' : 'bottom';
    final String position = _validPosition(arguments['webPosition']);
    final String background = arguments['webBgColor'] is String
        ? arguments['webBgColor'] as String
        : _defaultBackground;
    final int seconds = _asInt(arguments['time'], fallback: 1);
    final int duration = seconds <= 0 ? 0 : seconds * 1000;
    final bool showClose = arguments['webShowClose'] == true;

    final web.HTMLDivElement content = web.HTMLDivElement()
      ..textContent = rawMessage;
    final Object? rawTextColor = arguments['textcolor'];
    if (rawTextColor is num) {
      content.style.setProperty('color', _argbToCss(rawTextColor.toInt()));
    }

    final JSAny? toastifyValue = globalContext.getProperty('Toastify'.toJS);
    if (toastifyValue == null || !toastifyValue.isA<JSFunction>()) {
      throw StateError('Toastify.js failed to load.');
    }

    late JSObject toast;
    final JSFunction onRemoved = () {
      _activeToasts.remove(toast);
    }.toJS;
    final JSAny options = <String, Object?>{
      'node': content,
      'gravity': gravity,
      'position': position,
      'duration': duration,
      'close': showClose,
      'backgroundColor': background,
      'callback': onRemoved,
    }.jsify()!;
    final JSAny? rawToast = (toastifyValue as JSFunction).callAsFunction(
      null,
      options,
    );
    if (rawToast == null || !rawToast.isA<JSObject>()) {
      throw StateError('Toastify.js could not create a toast.');
    }
    toast = rawToast as JSObject;
    toast.callMethod<JSAny?>('showToast'.toJS);
    _activeToasts.add(toast);
  }

  void _cancelToasts() {
    for (final JSObject toast in List<JSObject>.of(_activeToasts)) {
      toast.callMethod<JSAny?>('hideToast'.toJS);
    }
    _activeToasts.clear();
  }

  static int _asInt(Object? value, {required int fallback}) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value') ?? fallback;
  }

  static String _validPosition(Object? value) {
    return switch (value) {
      'left' => 'left',
      'center' => 'center',
      _ => 'right',
    };
  }

  static String _argbToCss(int value) {
    final int alpha = (value >> 24) & 0xff;
    final int red = (value >> 16) & 0xff;
    final int green = (value >> 8) & 0xff;
    final int blue = value & 0xff;
    final double opacity = alpha / 255;
    return 'rgba($red, $green, $blue, $opacity)';
  }
}
