import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../data/legal_docs.dart';
import '../theme/app_colors.dart';

Future<void> openLegalDoc(BuildContext context, LegalDocType type) {
  return Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      builder: (_) => LegalDocScreen(type: type),
      fullscreenDialog: false,
    ),
  );
}

class LegalDocScreen extends StatefulWidget {
  const LegalDocScreen({super.key, required this.type});

  final LegalDocType type;

  @override
  State<LegalDocScreen> createState() => _LegalDocScreenState();
}

class _LegalDocScreenState extends State<LegalDocScreen> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _loading = true;
  bool _hasError = false;
  String _errorMessage = '页面加载失败，请检查网络后重试';

  String get _title => LegalDocs.title(widget.type);
  String get _url => LegalDocs.url(widget.type);

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      // Google Sites 在 WKWebView 中需接近 Safari 的 UA 才能正常渲染
      ..setUserAgent(
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
        'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 '
        'Mobile/15E148 Safari/604.1',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) return;
            setState(() => _progress = progress);
          },
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _loading = true;
              _hasError = false;
              _progress = 0;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() {
              _loading = false;
              _progress = 100;
            });
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            // 仅主框架失败时展示错误页，避免空白
            final isMain = error.isForMainFrame ?? true;
            if (!isMain) return;
            setState(() {
              _loading = false;
              _hasError = true;
              _errorMessage = _messageForError(error);
            });
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;
            // 保持在应用内 WebView，不唤起外部浏览器
            if (uri.scheme == 'http' || uri.scheme == 'https') {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      );
    _reload();
  }

  String _messageForError(WebResourceError error) {
    final desc = error.description.trim();
    if (desc.contains('Internet') ||
        desc.contains('offline') ||
        desc.contains('network') ||
        desc.contains('主机名') ||
        desc.contains('网络') ||
        error.errorType == WebResourceErrorType.hostLookup ||
        error.errorType == WebResourceErrorType.timeout ||
        error.errorType == WebResourceErrorType.connect) {
      return '当前无网络或网络不稳定，无法打开$_title';
    }
    if (desc.isNotEmpty) {
      return '无法加载$_title：$desc';
    }
    return '页面加载失败，请检查网络后重试';
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _hasError = false;
      _progress = 0;
      _errorMessage = '页面加载失败，请检查网络后重试';
    });
    try {
      await _controller.loadRequest(Uri.parse(_url));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasError = true;
        _errorMessage = '当前无网络或页面地址无效，无法打开$_title';
      });
    }
  }

  void _onBack() {
    // 返回上一层 App 页面，不退出应用
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.twilightDark,
        elevation: 0.5,
        title: Text(
          _title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.twilightDark,
          ),
        ),
        leading: IconButton(
          tooltip: '返回',
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: _onBack,
        ),
        actions: [
          IconButton(
            tooltip: '重新加载',
            onPressed: _loading ? null : _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: _loading && !_hasError
              ? LinearProgressIndicator(
                  value: _progress > 0 && _progress < 100
                      ? _progress / 100
                      : null,
                  minHeight: 3,
                  backgroundColor: AppColors.slate100,
                  color: AppColors.twilight,
                )
              : const SizedBox(height: 3),
        ),
      ),
      body: Stack(
        children: [
          if (!_hasError)
            WebViewWidget(controller: _controller)
          else
            _ErrorPane(
              title: _title,
              message: _errorMessage,
              onRetry: _reload,
            ),
          if (_loading && !_hasError)
            const ColoredBox(
              color: Color(0x66FFFFFF),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.twilight,
                  strokeWidth: 2.6,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorPane extends StatelessWidget {
  const _ErrorPane({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.meshA,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.twilightSurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  color: AppColors.twilight,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '无法打开$title',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.twilightDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.slate500,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.twilight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text(
                  '重新加载',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
