/** Map app / BCP47 tags to Stripe Checkout & Billing Portal `locale` values. */
export function stripeUiLocale(raw: unknown): string | undefined {
  if (raw == null) return undefined;
  const s = String(raw).toLowerCase().trim();
  if (!s) return undefined;

  const exact: Record<string, string> = {
    en: 'en',
    'en-us': 'en',
    'en-gb': 'en',
    it: 'it',
    'it-it': 'it',
    de: 'de',
    'de-de': 'de',
    fr: 'fr',
    'fr-fr': 'fr',
    ru: 'ru',
    'ru-ru': 'ru',
    zh: 'zh',
    'zh-cn': 'zh',
    'zh-hans': 'zh',
    'zh-hant': 'zh',
    'zh-tw': 'zh-TW',
  };

  if (exact[s]) return exact[s];

  const primary = s.split(/[-_]/)[0];
  const fromPrimary: Record<string, string> = {
    en: 'en',
    it: 'it',
    de: 'de',
    fr: 'fr',
    ru: 'ru',
    zh: 'zh',
  };

  return fromPrimary[primary];
}
