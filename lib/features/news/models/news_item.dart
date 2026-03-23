class NewsItem {
  const NewsItem({
    required this.title,
    required this.url,
    required this.source,
    required this.topic,
    required this.publishedAt,
    this.summary,
  });

  final String title;
  final String url;
  final String source;
  final String topic;
  final DateTime publishedAt;
  final String? summary;

  factory NewsItem.fromMap(Map<String, dynamic> map) {
    return NewsItem(
      title: (map['title'] as String?) ?? '',
      url: (map['url'] as String?) ?? '',
      source: (map['source'] as String?) ?? 'Unknown source',
      topic: (map['topic'] as String?) ?? 'hacking',
      summary: (map['summary'] as String?)?.trim(),
      publishedAt:
          DateTime.tryParse((map['published_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
