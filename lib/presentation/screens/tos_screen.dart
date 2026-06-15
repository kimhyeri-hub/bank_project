import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_them.dart';
import '../../services/activity_service.dart';
import '../../services/document_service.dart';
import '../../services/tos_service.dart';
import '../../services/claude_service.dart';
import '../../services/history_service.dart';
import '../../services/web_file_picker.dart';

class TosScreen extends StatefulWidget {
  const TosScreen({super.key});

  @override
  State<TosScreen> createState() => _TosScreenState();
}

class _TosScreenState extends State<TosScreen> {
  int _inputMethod = 0; // 0: PDF, 1: URL, 2: 직접입력
  final _urlController = TextEditingController();
  final _textController = TextEditingController();
  String? _uploadedFileName;
  String? _extractedText;
  bool _isExtracting = false;
  bool _isAnalyzing = false;
  TosReport? _report;
  String? _errorMessage;

  static const _exampleUrl =
      'https://raw.githubusercontent.com/kimhyeri-hub/bank_project/main/sample/sample_terms.html';
  static const _exampleText =
      '제3조 (개인정보 제3자 제공) 회사는 수집한 개인정보를 제휴사에 제공할 수 있습니다. '
      '제7조 (서비스 중단) 회사는 사전 공지 없이 서비스를 중단할 수 있습니다. '
      '제12조 (손해배상) 서비스 이용으로 인한 손해는 이용자가 책임을 집니다.';

  Future<void> _pickPdfFile() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );
    } catch (e) {
      setState(() => _errorMessage = '파일 선택 중 오류가 발생했습니다: $e');
      return;
    }
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      setState(() => _errorMessage = '파일을 읽을 수 없습니다.');
      return;
    }

    await _handlePickedFile(file.name, bytes);
  }

  Future<void> _handlePickedFile(String name, Uint8List bytes) async {
    setState(() {
      _uploadedFileName = name;
      _extractedText = null;
      _isExtracting = true;
      _errorMessage = null;
      _report = null;
    });

    try {
      final text = DocumentService.extractPdfText(bytes);
      setState(() {
        _extractedText = text;
        _isExtracting = false;
      });
    } catch (e) {
      setState(() {
        _isExtracting = false;
        _uploadedFileName = null;
        _errorMessage = 'PDF 텍스트 추출에 실패했습니다: $e';
      });
    }
  }

  Future<void> _analyze() async {
    final hasInput = (_inputMethod == 0 && _extractedText != null) ||
        (_inputMethod == 1 && _urlController.text.trim().isNotEmpty) ||
        (_inputMethod == 2 && _textController.text.trim().isNotEmpty);
    if (!hasInput) return;

    setState(() {
      _isAnalyzing = true;
      _report = null;
      _errorMessage = null;
    });

    try {
      String historyInput;
      String? text;
      switch (_inputMethod) {
        case 0:
          text = _extractedText;
          historyInput = '[PDF] $_uploadedFileName';
        case 1:
          historyInput = _urlController.text.trim();
        default:
          text = _textController.text.trim();
          historyInput = text.length > 40 ? '${text.substring(0, 40)}…' : text;
      }

      TosReport report;
      if (_inputMethod == 1) {
        await Future.delayed(const Duration(seconds: 1));
        report = TosService.mockReport();
      } else if (ClaudeService.isConfigured) {
        report = await TosService.analyze(text!);
      } else if (_inputMethod == 0) {
        await Future.delayed(const Duration(seconds: 1));
        report = TosService.pdfDemoReport();
      } else {
        await Future.delayed(const Duration(seconds: 1));
        report = TosService.mockReport();
      }
      await ActivityService.recordTosAnalysis();
      await HistoryService.save(HistoryEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: HistoryType.tos,
        input: historyInput,
        resultSummary: report.summary,
        riskLevel: report.dangerCount > 0 ? 'danger' : report.warningCount > 0 ? 'warning' : 'safe',
        createdAt: DateTime.now(),
      ));
      setState(() {
        _isAnalyzing = false;
        _report = report;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage = '분석 중 오류가 발생했습니다: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('약관 분석'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMethodSelector(),
            const SizedBox(height: 16),
            _buildInputCard(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _analyze,
                icon: _isAnalyzing
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.search, size: 18),
                label: Text(_isAnalyzing ? '분석 중...' : '약관 분석하기'),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_errorMessage!, style: const TextStyle(color: AppTheme.dangerColor, fontSize: 13)),
              ),
            ],
            if (_report != null) ...[
              const SizedBox(height: 24),
              _buildSummaryCard(),
              const SizedBox(height: 16),
              _buildResultList(),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodSelector() {
    final methods = [
      (Icons.picture_as_pdf_outlined, 'PDF 업로드'),
      (Icons.link, 'URL 입력'),
      (Icons.edit_outlined, '직접 입력'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: List.generate(methods.length, (i) {
          final selected = _inputMethod == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _inputMethod = i;
                _report = null;
                _errorMessage = null;
                _uploadedFileName = null;
                _extractedText = null;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Icon(methods[i].$1, size: 18, color: selected ? Colors.white : AppTheme.textSecondary),
                    const SizedBox(height: 4),
                    Text(
                      methods[i].$2,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: [
        _buildPdfInput(),
        _buildUrlInput(),
        _buildTextInput(),
      ][_inputMethod],
    );
  }

  Widget _buildPdfInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PDF 파일 업로드', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 4),
        const Text('은행·카드사 앱에서 다운로드한 약관 PDF를 올려주세요.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 16),
        Stack(
          children: [
            Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (_isExtracting || kIsWeb) ? null : (_) => _pickPdfFile(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: _uploadedFileName != null ? const Color(0xFFE8EAF6) : AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _uploadedFileName != null ? AppTheme.primaryColor : const Color(0xFFD1D5DB),
                    width: _uploadedFileName != null ? 2 : 1,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: _isExtracting
                    ? Column(
                        children: [
                          const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 3, color: AppTheme.primaryColor),
                          ),
                          const SizedBox(height: 10),
                          Text(_uploadedFileName ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                          const SizedBox(height: 4),
                          const Text('PDF에서 텍스트 추출 중...', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                        ],
                      )
                    : _uploadedFileName != null
                        ? Column(
                            children: [
                              const Icon(Icons.picture_as_pdf, color: AppTheme.primaryColor, size: 36),
                              const SizedBox(height: 8),
                              Text(_uploadedFileName!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                              const SizedBox(height: 4),
                              Text(
                                _extractedText != null ? '텍스트 ${_extractedText!.length}자 추출 완료' : '파일이 선택되었습니다',
                                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                              ),
                            ],
                          )
                        : const Column(
                            children: [
                              Icon(Icons.cloud_upload_outlined, color: AppTheme.textSecondary, size: 36),
                              SizedBox(height: 8),
                              Text('여기를 눌러 파일 선택', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                              SizedBox(height: 4),
                              Text('PDF 파일만 지원', style: TextStyle(fontSize: 11, color: Color(0xFFB0B8C1))),
                            ],
                          ),
              ),
            ),
            if (kIsWeb && !_isExtracting)
              Positioned.fill(
                child: buildWebPdfPicker(
                  onFilePicked: (name, bytes) => _handlePickedFile(name, bytes),
                  onError: (error) => setState(() => _errorMessage = error),
                ),
              ),
          ],
        ),
        if (_uploadedFileName != null && !_isExtracting) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() {
              _uploadedFileName = null;
              _extractedText = null;
            }),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.close, size: 14, color: AppTheme.textSecondary),
                SizedBox(width: 4),
                Text('파일 제거', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUrlInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('약관 페이지 URL', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 4),
        const Text('은행·카드사 홈페이지의 약관 URL을 붙여넣으세요.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 16),
        TextField(
          controller: _urlController,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            hintText: 'https://...',
            hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            prefixIcon: Icon(Icons.link, color: AppTheme.textSecondary, size: 20),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _urlController.text = _exampleUrl,
          child: const Text('예시 URL 불러오기', style: TextStyle(fontSize: 12, color: AppTheme.primaryLight, decoration: TextDecoration.underline)),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFCC02)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFFE65100), size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text('일부 사이트는 접근이 제한될 수 있습니다.', style: TextStyle(fontSize: 11, color: Color(0xFFE65100))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('약관 텍스트 직접 입력', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 4),
        const Text('약관 내용을 복사해서 붙여넣으세요.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 16),
        TextField(
          controller: _textController,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: '약관 내용을 붙여넣으세요...',
            hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _textController.text = _exampleText,
          child: const Text('예시 약관 불러오기', style: TextStyle(fontSize: 12, color: AppTheme.primaryLight, decoration: TextDecoration.underline)),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.summarize_outlined, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI 요약', style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(_report!.summary, style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultList() {
    final dangerCount = _report!.dangerCount;
    final warningCount = _report!.warningCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('조항별 분석', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const Spacer(),
            if (dangerCount > 0) _buildCountChip('위험 $dangerCount', AppTheme.dangerColor),
            const SizedBox(width: 6),
            if (warningCount > 0) _buildCountChip('주의 $warningCount', AppTheme.warningColor),
          ],
        ),
        const SizedBox(height: 12),
        ..._report!.clauses.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildRiskCard(c),
        )),
      ],
    );
  }

  Widget _buildCountChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildRiskCard(RiskClause clause) {
    final configs = {
      RiskLevel.danger: (AppTheme.dangerColor, const Color(0xFFFFEBEE), Icons.dangerous_outlined),
      RiskLevel.warning: (AppTheme.warningColor, const Color(0xFFFFF8E1), Icons.warning_amber_outlined),
      RiskLevel.safe: (AppTheme.safeColor, const Color(0xFFE8F5E9), Icons.check_circle_outline),
    };
    final (color, bg, icon) = configs[clause.level]!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(clause.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                if (clause.clause.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(6)),
                    child: Text(clause.clause, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                  ),
                ],
                const SizedBox(height: 6),
                Text(clause.description, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _textController.dispose();
    super.dispose();
  }
}

