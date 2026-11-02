import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glimmer_coast/screens/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('AuthScreen shows login and register tabs', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthScreen(onAuthed: () {}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('拾岸微光'), findsOneWidget);
    expect(find.text('登录'), findsWidgets);
    expect(find.text('注册'), findsOneWidget);
    expect(find.textContaining('用户协议'), findsOneWidget);
  });
}
