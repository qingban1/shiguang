enum ReportTargetType { post, user }

enum ReportReason {
  inappropriate,
  harassment,
  spam,
  privacy,
  illegal,
  other,
}

extension ReportReasonX on ReportReason {
  String get label {
    switch (this) {
      case ReportReason.inappropriate:
        return '低俗 / 不当内容';
      case ReportReason.harassment:
        return '骚扰 / 人身攻击';
      case ReportReason.spam:
        return '垃圾广告 / 欺诈';
      case ReportReason.privacy:
        return '侵犯隐私';
      case ReportReason.illegal:
        return '违法违规';
      case ReportReason.other:
        return '其他';
    }
  }
}

enum ReportStatus { pending, reviewing, upheld, rejected }

extension ReportStatusX on ReportStatus {
  String get label {
    switch (this) {
      case ReportStatus.pending:
        return '待处理';
      case ReportStatus.reviewing:
        return '审核中';
      case ReportStatus.upheld:
        return '已处理·成立';
      case ReportStatus.rejected:
        return '已驳回';
    }
  }
}

class ContentReport {
  ContentReport({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.targetAuthorId,
    required this.targetLabel,
    required this.reason,
    required this.note,
    required this.createdAt,
    this.status = ReportStatus.pending,
    this.resolvedAt,
    this.resolutionNote = '',
  });

  final String id;
  final ReportTargetType targetType;
  final String targetId;
  final String targetAuthorId;
  final String targetLabel;
  final ReportReason reason;
  final String note;
  final DateTime createdAt;
  ReportStatus status;
  DateTime? resolvedAt;
  String resolutionNote;

  bool get isOpen =>
      status == ReportStatus.pending || status == ReportStatus.reviewing;

  ContentReport copyWith({
    ReportStatus? status,
    DateTime? resolvedAt,
    String? resolutionNote,
  }) {
    return ContentReport(
      id: id,
      targetType: targetType,
      targetId: targetId,
      targetAuthorId: targetAuthorId,
      targetLabel: targetLabel,
      reason: reason,
      note: note,
      createdAt: createdAt,
      status: status ?? this.status,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionNote: resolutionNote ?? this.resolutionNote,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'targetType': targetType.name,
        'targetId': targetId,
        'targetAuthorId': targetAuthorId,
        'targetLabel': targetLabel,
        'reason': reason.name,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
        'resolvedAt': resolvedAt?.toIso8601String(),
        'resolutionNote': resolutionNote,
      };

  factory ContentReport.fromJson(Map<String, dynamic> json) {
    return ContentReport(
      id: json['id'] as String,
      targetType: ReportTargetType.values.firstWhere(
        (e) => e.name == json['targetType'],
        orElse: () => ReportTargetType.post,
      ),
      targetId: json['targetId'] as String? ?? '',
      targetAuthorId: json['targetAuthorId'] as String? ?? '',
      targetLabel: json['targetLabel'] as String? ?? '',
      reason: ReportReason.values.firstWhere(
        (e) => e.name == json['reason'],
        orElse: () => ReportReason.other,
      ),
      note: json['note'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      status: ReportStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReportStatus.pending,
      ),
      resolvedAt: DateTime.tryParse(json['resolvedAt'] as String? ?? ''),
      resolutionNote: json['resolutionNote'] as String? ?? '',
    );
  }
}

class ContentCheckResult {
  const ContentCheckResult.ok()
      : ok = true,
        message = '';

  const ContentCheckResult.reject(this.message) : ok = false;

  final bool ok;
  final String message;
}
