import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/news_item.dart';

class NewsService {
  NewsService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<NewsItem>> fetchLatestNews() async {
    final response = await _client.functions.invoke('security-news');
    final data = response.data as Map<String, dynamic>?;
    final rows = (data?['items'] as List<dynamic>? ?? const <dynamic>[])
        .cast<Map<String, dynamic>>();

    return rows
        .map(NewsItem.fromMap)
        .where((item) => item.url.isNotEmpty)
        .toList();
  }
}
