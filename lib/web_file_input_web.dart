import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'dart:ui_web' as ui_web;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void Function(Uint8List bytes, String name) _logoCallback = (_, __) {};
void Function(Uint8List bytes, String name) _gallerySingleCallback = (_, __) {};
void Function(List<Uint8List> bytes, List<String> names) _galleryMultiCallback = (_, __) {};

bool _registered = false;

void registerWebFileInputs() {
  if (_registered || !kIsWeb) return;
  _registered = true;

  ui_web.platformViewRegistry.registerViewFactory(
    'logo-file-input',
    (int viewId) {
      final input = html.FileUploadInputElement()
        ..accept = 'image/*'
        ..multiple = false
        ..style.position = 'absolute'
        ..style.left = '0'
        ..style.top = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.opacity = '0'
        ..style.cursor = 'pointer';
      input.onChange.listen((_) async {
        final files = input.files;
        input.value = '';
        if (files == null || files.isEmpty) return;
        final file = files.first;
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        await reader.onLoad.first;
        final bytes = reader.result;
        if (bytes is! Uint8List) return;
        _logoCallback(bytes, file.name);
      });
      return input;
    },
  );

  ui_web.platformViewRegistry.registerViewFactory(
    'gallery-single-file-input',
    (int viewId) {
      final input = html.FileUploadInputElement()
        ..accept = 'image/*'
        ..multiple = false
        ..style.position = 'absolute'
        ..style.left = '0'
        ..style.top = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.opacity = '0'
        ..style.cursor = 'pointer';
      input.onChange.listen((_) async {
        final files = input.files;
        input.value = '';
        if (files == null || files.isEmpty) return;
        final file = files.first;
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        await reader.onLoad.first;
        final bytes = reader.result;
        if (bytes is! Uint8List) return;
        _gallerySingleCallback(bytes, file.name);
      });
      return input;
    },
  );

  ui_web.platformViewRegistry.registerViewFactory(
    'gallery-multi-file-input',
    (int viewId) {
      final input = html.FileUploadInputElement()
        ..accept = 'image/*'
        ..multiple = true
        ..style.position = 'absolute'
        ..style.left = '0'
        ..style.top = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.opacity = '0'
        ..style.cursor = 'pointer';
      input.onChange.listen((_) async {
        final files = input.files;
        input.value = '';
        if (files == null || files.isEmpty) return;
        final bl = <Uint8List>[];
        final nl = <String>[];
        for (final file in files) {
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);
          await reader.onLoad.first;
          final bytes = reader.result;
          if (bytes is! Uint8List) continue;
          bl.add(bytes);
          nl.add(file.name);
        }
        if (bl.isNotEmpty) _galleryMultiCallback(bl, nl);
      });
      return input;
    },
  );
}

void setLogoFileCallback(void Function(Uint8List bytes, String name)? cb) {
  _logoCallback = cb ?? (_, __) {};
}

void setGallerySingleFileCallback(void Function(Uint8List bytes, String name)? cb) {
  _gallerySingleCallback = cb ?? (_, __) {};
}

void setGalleryMultiFileCallback(void Function(List<Uint8List> bytes, List<String> names)? cb) {
  _galleryMultiCallback = cb ?? (_, __) {};
}

Widget buildLogoFileInput({required Widget child, required bool enabled}) {
  if (!kIsWeb) return child;
  return Stack(
    alignment: Alignment.center,
    children: [
      child,
      if (enabled)
        Positioned.fill(
          child: HtmlElementView(viewType: 'logo-file-input'),
        ),
    ],
  );
}

Widget buildGallerySingleFileInput({required Widget child, required bool enabled}) {
  if (!kIsWeb) return child;
  return Stack(
    alignment: Alignment.center,
    children: [
      child,
      if (enabled)
        Positioned.fill(
          child: HtmlElementView(viewType: 'gallery-single-file-input'),
        ),
    ],
  );
}

Widget buildGalleryMultiFileInput({required Widget child, required bool enabled}) {
  if (!kIsWeb) return child;
  return Stack(
    alignment: Alignment.center,
    children: [
      child,
      if (enabled)
        Positioned.fill(
          child: HtmlElementView(viewType: 'gallery-multi-file-input'),
        ),
    ],
  );
}
