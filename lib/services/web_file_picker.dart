/// 웹에서는 실제 브라우저 `<input type="file">` 엘리먼트를 오버레이해 파일을 선택하고,
/// 그 외 플랫폼에서는 아무것도 그리지 않는 위젯을 제공합니다.
library;

export 'web_file_picker_stub.dart'
    if (dart.library.js_interop) 'web_file_picker_web.dart';
