import 'dart:typed_data';

import 'package:flutter/material.dart';

void registerWebFileInputs() {}

void setLogoFileCallback(void Function(Uint8List bytes, String name)? cb) {}

void setGallerySingleFileCallback(void Function(Uint8List bytes, String name)? cb) {}

void setGalleryMultiFileCallback(void Function(List<Uint8List> bytes, List<String> names)? cb) {}

Widget buildLogoFileInput({required Widget child, required bool enabled}) => child;

Widget buildGallerySingleFileInput({required Widget child, required bool enabled}) => child;

Widget buildGalleryMultiFileInput({required Widget child, required bool enabled}) => child;
