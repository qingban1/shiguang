import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/legal_docs.dart';
import '../data/storage_service.dart';
import '../models/auth_account.dart';
import '../theme/app_colors.dart';
import '../widgets/app_toast.dart';
import '../widgets/glimmer_background.dart';
import 'forgot_password_screen.dart';
import 'legal_doc_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.onAuthed,
    this.sessionExpired = false,
  });

  final VoidCallback onAuthed;
  final bool sessionExpired;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _storage = StorageService.instance;
  int _mode = 0; // 0 登录 1 注册
  final _accountCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  bool _agreed = false;
  bool _shakeAgree = false;
  int _cooldown = 0;
  Timer? _timer;
  String? _hintCode;

  @override
  void initState() {
    super.initState();
    if (widget.sessionExpired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppToast.show(context, '登录已过期，请重新登录');
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _accountCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_cooldown <= 1) {
        t.cancel();
        setState(() => _cooldown = 0);
      } else {
        setState(() => _cooldown -= 1);
      }
    });
  }

  Future<void> _sendRegisterCode() async {
    if (_cooldown > 0 || _busy) return;
    HapticFeedback.selectionClick();
    setState(() => _busy = true);
    final result = await _storage.sendVerificationCode(
      account: _accountCtrl.text,
      purpose: VerifyPurpose.register,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _hintCode = result.code;
    });
    AppToast.show(context, result.message);
    if (result.ok) {
      _startCooldown();
      if (result.code != null) {
        _codeCtrl.text = result.code!;
      }
    }
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (!_agreed) {
      setState(() => _shakeAgree = true);
      HapticFeedback.heavyImpact();
      AppToast.show(context, '请先阅读并同意用户协议与隐私政策');
      Future<void>.delayed(const Duration(milliseconds: 420), () {
        if (mounted) setState(() => _shakeAgree = false);
      });
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _busy = true);
    final result = _mode == 0
        ? await _storage.loginAccount(
            account: _accountCtrl.text,
            password: _passwordCtrl.text,
            agreedTerms: _agreed,
          )
        : await _storage.registerAccount(
            account: _accountCtrl.text,
            password: _passwordCtrl.text,
            displayName: _nameCtrl.text,
            verifyCode: _codeCtrl.text,
            agreedTerms: _agreed,
          );
    if (!mounted) return;
    setState(() => _busy = false);
    AppToast.show(context, result.message);
    if (result.ok) {
      widget.onAuthed();
    }
  }

  Future<void> _openForgot() async {
    final reset = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
    if (reset == true && mounted) {
      setState(() => _mode = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return GlimmerBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(24, 28, 24, 24 + bottom),
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.twilightLight,
                        AppColors.dawn,
                        AppColors.amber,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.amber.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.waves_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '拾岸微光',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.twilightDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.sessionExpired
                    ? '登录已过期，请重新验证身份'
                    : '登录后继续拾取同频的晨曦',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.slate500,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _ModeTab(
                        label: '登录',
                        selected: _mode == 0,
                        onTap: () => setState(() {
                          _mode = 0;
                          _hintCode = null;
                        }),
                      ),
                    ),
                    Expanded(
                      child: _ModeTab(
                        label: '注册',
                        selected: _mode == 1,
                        onTap: () => setState(() {
                          _mode = 1;
                          _hintCode = null;
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white),
                ),
                child: Column(
                  children: [
                    if (_mode == 1) ...[
                      _Field(
                        controller: _nameCtrl,
                        label: '昵称',
                        hint: '你在海岸的名字',
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 12),
                    ],
                    _Field(
                      controller: _accountCtrl,
                      label: '账号',
                      hint: '手机号或邮箱',
                      icon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    if (_mode == 1) ...[
                      const SizedBox(height: 12),
                      _Field(
                        controller: _codeCtrl,
                        label: '验证码',
                        hint: '6 位验证码',
                        icon: Icons.sms_outlined,
                        keyboardType: TextInputType.number,
                        trailing: TextButton(
                          onPressed:
                              _cooldown > 0 || _busy ? null : _sendRegisterCode,
                          child: Text(
                            _cooldown > 0 ? '${_cooldown}s' : '获取验证码',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      if (_hintCode != null) ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '验证码已发送：$_hintCode',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.twilight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 12),
                    _Field(
                      controller: _passwordCtrl,
                      label: '密码',
                      hint: _mode == 1 ? '至少 6 位' : '输入密码',
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscure,
                      trailing: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: AppColors.slate400,
                        ),
                      ),
                    ),
                    if (_mode == 0) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _openForgot,
                          child: const Text(
                            '忘记密码？',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ] else
                      const SizedBox(height: 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      transform: Matrix4.translationValues(
                        _shakeAgree ? 8 : 0,
                        0,
                        0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: Checkbox(
                              value: _agreed,
                              activeColor: AppColors.twilight,
                              onChanged: (v) =>
                                  setState(() => _agreed = v ?? false),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    '我已阅读并同意 ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.45,
                                      color: AppColors.slate600,
                                    ),
                                  ),
                                  GestureDetector(
                                    key: const Key('auth_link_user_agreement'),
                                    onTap: () => openLegalDoc(
                                      context,
                                      LegalDocType.userAgreement,
                                    ),
                                    child: const Text(
                                      '《用户协议》',
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.45,
                                        color: AppColors.twilight,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    ' 与 ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.45,
                                      color: AppColors.slate600,
                                    ),
                                  ),
                                  GestureDetector(
                                    key: const Key('auth_link_privacy_policy'),
                                    onTap: () => openLegalDoc(
                                      context,
                                      LegalDocType.privacyPolicy,
                                    ),
                                    child: const Text(
                                      '《隐私政策》',
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.45,
                                        color: AppColors.twilight,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppColors.postButtonGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TextButton(
                          onPressed: _busy ? null : _submit,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _busy
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _mode == 0 ? '登录' : '注册并进入',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _mode == 0
                    ? '还没有账号？切换到注册，开启你的微光足迹'
                    : '已有账号？切换到登录，继续你的海岸记录',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.slate500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.twilight : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : AppColors.slate500,
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.trailing,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? trailing;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.slate600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.twilightDark,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.slate400,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(icon, size: 20, color: AppColors.twilight),
            suffixIcon: trailing,
            filled: true,
            fillColor: AppColors.twilightSurface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
