import 'package:flutter_test/flutter_test.dart';
import 'package:glimmer_coast/models/auth_account.dart';
import 'package:glimmer_coast/models/content_report.dart';

void main() {
  group('AuthAccount', () {
    test('password hash matches', () {
      final a = AuthAccount(
        id: '1',
        account: '13800138000',
        passwordHash: AuthAccount.hashPassword('secret1'),
        displayName: '旅人',
      );
      expect(a.matchesPassword('secret1'), isTrue);
      expect(a.matchesPassword('wrong'), isFalse);
    });

    test('session expiry detection', () {
      final expired = AuthSession(
        accountId: '1',
        issuedAt: DateTime.now().subtract(const Duration(days: 40)),
        expiresAt: DateTime.now().subtract(const Duration(days: 10)),
      );
      expect(expired.isExpired, isTrue);

      final live = AuthSession(
        accountId: '1',
        issuedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );
      expect(live.isExpired, isFalse);
    });

    test('masks phone and email', () {
      final phone = AuthAccount(
        id: '1',
        account: '13800138000',
        passwordHash: 'x',
        displayName: 'a',
      );
      expect(phone.maskedAccount.contains('****'), isTrue);

      final mail = AuthAccount(
        id: '2',
        account: 'hello@example.com',
        passwordHash: 'x',
        displayName: 'a',
      );
      expect(mail.maskedAccount.contains('***'), isTrue);
    });
  });

  group('ContentReport', () {
    test('isOpen for pending and reviewing', () {
      final pending = ContentReport(
        id: 'r1',
        targetType: ReportTargetType.post,
        targetId: 'p1',
        targetAuthorId: 'a1',
        targetLabel: 'x',
        reason: ReportReason.spam,
        note: '',
        createdAt: DateTime.now(),
      );
      expect(pending.isOpen, isTrue);
      pending.status = ReportStatus.upheld;
      expect(pending.isOpen, isFalse);
    });
  });
}
