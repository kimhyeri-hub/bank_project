import 'dart:typed_data';
import 'package:flutter/widgets.dart';

/// 네이티브(Android/iOS/Desktop)에서는 사용하지 않으므로 빈 위젯을 반환합니다.
Widget buildWebPdfPicker({
  required void Function(String name, Uint8List bytes) onFilePicked,
  required void Function(String error) onError,
}) =>
    const SizedBox.shrink();
