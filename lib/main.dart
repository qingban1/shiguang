import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/storage_service.dart';
import 'screens/auth_screen.dart';
import 'screens/home_shell.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'widgets/glimmer_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  await StorageService.instance.init();
  runApp(const GlimmerCoastApp());
}

class GlimmerCoastApp extends StatelessWidget {
  const GlimmerCoastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '拾岸微光',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthRoot(),
    );
  }
}

class AuthRoot extends StatefulWidget {
  const AuthRoot({super.key});

  @override
  State<AuthRoot> createState() => _AuthRootState();
}

class _AuthRootState extends State<AuthRoot> with WidgetsBindingObserver {
  bool _ready = false;
  bool _loggedIn = false;
  bool _sessionExpired = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _loggedIn) {
      _revalidateSession();
    }
  }

  Future<void> _bootstrap() async {
    final state = await StorageService.instance.checkLoginState();
    if (!mounted) return;
    setState(() {
      _loggedIn = state.loggedIn;
      _sessionExpired = state.expired;
      _ready = true;
    });
  }

  Future<void> _revalidateSession() async {
    final state = await StorageService.instance.checkLoginState();
    if (!mounted) return;
    if (!state.loggedIn && _loggedIn) {
      setState(() {
        _loggedIn = false;
        _sessionExpired = state.expired || true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const GlimmerBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.twilight),
          ),
        ),
      );
    }
    if (!_loggedIn) {
      return AuthScreen(
        sessionExpired: _sessionExpired,
        onAuthed: () => setState(() {
          _loggedIn = true;
          _sessionExpired = false;
        }),
      );
    }
    return HomeShell(
      onLoggedOut: () => setState(() {
        _loggedIn = false;
        _sessionExpired = false;
      }),
      onSessionExpired: () => setState(() {
        _loggedIn = false;
        _sessionExpired = true;
      }),
    );
  }
}
