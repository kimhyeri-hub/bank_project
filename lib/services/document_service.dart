import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// PDF 파일에서 약관 분석용 텍스트를 추출합니다.
class DocumentService {
  /// PDF 바이트에서 텍스트를 추출합니다. 텍스트가 없는 스캔 PDF 등은 예외를 던집니다.
  static String extractPdfText(Uint8List bytes) {
    final document = PdfDocument(inputBytes: bytes);
    try {
      final text = PdfTextExtractor(document).extractText();
      final trimmed = text.trim();
      if (trimmed.isEmpty) {
        throw Exception('PDF에서 텍스트를 찾을 수 없습니다. 스캔 이미지 PDF인지 확인해주세요.');
      }
      return trimmed;
    } finally {
      document.dispose();
    }
  }
}
