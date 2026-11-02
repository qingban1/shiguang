import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/storage_service.dart';
import '../models/auth_account.dart';
import '../theme/app_colors.dart';
import '../widgets/app_toast.dart';
import '../widgets/glimmer_background.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _storage = StorageService.instance;
  final _accountCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  int _cooldown = 0;
  Timer? _timer;
  String? _hintCode;

  @override
  void dispose() {
    _timer?.cancel();
    _accountCtrl.dispose();
    _codeCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
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

  Future<void> _sendCode() async {
    if (_cooldown > 0 || _busy) return;
    HapticFeedback.selectionClick();
    setState(() => _busy = true);
    final result = await _storage.sendVerificationCode(
      account: _accountCtrl.text,
      purpose: VerifyPurpose.reset,
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
    if (_passwordCtrl.text != _confirmCtrl.text) {
      AppToast.show(context, '两次输入的新密码不一致');
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _busy = true);
    final result = await _storage.resetPassword(
      account: _accountCtrl.text,
      verifyCode: _codeCtrl.text,
      newPassword: _passwordCtrl.text,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    AppToast.show(context, result.message);
    if (result.ok) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return GlimmerBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            '忘记密码',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.twilightDark,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 24 + bottom),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white),
              ),
              child: Column(
                children: [
                  const Text(
                    '通过账号验证码重置密码。重置成功后请使用新密码登录。',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: AppColors.slate500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AuthField(
                    controller: _accountCtrl,
                    label: '账号',
                    hint: '注册时的手机号或邮箱',
                    icon: Icons.person_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _AuthField(
                    controller: _codeCtrl,
                    label: '验证码',
                    hint: '6 位验证码',
                    icon: Icons.sms_outlined,
                    keyboardType: TextInputType.number,
                    trailing: TextButton(
                      onPressed: _cooldown > 0 || _busy ? null : _sendCode,
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
                  const SizedBox(height: 12),
                  _AuthField(
                    controller: _passwordCtrl,
                    label: '新密码',
                    hint: '至少 6 位',
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
                  const SizedBox(height: 12),
                  _AuthField(
                    controller: _confirmCtrl,
                    label: '确认新密码',
                    hint: '再次输入新密码',
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscure,
                  ),
                  const SizedBox(height: 20),
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
                            : const Text(
                                '重置密码',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
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
