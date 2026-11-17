import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/export_entry.dart';
import '../services/history_store.dart';
import '../utils/file_name.dart';

class ConverterPage extends StatefulWidget {
  const ConverterPage({required this.onExportSaved, super.key});

  final VoidCallback onExportSaved;

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  static const _homeUrl = 'https://holoprint-mc.github.io/';

  InAppWebViewController? _controller;
  int _progress = 0;
  String? _loadError;
  bool _isSaving = false;

  static const String _downloadBridgeScript = r'''(() => {
    if (window.__cprDownloadBridgeInstalled) return;
    window.__cprDownloadBridgeInstalled = true;
    const originalCreateObjectURL = URL.createObjectURL.bind(URL);
    const knownBlobs = new Map();
    URL.createObjectURL = function(blob) {
      const url = originalCreateObjectURL(blob);
      try { knownBlobs.set(url, blob); } catch (_) {}
      return url;
    };

    async function sendBlob(blob, filename) {
      if (!blob || !window.flutter_inappwebview) return;
      const reader = new FileReader();
      reader.onloadend = function() {
        const dataUrl = String(reader.result || '');
        const comma = dataUrl.indexOf(',');
        const base64 = comma >= 0 ? dataUrl.substring(comma + 1) : '';
        if (!base64) return;
        window.flutter_inappwebview.callHandler(
          'CPRDownload',
          filename || 'CPR-Holoprint.mcpack',
          blob.type || 'application/octet-stream',
          base64
        );
      };
      reader.readAsDataURL(blob);
    }

    document.addEventListener('click', async function(event) {
      const target = event.target;
      const anchor = target && target.closest ? target.closest('a[download]') : null;
      if (!anchor) return;
      const href = anchor.href || '';
      if (!href.startsWith('blob:') && !href.startsWith('data:')) return;
      event.preventDefault();
      event.stopPropagation();
      if (event.stopImmediatePropagation) event.stopImmediatePropagation();
      try {
        let blob = knownBlobs.get(href);
        if (!blob && href.startsWith('blob:')) {
          blob = await (await fetch(href)).blob();
        }
        if (!blob && href.startsWith('data:')) {
          const response = await fetch(href);
          blob = await response.blob();
        }
        await sendBlob(blob, anchor.download || 'CPR-Holoprint.mcpack');
      } catch (error) {
        console.error('CPR download bridge failed', error);
      }
    }, true);
  })();''';

  Future<void> _installDownloadBridge() async {
    await _controller?.evaluateJavascript(source: _downloadBridgeScript);
  }

  Future<void> _openUpload(String extension) async {
    final safeExtension = jsonEncode(extension.toLowerCase());
    final script = '''(() => {
      const suffix = $safeExtension;
      const inputs = Array.from(document.querySelectorAll('input[type="file"]'));
      const target = inputs.find((input) => (input.accept || '').toLowerCase().includes(suffix));
      if (target) { target.click(); return true; }
      return false;
    })();''';
    try {
      final result = await _controller?.evaluateJavascript(source: script);
      if (result == false && mounted) {
        _showMessage('لم أجد خانة رفع هذا النوع داخل محرك HoloPrint. استخدم أزرار الرفع الموجودة في الصفحة.');
      }
    } on Exception {
      if (mounted) _showMessage('تعذر فتح منتقي الملفات. حدّث صفحة المحول وحاول مرة ثانية.');
    }
  }

  Future<void> _handleDownload(List<dynamic> arguments) async {
    if (_isSaving || arguments.length < 3) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      final fileName = sanitizeDownloadName(arguments[0]?.toString() ?? 'CPR-Holoprint.mcpack');
      final encoded = arguments[2]?.toString() ?? '';
      if (encoded.isEmpty) throw const FormatException('ملف التنزيل فارغ.');
      final bytes = Uint8List.fromList(base64Decode(encoded));
      if (bytes.isEmpty) throw const FormatException('ملف التنزيل فارغ.');

      final destination = await FilePicker.saveFile(
        dialogTitle: 'اختيار مكان حفظ حزمة Holoprint',
        fileName: fileName,
        bytes: bytes,
      );
      if (destination == null) {
        if (mounted) _showMessage('تم إلغاء الحفظ.');
        return;
      }

      final now = DateTime.now();
      await HistoryStore.add(
        ExportEntry(
          id: now.microsecondsSinceEpoch.toString(),
          fileName: fileName,
          createdAt: now,
          bytes: bytes.length,
        ),
      );
      if (mounted) widget.onExportSaved();
      if (mounted) {
        _showMessage('تم حفظ $fileName. افتحه من مدير الملفات لاستيراده إلى Minecraft.');
      }
    } on FormatException catch (error) {
      if (mounted) _showMessage('تعذر قراءة ملف الحزمة: ${error.message}');
    } on Exception catch (error) {
      if (mounted) _showMessage('فشل حفظ الحزمة: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _refresh() async {
    setState(() {
      _loadError = null;
      _progress = 0;
    });
    await _controller?.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 9),
          decoration: BoxDecoration(
            color: const Color(0xFF101B23),
            border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Color(0xFF5BE0C8), shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'محرك HoloPrint الرسمي · اتصال مطلوب',
                  style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'استيراد ملفات',
                icon: const Icon(Icons.add_to_photos_outlined, size: 21),
                onSelected: _openUpload,
                itemBuilder: (context) => const [
                  PopupMenuItem(value: '.mcstructure', child: Text('ملف MCStructure')),
                  PopupMenuItem(value: '.mcworld', child: Text('عالم MCWorld')),
                  PopupMenuItem(value: '.mctemplate', child: Text('قالب MCTemplate')),
                  PopupMenuItem(value: '.zip', child: Text('ملف عالم ZIP')),
                  PopupMenuItem(value: '.mcpack', child: Text('حزمة قديمة MCpack')),
                ],
              ),
              IconButton(
                tooltip: 'إعادة تحميل المحرك',
                onPressed: _refresh,
                icon: const Icon(Icons.refresh_rounded, size: 21),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
        if (_progress < 100)
          LinearProgressIndicator(
            value: _progress == 0 ? null : _progress / 100,
            minHeight: 2,
            backgroundColor: Colors.white.withValues(alpha: 0.04),
            color: const Color(0xFF54DCC5),
          ),
        if (_isSaving)
          const LinearProgressIndicator(minHeight: 2, color: Color(0xFFFFC66D)),
        Expanded(
          child: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(_homeUrl)),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  useOnDownloadStart: true,
                  useShouldOverrideUrlLoading: true,
                  allowFileAccessFromFileURLs: false,
                  allowUniversalAccessFromFileURLs: false,
                  supportZoom: true,
                  builtInZoomControls: true,
                  displayZoomControls: false,
                  isInspectable: false,
                  allowsInlineMediaPlayback: true,
                ),
                shouldOverrideUrlLoading: (controller, action) async {
                  final target = action.request.url;
                  if (target == null) return NavigationActionPolicy.CANCEL;
                  if (target.host == 'holoprint-mc.github.io') {
                    return NavigationActionPolicy.ALLOW;
                  }
                  if (target.scheme == 'https' || target.scheme == 'http') {
                    await launchUrl(Uri.parse(target.toString()), mode: LaunchMode.externalApplication);
                  }
                  return NavigationActionPolicy.CANCEL;
                },
                onWebViewCreated: (controller) {
                  _controller = controller;
                  controller.addJavaScriptHandler(
                    handlerName: 'CPRDownload',
                    callback: (arguments) async {
                      await _handleDownload(arguments);
                      return {'received': true};
                    },
                  );
                },
                onLoadStart: (controller, url) {
                  if (mounted) setState(() => _loadError = null);
                },
                onLoadStop: (controller, url) async {
                  await _installDownloadBridge();
                  if (mounted) setState(() => _progress = 100);
                },
                onProgressChanged: (controller, progress) {
                  if (mounted) setState(() => _progress = progress);
                },
                onReceivedError: (controller, request, error) {
                  if (request.isForMainFrame == true && mounted) {
                    setState(() => _loadError = error.description);
                  }
                },
              ),
              if (_loadError != null)
                Positioned.fill(
                  child: ColoredBox(
                    color: const Color(0xFF0A1118),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.wifi_off_rounded, size: 42, color: Colors.white54),
                            const SizedBox(height: 14),
                            const Text('تعذر الاتصال بمحرك HoloPrint', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            const SizedBox(height: 8),
                            Text(_loadError!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            const SizedBox(height: 18),
                            FilledButton.icon(onPressed: _refresh, icon: const Icon(Icons.refresh), label: const Text('إعادة المحاولة')),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          color: const Color(0xFF0E1720),
          child: const Text(
            'تُفتح الملفات داخل صفحة HoloPrint الرسمية. لا تستخدم ملفات لا تملك حق استخدامها أو مشاركتها.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 9, height: 1.35),
          ),
        ),
      ],
    );
  }
}
