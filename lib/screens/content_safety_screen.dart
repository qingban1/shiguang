import 'package:flutter/material.dart';

import '../models/content_report.dart';
import '../theme/app_colors.dart';
import '../widgets/glimmer_background.dart';

/// 举报记录与审核处理
class ContentSafetyScreen extends StatelessWidget {
  const ContentSafetyScreen({
    super.key,
    required this.reports,
    required this.onStartReview,
    required this.onResolve,
  });

  final List<ContentReport> reports;
  final Future<void> Function(String reportId) onStartReview;
  final Future<void> Function(String reportId, bool upheld) onResolve;

  @override
  Widget build(BuildContext context) {
    final open = reports.where((r) => r.isOpen).toList();
    final closed = reports.where((r) => !r.isOpen).toList();

    return GlimmerBackground(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(
              '内容安全中心',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.twilightDark,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            bottom: const TabBar(
              labelColor: AppColors.twilight,
              unselectedLabelColor: AppColors.slate500,
              indicatorColor: AppColors.twilight,
              tabs: [
                Tab(text: '待审核'),
                Tab(text: '全部记录'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _ReportList(
                reports: open,
                emptyText: '暂无待处理举报',
                onStartReview: onStartReview,
                onResolve: onResolve,
                showActions: true,
              ),
              _ReportList(
                reports: [...open, ...closed],
                emptyText: '还没有举报记录',
                onStartReview: onStartReview,
                onResolve: onResolve,
                showActions: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportList extends StatelessWidget {
  const _ReportList({
    required this.reports,
    required this.emptyText,
    required this.onStartReview,
    required this.onResolve,
    required this.showActions,
  });

  final List<ContentReport> reports;
  final String emptyText;
  final Future<void> Function(String reportId) onStartReview;
  final Future<void> Function(String reportId, bool upheld) onResolve;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return Center(
        child: Text(
          emptyText,
          style: const TextStyle(fontSize: 13, color: AppColors.slate500),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      itemCount: reports.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final r = reports[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _StatusBadge(status: r.status),
                  const Spacer(),
                  Text(
                    r.targetType == ReportTargetType.post ? '内容' : '用户',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                r.targetLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.twilightDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '原因：${r.reason.label}',
                style: const TextStyle(fontSize: 12, color: AppColors.slate600),
              ),
              if (r.note.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '说明：${r.note}',
                  style: const TextStyle(fontSize: 12, color: AppColors.slate500),
                ),
              ],
              if (r.resolutionNote.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '处理：${r.resolutionNote}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.twilight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                _timeLabel(r.createdAt),
                style: const TextStyle(fontSize: 11, color: AppColors.slate400),
              ),
              if (showActions && r.isOpen) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (r.status == ReportStatus.pending)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => onStartReview(r.id),
                          child: const Text('开始审核'),
                        ),
                      ),
                    if (r.status == ReportStatus.pending)
                      const SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        onPressed: () => onResolve(r.id, false),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.slate100,
                          foregroundColor: AppColors.slate600,
                        ),
                        child: const Text('驳回'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        onPressed: () => onResolve(r.id, true),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.rose50,
                          foregroundColor: AppColors.rose600,
                        ),
                        child: const Text('成立并隐藏'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _timeLabel(DateTime t) {
    final m = t.month.toString().padLeft(2, '0');
    final d = t.day.toString().padLeft(2, '0');
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$m-$d $hh:$mm';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ReportStatus status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status) {
      case ReportStatus.pending:
        bg = AppColors.amberSurface;
        fg = AppColors.amberDark;
      case ReportStatus.reviewing:
        bg = AppColors.twilightSurface;
        fg = AppColors.twilight;
      case ReportStatus.upheld:
        bg = AppColors.rose50;
        fg = AppColors.rose600;
      case ReportStatus.rejected:
        bg = AppColors.slate100;
        fg = AppColors.slate600;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}
