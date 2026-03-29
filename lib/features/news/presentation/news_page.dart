import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sass_security/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/app_snack.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../auth/models/app_profile.dart';
import '../data/news_service.dart';
import '../models/news_item.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({required this.profile, super.key});

  final AppProfile profile;

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final _service = NewsService();
  late Future<List<NewsItem>> _future;

  var _selectedTopic = 'all';

  @override
  void initState() {
    super.initState();
    _future = _service.fetchLatestNews();
  }

  Future<void> _reload() async {
    setState(() {
      _future = _service.fetchLatestNews();
    });
    await _future;
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    final l10n = AppLocalizations.of(context);
    if (uri == null) {
      if (mounted) {
        AppSnack.error(context, l10n.invalid_news_link);
      }
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      AppSnack.error(context, l10n.cannot_open_news);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: _reload,
      child: FutureBuilder<List<NewsItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: const [
                LoadingSkeleton(height: 108),
                SizedBox(height: 12),
                LoadingSkeleton(height: 108),
                SizedBox(height: 12),
                LoadingSkeleton(height: 108),
              ],
            );
          }

          if (snapshot.hasError) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(snapshot.error.toString()),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _reload, child: Text(l10n.refresh)),
              ],
            );
          }

          final allItems = snapshot.data ?? const <NewsItem>[];
          final items = _selectedTopic == 'all'
              ? allItems
              : allItems.where((item) => item.topic == _selectedTopic).toList();

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.security_news_title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.security_news_subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _TopicChip(
                          label: l10n.news_topic_all,
                          selected: _selectedTopic == 'all',
                          onSelected: () =>
                              setState(() => _selectedTopic = 'all'),
                        ),
                        _TopicChip(
                          label: l10n.incident_type_virus,
                          selected: _selectedTopic == 'virus',
                          onSelected: () =>
                              setState(() => _selectedTopic = 'virus'),
                        ),
                        _TopicChip(
                          label: l10n.incident_type_hacking,
                          selected: _selectedTopic == 'hacking',
                          onSelected: () =>
                              setState(() => _selectedTopic = 'hacking'),
                        ),
                        _TopicChip(
                          label: l10n.news_topic_tools,
                          selected: _selectedTopic == 'tools',
                          onSelected: () =>
                              setState(() => _selectedTopic = 'tools'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                EmptyState(
                  title: l10n.no_news_for_filter,
                  icon: Icons.newspaper_outlined,
                ),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    child: InkWell(
                      onTap: () => _openLink(item.url),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _TopicBadge(topic: item.topic, l10n: l10n),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.source,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.white70),
                                  ),
                                ),
                                Text(
                                  DateFormat(
                                    'dd/MM HH:mm',
                                  ).format(item.publishedAt.toLocal()),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.white70),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if ((item.summary ?? '').isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                item.summary!,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.white70),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              item.url,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: const Color(0xFF93C5FD)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: const Color(0xFF1D4ED8),
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.white70),
      backgroundColor: const Color(0x332B3548),
      side: const BorderSide(color: Color(0xFF334155)),
    );
  }
}

class _TopicBadge extends StatelessWidget {
  const _TopicBadge({required this.topic, required this.l10n});

  final String topic;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color color;

    switch (topic) {
      case 'virus':
        label = l10n.news_badge_virus;
        color = const Color(0xFFEF4444);
      case 'tools':
        label = l10n.news_badge_tools;
        color = const Color(0xFF10B981);
      case 'hacking':
      default:
        label = l10n.news_badge_hacking;
        color = const Color(0xFFF59E0B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
