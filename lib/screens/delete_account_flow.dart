import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/legal_docs.dart';
import '../theme/app_colors.dart';
import 'legal_doc_screen.dart';

/// 注销账号完整流程：说明 → 密码验证 → 二次确认
/// 返回密码字符串表示用户确认注销；null 表示取消
Future<String?> showDeleteAccountFlow(BuildContext context) async {
  final understood = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _DeleteExplainSheet(),
  );
  if (understood != true || !context.mounted) return null;

  final password = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _DeletePasswordSheet(),
  );
  if (password == null || password.isEmpty || !context.mounted) return null;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('二次确认'),
      content: const Text(
        '注销后账号与相关内容将永久删除且不可恢复。确定继续吗？',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: AppColors.rose600),
          child: const Text('确认注销'),
        ),
      ],
    ),
  );
  if (confirmed != true) return null;
  return password;
}

class _DeleteExplainSheet extends StatefulWidget {
  const _DeleteExplainSheet();

  @override
  State<_DeleteExplainSheet> createState() => _DeleteExplainSheetState();
}

class _DeleteExplainSheetState extends State<_DeleteExplainSheet> {
  bool _checked = false;

  static const _items = <String>[
    '账号登录凭证与身份信息',
    '个人资料（昵称、头像、城市、简介）',
    '你发布的全部微光动态及相关回响',
    '关注与粉丝关系中的个人关联数据',
    '信箱确幸收集、互动通知与拉黑名单',
    '账号偏好设置与登录状态',
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slate300,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '注销账号',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.rose600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '注销将永久删除以下数据，且不可恢复：',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.slate700,
            ),
          ),
          const SizedBox(height: 12),
          ..._items.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.remove_circle_outline,
                      size: 16,
                      color: AppColors.rose600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      e,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.slate700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.rose50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '社区中他人可见的公开内容将一并移除。注销完成后将清除登录信息并返回未登录状态。',
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color: AppColors.rose600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                '注销规则详见',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.slate600,
                ),
              ),
              GestureDetector(
                onTap: () =>
                    openLegalDoc(context, LegalDocType.userAgreement),
                child: const Text(
                  '《用户协议》',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.twilight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Text(
                '与',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.slate600,
                ),
              ),
              GestureDetector(
                onTap: () =>
                    openLegalDoc(context, LegalDocType.privacyPolicy),
                child: const Text(
                  '《隐私政策》',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.twilight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Text(
                '。',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.slate600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => setState(() => _checked = !_checked),
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                Checkbox(
                  value: _checked,
                  activeColor: AppColors.rose600,
                  onChanged: (v) => setState(() => _checked = v ?? false),
                ),
                const Expanded(
                  child: Text(
                    '我已了解上述影响，并确认数据删除后不可恢复',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('取消'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _checked ? AppColors.rose600 : AppColors.slate200,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextButton(
                    onPressed: _checked
                        ? () {
                            HapticFeedback.selectionClick();
                            Navigator.pop(context, true);
                          }
                        : null,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      disabledForegroundColor: AppColors.slate400,
                    ),
                    child: const Text(
                      '继续注销',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeletePasswordSheet extends StatefulWidget {
  const _DeletePasswordSheet();

  @override
  State<_DeletePasswordSheet> createState() => _DeletePasswordSheetState();
}

class _DeletePasswordSheetState extends State<_DeletePasswordSheet> {
  final _ctrl = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_ctrl.text.isEmpty) {
      setState(() => _error = '请输入当前密码以验证身份');
      return;
    }
    HapticFeedback.selectionClick();
    Navigator.pop(context, _ctrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    final bottom = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slate300,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '身份验证',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.twilightDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '请输入当前登录密码，以确认是你本人在操作。',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.slate500),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              obscureText: _obscure,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '当前密码',
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.twilight,
                ),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.slate400,
                  ),
                ),
                filled: true,
                fillColor: AppColors.twilightSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _error!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.rose600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.rose600,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextButton(
                  onPressed: _submit,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text(
                    '验证并继续',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
