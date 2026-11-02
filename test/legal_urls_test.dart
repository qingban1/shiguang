import 'package:flutter_test/flutter_test.dart';
import 'package:glimmer_coast/config/app_legal_urls.dart';
import 'package:glimmer_coast/data/legal_docs.dart';

void main() {
  test('legal public urls are published Sites links', () {
    expect(
      AppLegalUrls.userAgreement,
      'https://sites.google.com/view/huvrhyfydyydy/%E9%A6%96%E9%A1%B5',
    );
    expect(
      AppLegalUrls.privacyPolicy,
      'https://sites.google.com/view/iueyd8737y2e78y237/%E9%A6%96%E9%A1%B5',
    );

    expect(LegalDocs.url(LegalDocType.userAgreement), AppLegalUrls.userAgreement);
    expect(LegalDocs.url(LegalDocType.privacyPolicy), AppLegalUrls.privacyPolicy);

    for (final url in [
      AppLegalUrls.userAgreement,
      AppLegalUrls.privacyPolicy,
    ]) {
      expect(url.startsWith('https://sites.google.com/view/'), isTrue);
      expect(url.contains('/edit'), isFalse);
      expect(url.contains('/u/'), isFalse);
    }
  });
}
