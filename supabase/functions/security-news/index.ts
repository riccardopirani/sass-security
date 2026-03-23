import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

import { handleOptions, json } from '../_shared/cors.ts';

type Topic = 'virus' | 'hacking' | 'tools';

type NewsItem = {
  title: string;
  url: string;
  source: string;
  topic: Topic;
  summary: string;
  published_at: string;
};

type RssSource = {
  name: string;
  url: string;
};

const maxItems = 60;

const rssSources: RssSource[] = [
  { name: 'Reddit r/netsec', url: 'https://www.reddit.com/r/netsec/.rss' },
  {
    name: 'Reddit r/cybersecurity',
    url: 'https://www.reddit.com/r/cybersecurity/.rss',
  },
  {
    name: 'Security StackExchange',
    url: 'https://security.stackexchange.com/feeds',
  },
  {
    name: 'BleepingComputer',
    url: 'https://www.bleepingcomputer.com/feed/',
  },
];

const hackerNewsQueries = [
  'malware ransomware virus',
  'hacking data breach exploit',
  'cybersecurity tool pentest scanner',
];

const plainText = (value: string) =>
  value
    .replace(/<!\[CDATA\[(.*?)\]\]>/gis, '$1')
    .replace(/<[^>]+>/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();

const asIsoDate = (value: string | null | undefined) => {
  const parsed = value ? new Date(value) : new Date(0);
  if (Number.isNaN(parsed.getTime())) {
    return new Date(0).toISOString();
  }
  return parsed.toISOString();
};

const classifyTopic = (text: string): Topic => {
  const t = text.toLowerCase();

  if (
    t.includes('virus') ||
    t.includes('malware') ||
    t.includes('ransomware') ||
    t.includes('trojan') ||
    t.includes('worm')
  ) {
    return 'virus';
  }

  if (
    t.includes('tool') ||
    t.includes('scanner') ||
    t.includes('framework') ||
    t.includes('open source') ||
    t.includes('pentest') ||
    t.includes('github')
  ) {
    return 'tools';
  }

  return 'hacking';
};

const normalizeItem = (raw: {
  title?: string;
  url?: string;
  source: string;
  summary?: string;
  publishedAt?: string;
  hintText?: string;
}): NewsItem | null => {
  const title = (raw.title ?? '').trim();
  const url = (raw.url ?? '').trim();

  if (!title || !url || !url.startsWith('http')) {
    return null;
  }

  return {
    title,
    url,
    source: raw.source,
    summary: plainText((raw.summary ?? '').trim()).slice(0, 300),
    topic: classifyTopic(`${title} ${raw.summary ?? ''} ${raw.hintText ?? ''}`),
    published_at: asIsoDate(raw.publishedAt),
  };
};

const fetchHackerNews = async (): Promise<NewsItem[]> => {
  const all: NewsItem[] = [];

  for (const query of hackerNewsQueries) {
    const params = new URLSearchParams({
      query,
      tags: 'story',
      hitsPerPage: '18',
    });

    const response = await fetch(
      `https://hn.algolia.com/api/v1/search_by_date?${params.toString()}`,
      {
        headers: {
          'User-Agent': 'CyberGuard-News-Aggregator',
        },
      },
    );

    if (!response.ok) {
      continue;
    }

    const data = await response.json();
    const hits = (data?.hits as Array<Record<string, unknown>> | undefined) ?? [];

    for (const hit of hits) {
      const item = normalizeItem({
        title: (hit.title as string | undefined) ?? (hit.story_title as string | undefined),
        url: (hit.url as string | undefined) ?? (hit.story_url as string | undefined),
        source: 'Hacker News',
        publishedAt: hit.created_at as string | undefined,
        hintText: query,
      });

      if (item != null) {
        all.push(item);
      }
    }
  }

  return all;
};

const textFromFirst = (element: Element, selectors: string[]) => {
  for (const selector of selectors) {
    const node = element.querySelector(selector);
    const text = node?.textContent?.trim() ?? '';
    if (text.length > 0) {
      return text;
    }
  }
  return '';
};

const parseRss = (xml: string, sourceName: string): NewsItem[] => {
  const document = new DOMParser().parseFromString(xml, 'application/xml');
  if (!document) {
    return [];
  }

  const output: NewsItem[] = [];

  for (const item of document.querySelectorAll('item')) {
    const normalized = normalizeItem({
      title: textFromFirst(item, ['title']),
      url: textFromFirst(item, ['link']),
      source: sourceName,
      summary: textFromFirst(item, ['description', 'content']),
      publishedAt: textFromFirst(item, ['pubDate', 'dc\\:date']),
    });

    if (normalized != null) {
      output.push(normalized);
    }
  }

  for (const entry of document.querySelectorAll('entry')) {
    const linkElement = entry.querySelector('link');
    const href = linkElement?.getAttribute('href') ?? '';

    const normalized = normalizeItem({
      title: textFromFirst(entry, ['title']),
      url: href,
      source: sourceName,
      summary: textFromFirst(entry, ['summary', 'content']),
      publishedAt: textFromFirst(entry, ['updated', 'published']),
    });

    if (normalized != null) {
      output.push(normalized);
    }
  }

  return output;
};

const fetchRssSource = async (source: RssSource): Promise<NewsItem[]> => {
  const response = await fetch(source.url, {
    headers: {
      'User-Agent': 'CyberGuard-News-Aggregator',
    },
  });

  if (!response.ok) {
    return [];
  }

  const xml = await response.text();
  return parseRss(xml, source.name);
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return handleOptions();
  }

  if (req.method !== 'POST') {
    return json({ error: 'Method not allowed' }, 405);
  }

  try {
    const [hnResult, ...rssResults] = await Promise.allSettled([
      fetchHackerNews(),
      ...rssSources.map((source) => fetchRssSource(source)),
    ]);

    const merged: NewsItem[] = [];

    if (hnResult.status === 'fulfilled') {
      merged.push(...hnResult.value);
    }

    for (const result of rssResults) {
      if (result.status === 'fulfilled') {
        merged.push(...result.value);
      }
    }

    const deduplicated = new Map<string, NewsItem>();
    for (const item of merged) {
      if (!deduplicated.has(item.url)) {
        deduplicated.set(item.url, item);
      }
    }

    const items = [...deduplicated.values()]
      .sort((a, b) => b.published_at.localeCompare(a.published_at))
      .slice(0, maxItems);

    return json({
      fetched_at: new Date().toISOString(),
      items,
      sources: ['Hacker News', ...rssSources.map((source) => source.name)],
    });
  } catch (error) {
    return json(
      {
        error: error instanceof Error ? error.message : 'Unexpected error',
      },
      400,
    );
  }
});
