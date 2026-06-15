import 'dart:js_interop';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// 실제 `<input type="file">` 엘리먼트를 화면 위에 투명하게 겹쳐, 브라우저가
/// 진짜 사용자 탭으로 인식하도록 합니다. (iOS Safari 등에서 Flutter의 합성
/// 클릭으로는 파일 선택창이 열리지 않는 문제를 회피)
Widget buildWebPdfPicker({
  required void Function(String name, Uint8List bytes) onFilePicked,
  required void Function(String error) onError,
}) {
  return HtmlElementView.fromTagName(
    tagName: 'input',
    onElementCreated: (Object element) {
      final input = element as web.HTMLInputElement;
      input.type = 'file';
      input.accept = '.pdf,application/pdf';
      input.style.width = '100%';
      input.style.height = '100%';
      input.style.opacity = '0';
      input.style.cursor = 'pointer';

      input.addEventListener(
        'change',
        (web.Event event) {
          final files = input.files;
          final file = files?.item(0);
          if (file == null) return;

          final reader = web.FileReader();
          reader.onLoadEnd.listen((web.ProgressEvent _) {
            final result = reader.result;
            if (result == null || !result.isA<JSArrayBuffer>()) {
              onError('파일을 읽을 수 없습니다.');
              return;
            }
            onFilePicked(file.name, (result as JSArrayBuffer).toDart.asUint8List());
            input.value = '';
          });
          reader.readAsArrayBuffer(file);
        }.toJS,
      );
    },
  );
}
