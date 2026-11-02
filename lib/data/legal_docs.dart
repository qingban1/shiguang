import '../config/app_legal_urls.dart';

enum LegalDocType { userAgreement, privacyPolicy }

class LegalDocs {
  LegalDocs._();

  static String title(LegalDocType type) {
    switch (type) {
      case LegalDocType.userAgreement:
        return '用户协议';
      case LegalDocType.privacyPolicy:
        return '隐私政策';
    }
  }

  /// 已发布的公开网址，供应用内 WebView 加载。
  static String url(LegalDocType type) {
    switch (type) {
      case LegalDocType.userAgreement:
        return AppLegalUrls.userAgreement;
      case LegalDocType.privacyPolicy:
        return AppLegalUrls.privacyPolicy;
    }
  }
}
