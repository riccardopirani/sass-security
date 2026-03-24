class PhishingCampaign {
  const PhishingCampaign({
    required this.id,
    required this.name,
    required this.status,
    required this.sentCount,
    required this.openedCount,
    required this.clickedCount,
    required this.credentialSubmittedCount,
    required this.abTestEnabled,
    required this.campaignMode,
    required this.generatedByAi,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String status;
  final int sentCount;
  final int openedCount;
  final int clickedCount;
  final int credentialSubmittedCount;
  final bool abTestEnabled;
  final String campaignMode;
  final bool generatedByAi;
  final DateTime createdAt;

  factory PhishingCampaign.fromMap(Map<String, dynamic> map) {
    return PhishingCampaign(
      id: map['id'] as String,
      name: (map['name'] as String?) ?? '',
      status: (map['status'] as String?) ?? 'draft',
      sentCount: (map['sent_count'] as num?)?.toInt() ?? 0,
      openedCount: (map['opened_count'] as num?)?.toInt() ?? 0,
      clickedCount: (map['clicked_count'] as num?)?.toInt() ?? 0,
      credentialSubmittedCount:
          (map['credential_submitted_count'] as num?)?.toInt() ?? 0,
      abTestEnabled: (map['ab_test_enabled'] as bool?) ?? false,
      campaignMode: (map['campaign_mode'] as String?) ?? 'manual',
      generatedByAi: (map['generated_by_ai'] as bool?) ?? false,
      createdAt:
          DateTime.tryParse((map['created_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
