import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/content_filter.dart';
import '../models/content_report.dart';
import '../theme/app_colors.dart';

class ReportDraft {
  const ReportDraft({
    required this.targetType,
    required this.reason,
    required this.note,
  });

  final ReportTargetType targetType;
  final ReportReason reason;
  final String note;
}

Future<ReportDraft?> showReportSheet(
  BuildContext context, {
  required String title,
  ReportTargetType initialType = ReportTargetType.post,
  bool allowUserReport = true,
}) {
  return showModalBottomSheet<ReportDraft>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ReportSheetBody(
      title: title,
      initialType: initialType,
      allowUserReport: allowUserReport,
    ),
  );
}

class _ReportSheetBody extends StatefulWidget {
  const _ReportSheetBody({
    required this.title,
    required this.initialType,
    required this.allowUserReport,
  });

  final String title;
  final ReportTargetType initialType;
  final bool allowUserReport;

  @override
  State<_ReportSheetBody> createState() => _ReportSheetBodyState();
}

class _ReportSheetBodyState extends State<_ReportSheetBody> {
  late ReportTargetType _type;
  ReportReason _reason = ReportReason.inappropriate;
  final _noteCtrl = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final noteCheck = ContentFilter.validateReportNote(_noteCtrl.text);
    if (!noteCheck.ok) {
      setState(() => _error = noteCheck.message);
      return;
    }
    HapticFeedback.selectionClick();
    Navigator.pop(
      context,
      ReportDraft(
        targetType: _type,
        reason: _reason,
        note: _noteCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    final bottom = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(20, 10, 20, 16 + bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            const SizedBox(height: 14),
            const Text(
              '提交举报',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.twilightDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '对象：${widget.title}',
              style: const TextStyle(fontSize: 12, color: AppColors.slate500),
            ),
            const SizedBox(height: 14),
            if (widget.allowUserReport) ...[
              const Text(
                '举报类型',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _TypeChip(
                      label: '举报内容',
                      selected: _type == ReportTargetType.post,
                      onTap: () =>
                          setState(() => _type = ReportTargetType.post),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TypeChip(
                      label: '举报用户',
                      selected: _type == ReportTargetType.user,
                      onTap: () =>
                          setState(() => _type = ReportTargetType.user),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],
            const Text(
              '举报原因',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.slate600,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ReportReason.values.map((r) {
                    final selected = _reason == r;
                    return GestureDetector(
                      onTap: () => setState(() => _reason = r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.twilight
                              : AppColors.slate100,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          r.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : AppColors.slate600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              '补充说明（可选）',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.slate600,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _noteCtrl,
              maxLines: 3,
              maxLength: 200,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              decoration: InputDecoration(
                hintText: '可描述出现位置、时间或具体问题',
                filled: true,
                fillColor: AppColors.twilightSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.rose600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.twilight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextButton(
                  onPressed: _submit,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text(
                    '提交举报',
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

class _TypeChip extends StatelessWidget {
  const _TypeChip({
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.twilightSurface : AppColors.slate100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.twilight.withValues(alpha: 0.45)
                : AppColors.slate200,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: selected ? AppColors.twilight : AppColors.slate600,
          ),
        ),
      ),
    );
  }
}
