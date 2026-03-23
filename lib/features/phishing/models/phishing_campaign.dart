class PhishingCampaign {
  const PhishingCampaign({
    required this.id,
    required this.name,
    required this.status,
    required this.sentCount,
    required this.openedCount,
    required this.clickedCount,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String status;
  final int sentCount;
  final int openedCount;
  final int clickedCount;
  final DateTime createdAt;

  factory PhishingCampaign.fromMap(Map<String, dynamic> map) {
    return PhishingCampaign(
      id: map['id'] as String,
      name: (map['name'] as String?) ?? '',
      status: (map['status'] as String?) ?? 'draft',
      sentCount: (map['sent_count'] as num?)?.toInt() ?? 0,
      openedCount: (map['opened_count'] as num?)?.toInt() ?? 0,
      clickedCount: (map['clicked_count'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse((map['created_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
