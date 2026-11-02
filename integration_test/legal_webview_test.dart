import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glimmer_coast/data/storage_service.dart';
import 'package:glimmer_coast/main.dart';
import 'package:glimmer_coast/models/auth_account.dart';
import 'package:glimmer_coast/screens/legal_doc_screen.dart';
import 'package:integration_test/integration_test.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('注册登录页：用户协议与隐私政策进入内置 WebView 并可返回', (
    tester,
  ) async {
    await StorageService.instance.init();
    await StorageService.instance.logout();

    await tester.pumpWidget(const GlimmerCoastApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await _openByKeyAndBack(
      tester,
      openKey: const Key('auth_link_user_agreement'),
      title: '用户协议',
    );
    await _openByKeyAndBack(
      tester,
      openKey: const Key('auth_link_privacy_policy'),
      title: '隐私政策',
    );
  });

  testWidgets('设置页：用户协议与隐私政策进入内置 WebView 并可返回', (tester) async {
    await StorageService.instance.init();
    await StorageService.instance.logout();

    final stamp = DateTime.now().millisecondsSinceEpoch;
    final account = 'legal$stamp@gmail.com';
    final codeResult = await StorageService.instance.sendVerificationCode(
      account: account,
      purpose: VerifyPurpose.register,
    );
    expect(codeResult.ok, isTrue);
    final registered = await StorageService.instance.registerAccount(
      account: account,
      password: 'Pass1234',
      displayName: '协议测试',
      verifyCode: codeResult.code!,
      agreedTerms: true,
    );
    expect(registered.ok, isTrue);

    await tester.pumpWidget(const GlimmerCoastApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.byIcon(Icons.water_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('账号与资料'), findsOneWidget);

    await _revealKey(tester, const Key('settings_user_agreement'));
    await _openByKeyAndBack(
      tester,
      openKey: const Key('settings_user_agreement'),
      title: '用户协议',
    );

    await _revealKey(tester, const Key('settings_privacy_policy'));
    await _openByKeyAndBack(
      tester,
      openKey: const Key('settings_privacy_policy'),
      title: '隐私政策',
    );

    expect(find.byKey(const Key('settings_user_agreement')), findsOneWidget);
    expect(find.byKey(const Key('settings_privacy_policy')), findsOneWidget);
  });
}

Future<void> _revealKey(WidgetTester tester, Key key) async {
  final target = find.byKey(key);
  if (target.evaluate().isNotEmpty) {
    final center = tester.getCenter(target);
    if (center.dy < 720) return;
  }
  final scrollable = find.byType(Scrollable).first;
  for (var i = 0; i < 16; i++) {
    await tester.drag(scrollable, const Offset(0, -260));
    await tester.pump(const Duration(milliseconds: 180));
    if (find.byKey(key).evaluate().isEmpty) continue;
    final center = tester.getCenter(find.byKey(key));
    if (center.dy < 720) return;
  }
  expect(find.byKey(key), findsOneWidget);
}

Future<void> _openByKeyAndBack(
  WidgetTester tester, {
  required Key openKey,
  required String title,
}) async {
  final target = find.byKey(openKey);
  expect(target, findsOneWidget);
  await tester.tap(target);
  await tester.pump();
  await tester.pump(const Duration(seconds: 2));

  expect(find.byType(LegalDocScreen), findsOneWidget);
  expect(find.text(title), findsWidgets);
  expect(find.byType(WebViewWidget), findsOneWidget);

  await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 800));
  expect(find.byType(LegalDocScreen), findsNothing);
}
