# YM FlutterToast

[![pub package](https://img.shields.io/pub/v/ym_fluttertoast.svg)](https://pub.dev/packages/ym_fluttertoast)
[![pub points](https://img.shields.io/pub/points/ym_fluttertoast)](https://pub.dev/packages/ym_fluttertoast/score)

Simple platform toasts and fully-customizable Flutter overlay toasts.

Version `1.0.0` targets Flutter `3.47.0+`, Dart `3.13.0+`, Android API 24+, and iOS 15+. The platform toast API supports Android, iOS, and web. The custom `FToast` overlay works anywhere Flutter can render an overlay.

## Install

```yaml
dependencies:
  ym_fluttertoast: ^1.0.0
```

Then import the package:

```dart
import 'package:ym_fluttertoast/fluttertoast.dart';
```

## Platform toast

Use `Fluttertoast` when you want a one-line, native/browser toast without a `BuildContext`:

```dart
await Fluttertoast.showToast(
  msg: 'Saved successfully',
  toastLength: Toast.LENGTH_SHORT,
  gravity: ToastGravity.BOTTOM,
  timeInSecForIosWeb: 2,
  backgroundColor: Colors.green,
  textColor: Colors.white,
  fontSize: 16,
);
```

Hide the current platform toast:

```dart
await Fluttertoast.cancel();
```

| Parameter | Description | Default |
| --- | --- | --- |
| `msg` | Required toast message. | — |
| `toastLength` | `Toast.LENGTH_SHORT` or `Toast.LENGTH_LONG`; Android only. | Short |
| `gravity` | `TOP`, `CENTER`, or `BOTTOM` for platform toasts. | Bottom |
| `timeInSecForIosWeb` | Duration in seconds for iOS and web. | `1` |
| `backgroundColor` | Android/iOS background color. | Platform default |
| `textColor` | Android/iOS text color. | Platform default |
| `fontSize` | Text size in logical pixels where supported. | Platform default |
| `fontAsset` | Asset path to a font file in the host app. | Platform default |
| `webShowClose` | Display a close button on web. | `false` |
| `webBgColor` | CSS color or gradient for web. | Green gradient |
| `webPosition` | `left`, `center`, or `right` for web. | `right` |

### Android

Android 11 and newer restrict custom system toast views. On those versions the plugin uses the OS-rendered toast, so custom background, text color, font size, and font asset styling may be ignored. Custom styling remains available on older Android versions.

### Web

Toastify.js and its stylesheet are loaded from the package assets once. Message text is inserted as a DOM text node, so user-provided messages are not interpreted as JavaScript or HTML.

## Custom Flutter overlay toast

Use `FToast` when you need arbitrary Flutter widgets, queueing, custom positioning, or a dismiss button. Add its overlay to the app:

```dart
MaterialApp(
  builder: FToastBuilder(),
  home: const MyHomePage(),
);
```

Initialize it with a context below the app overlay:

```dart
late final FToast fToast;

@override
void initState() {
  super.initState();
  fToast = FToast().init(context);
}
```

Show a custom widget:

```dart
fToast.showToast(
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.green,
      borderRadius: BorderRadius.circular(24),
    ),
    child: const Text('This is a custom toast'),
  ),
  gravity: ToastGravity.BOTTOM,
  toastDuration: const Duration(seconds: 2),
);
```

Toasts are queued automatically. Remove the visible toast or clear all queued toasts:

```dart
fToast.removeCustomToast();
fToast.removeQueuedCustomToasts();
```

Use `isDismissible: true` to remove a toast when it is tapped. For complete positioning control, provide a builder:

```dart
fToast.showToast(
  child: const Text('Top-left toast'),
  positionedToastBuilder: (context, child, gravity) {
    return Positioned(top: 24, left: 24, child: child);
  },
);
```

The custom overlay options are:

| Parameter | Description | Default |
| --- | --- | --- |
| `child` | Required Flutter widget. | — |
| `toastDuration` | Time before fade-out starts. | 2 seconds |
| `fadeDuration` | Fade animation duration. | 350 ms |
| `gravity` | Built-in position. | Bottom |
| `positionedToastBuilder` | Custom `Positioned` builder. | `null` |
| `ignorePointer` | Let touches pass through the toast. | `false` |
| `isDismissible` | Remove the visible toast on tap. | `false` |

See the [example](example) app for platform and custom-toast demonstrations.

## Release notes

See [CHANGELOG.md](CHANGELOG.md) for upgrade notes and the [contribution guide](CONTRIBUTING.md) for development workflow.
