# Search and AI visibility

The one home for how a public website is found by search engines and AI assistants. It names
search engines, AI crawlers and their tools on purpose: a recorded exception to the plugin's rule
against product names, in the same way as hosting.md names hosting platforms. The names it may use
are the ones in this file.

Every outside fact here names its source number, as "(source 4)", from "Sources" at the end. Practice
without a source is marked as practice.

## Terms

- **public website**: pages that anyone can open without signing in and that are meant to be found.
  An app behind a sign-in is not one.
- **production domain**: the domain the public website is meant to live on.
- **test domain**: a domain for a version that is not the production one.
- **site-URL setting**: the one setting that every absolute URL of the site is built from.
- **canonical URL**: the per-page tag that names the one URL of that page.
- **crawler**: a program that fetches pages for a search engine or another service. An **AI
  crawler** is a crawler of an AI operator.
- **robots rules**: the rules in `robots.txt`, in a robots meta tag and in an `X-Robots-Tag` header.
- **indexable**: a page that robots rules allow into a search index, so it can be found in search.
- **search intent**: the one question or need behind a search. One page serves one search intent.

`Public website: yes` does not mean `Live site: yes`. A public website may still be unreleased.
Gate 15 stays tied to `Live site:` only.

## When it applies

- PROJECT.md, "Website and public presence", says `Public website: yes`, and the change touches
  the site: its pages, layout, head tags, content, routing, redirects, hosting, sitemap, robots
  rules or structured data.
- The field is missing, and the change touches files that serve public pages: ask once at stage
  1, "Is this a public website that should be found by search engines? Answer yes or no." Offer
  to write the line. Until a yes, this file does not apply.
- Which changes on a public website are visible: pipeline.md, "Visible change".
- The lead reads this file at stage 1 and 2 and passes its path to the reviewers (pipeline.md,
  "Which agent when"). A change with a gate 17 signal never takes the quick lane; in a quick-lane change without one,
  the stage 1 read and 5d still apply.
- There is no argument and no mode. Nothing here runs without a change.

Say once, at stage 1: "This change touches a public website. I check it against the search and AI
visibility list (seo-geo.md)." In chat, explain a term such as hreflang in a few words on first
use, or leave it out.

## PROJECT.md fields

The lines in setup.md, "Template", under "Website and public presence": `Public website:`,
`Site languages:`, `Production domain:`, `Test domain:`, `Search tool property:` and
`Title and description limits:`. Never guess a value: ask once, when it is first needed. The
search tool property is a name, never a password or a token.

## S1. Hard rules

1. No invented proof: design rule F5 (skills/design/references/tiers.md) is the rule, and gate 17
   stops a change that adds proof the owner did not give.
2. Every factual or legal claim on a page has a source that the owner or the lead read in the
   original. No source: the claim is not on the page.
3. A write to the production site or domain is gate 15. A change in indexability or robots rules,
   a change of the site-URL setting or a canonical URL to another host, publishing a draft and new
   proof are gate 17 (gates.md).
4. Robots rules hide nothing from people. Unreleased or private content needs a sign-in, and
   `robots.txt` never lists private paths.
5. Never sign in for the owner, never send a mail or a request to a third party, and never create
   an account or a listing in the owner's name. Draft the text; the owner acts.

## S2. Technical foundation

Practice, unless a fact is named.
1. Content is in the HTML the server sends. Google renders script in a later step (source 20), and
   some crawlers run no script at all (source 6). Design rule F8 covers visible content.
2. One canonical URL per page, absolute, built from the site-URL setting. The same build then
   works for the test domain and the production domain.
3. One URL form: one trailing-slash style, https only, one host (with or without `www`).
4. A missing page returns status 404 and a real error page.
5. Exactly one `h1` per page.
6. A unique title and meta description per page, written as an answer with a clear benefit.
   Google documents no character limit and may rewrite both (source 9). A project may set its own limits
   in `Title and description limits:`; they are the project's choice, never a search engine rule.
7. Robots meta for normal pages: `index,follow` and, for large image previews, `max-image-preview:large` (source 18).
8. A test build is `noindex,nofollow`, its `robots.txt` disallows all, and it shows a visible test
   banner. Changing that is gate 17.
9. Drafts are never built for production, never in the sitemap and never in a feed.
10. An XML sitemap generated at build, with `lastmod` (the last-changed date) from real change dates, and a generated
    `robots.txt` that names the sitemap URL from the site-URL setting.
11. Caching, https and error pages on the hosting platform: hosting.md. In short: long caching
    for fingerprinted assets (files whose name changes with their content), no caching for HTML.
12. Speed: preload the largest image above the fold, responsive images with width and height,
    self-hosted fonts. Core Web Vitals (load, response and layout-shift measures from real users):
    good is LCP 2.5 s or less, INP 200 ms or less, CLS 0.1 or less, at the 75th percentile (source 17).
13. Absolute asset paths (`/img/x.webp`), never relative: relative paths break in language folders.
14. Phone widths: design rule F6. Also check 768 and 1440 px.
15. Forms work without third-party scripts: a hidden field that only bots fill in, a minimum fill time and a
    rate limit.

## S3. Languages

1. `lang` on every page, with the region when it matters (`nl-BE`).
2. Slugs in the page's own language.
3. One route map: each page key with its path per language. Menus, hreflang and the sitemap read it.
4. hreflang (tags that link the language versions of one page): in HTML, in an HTTP header or in
   the sitemap; each version lists itself and every other version; return links are required, or
   the tags are ignored; `x-default` for no match; full URLs (source 12). Only for translations that exist.
5. A page without a translation has no hreflang; a link to it says its language, for example "(NL)".
6. Each language gets its own search research; a literal translation misses local search terms.
7. A native speaker reviews new translations (advice).

## S4. Structured data

1. One linked graph: each entity has an `@id`, for example `<site URL>/#organization`.
2. Organization on every page: legal name, address, contact, logo and `sameAs` links to the
   official profiles.
3. WebSite on the home page with `name` and `alternateName`, and `og:site_name` set to the same
   name: Google takes the site name in results mainly from this markup, on the home page only (source 10).
4. A page type only for what is on that page: software, service, article, blog post, about,
   contact, collection, video, glossary terms, breadcrumb.
5. FAQ markup only for questions that are visible on the page. Google shows no FAQ rich results
   any more (source 13): never promise one.
6. No review or rating markup without real reviews by others. Reviews on your own organization
   markup never get stars (source 14).
7. Validate the markup after each change, with a schema.org or Rich Results Test validator.

## S5. Content

1. Search research per language, from real sources such as search suggestions, saved as data.
2. A plan that maps each search intent to one page. No two pages on one search intent.
3. A focused page per important search intent, linked from the home page. The home page cannot be
   made to rank for one term (practice).
4. Answer first: the first sentence under the `h1` answers the page's question.
5. Questions written as real user questions; sources at the bottom of each article.
6. Internal links: every key page within two clicks of the home page, with descriptive link text.
7. One brand spelling everywhere.
8. Change the updated date only on a real change.
9. Explanations that stay true go into a knowledge base; dated news goes into a blog.

## S6. AI visibility

1. Robots rules for AI crawlers are the owner's choice. Ask only when the change touches robots
   rules or the owner asks about AI crawlers. List each token with its purpose:
   - OpenAI: GPTBot (training), OAI-SearchBot (ChatGPT search), ChatGPT-User (a fetch a user
     starts) (source 1).
   - Anthropic: ClaudeBot (training), Claude-SearchBot (search quality), Claude-User (a fetch a
     user starts) (source 2).
   - Perplexity: PerplexityBot (search results), Perplexity-User (a fetch a user starts) (source 3).
   - Google-Extended: Gemini training and grounding (basing answers on pages); it does not change
     Google Search (source 4).
   - Apple: Applebot (search features; its data may also help train Apple models),
     Applebot-Extended (a training opt-out that crawls nothing) (source 5).
   - Common Crawl: CCBot (source 6).
   Then ask one question: "allow all", "allow search and user fetches, block training", or
   "block all". There is no default. No answer: write no AI crawler rule. Robots rules may not stop
   a fetch that a user starts (sources 1 and 3). The robots change itself is gate 17.
2. `llms.txt` is optional: a Markdown file with an `h1` name, then an optional summary and link
   lists (source 7). Google says sites need no new AI text files for its AI features (source 8). Its effect is unproven.
3. The same name, address, contact and description on the site, in the markup and on every
   profile; `sameAs` to each official profile.
4. Short definitions, lists, tables and short sentences are easy to quote.
5. Mentions on other sites, directories and partner pages: the owner's work (S9).
6. Measuring: the owner can ask the main questions to AI assistants and log the answers over time.
   The skill runs nothing on its own.

## S7. Search appearance

1. Favicon: square, at least 8 x 8 px, larger than 48 x 48 px recommended, a `link rel="icon"`
   (or `apple-touch-icon`) in the home page head, crawlable, on a stable URL (source 11).
2. Site name: S4 item 3.
3. `og:image` at least 1200 px wide, with `og:title` and `og:description` (practice).

## S8. Search tools

The owner signs in and acts. The lead drafts the steps.
1. A domain property verified by DNS covers every subdomain and protocol.
2. Submit the sitemap; a first "Couldn't fetch" is common, so check again later (practice).
3. "Request indexing" has a daily limit with no published number (source 15): the most important pages
   first.
4. After a change to the site name, favicon or markup, ask for the home page to be indexed again.
5. A weekly look at indexed pages and search queries is a suggestion to the owner, not a task.
6. IndexNow: listed support from Bing, Naver, Seznam.cz, Yandex and Yep (source 19). Bing Webmaster
   Tools is the owner's choice.

## S9. Off-site authority

1. One document with ready descriptions (short and long, per language) and base data, so every
   listing says the same.
2. Business profiles, software directories, app store pages, social profiles, partner pages and
   press: each is the owner's action. The lead drafts texts and mails; it never sends them.

## S10. Domain move

1. Only the site-URL setting changes; nothing else names the domain. That change is gate 17, and
   the move on the production domain is gate 15 too.
2. A permanent redirect (301 or 308) from each old URL to its matching new URL, never many old URLs
   to one unrelated page. Redirect straight to the final URL and keep any chain short (source 16).
3. Keep the redirects at least 1 year. The site-move guide says at least 1 year, the Change of
   Address help says at least 180 days; this file takes the stricter value (source 16).
4. Google's Change of Address tool is for domain or subdomain moves, after the redirects are in
   place, by an owner of both properties (source 16). The lead drafts the steps; the owner does them.
5. Problems on the old site, such as a `noindex` on a live page, are fixed only with the owner's go
   (gate 15).

## Review points

The lead passes this file's path in stage 2 and 5d. Each point is yes or no on the plan or the
diff. BLOCKING only where it says so; the rest is ADJUST or advice.

Architect (stage 2):
- SEO-A1. All absolute URLs come from the site-URL setting.
- SEO-A2. One route map feeds menus, hreflang and the sitemap.
- SEO-A3. The plan names any gate 17 signal it contains.

Product expert (stage 2 and 5d):
- SEO-P1. No review, rating, quote, testimonial, customer logo, customer count, price or award
  that is not in the user's own words in the brief and not on the "Proof we have" list, if the
  project has one. A list line added in the same change counts only after the user's own typed
  confirmation (tiers.md). BLOCKING (gate 17).
- SEO-P2. No draft is built or published without the owner's typed answer to the gate 17
  question. BLOCKING (gate 17).
- SEO-P3. A change in indexability has the owner's typed answer to the gate 17 question, for
  this signal and scope. BLOCKING (gate 17).
- SEO-P4. Each factual or legal claim has a source in the page's sources or in the brief.
- SEO-P5. No new page shares a search intent with a page in the route map or the sitemap.
- SEO-P6. No promise of a FAQ rich result or of llms.txt effects.
- SEO-P7. Advice: the first sentence under the `h1` answers the page's question.

UI specialist (stage 2 and 5d, on a visible change, from the code):
- SEO-U1. Each changed page has a title and meta description, unique among the changed pages.
- SEO-U2. Each changed page has one `h1` in its source.
- SEO-U3. `lang` matches the page's language.
- SEO-U4. A link to an untranslated page says its language.
- SEO-U5. Every image has alt text (empty for decoration).
- SEO-U6. Asset paths are absolute.
- Check to run, for the lead: hreflang return links, the rendered `h1` count, the widths in S2
  item 14.

## Build check

A check that runs after each build. Only for a project with CI; adding it is a CI change, so the
CI rules and forced-high paths of gates.md apply. The lead runs only commands from confirmed
`Checks:` or `Preview:` lines. Write the script in the project's own language. A failure stops the
deploy.

Checks, on every page:
1. Each internal link points to an existing page; a link with a file extension to an existing file
   on disk.
2. Each image `src` and video `poster` is absolute, and the file exists.
3. hreflang targets exist and link back.
4. `lang` matches the language folder.
5. Exactly one `h1`.
6. Title and meta description present and unique. Their length only when `Title and description
   limits:` sets one; count after HTML-unescaping (`&#39;` is one character).
7. Optional: canonical present and absolute; JSON-LD parses as JSON; no `noindex` in a production
   build.

Result line: `pages: <n> | with hreflang: <n> | broken links: none | problems: none`, plus
`length check: off` when no limits are set.

Where the pages come from:
- A static site generator: read the HTML files in its output folder.
- A server-rendered site: start it locally with the confirmed `Preview:` command and fetch a fixed
  list of URLs on that local host only.
- A single-page app: check the pre-rendered or server HTML. Without it, the content is not in the
  HTML: say so, and point to S2 item 1.

## Known pitfalls

Project practice from one site, no source unless named.
1. The home page cannot be forced to rank for a term. A focused page for that search intent,
   linked from the home page, can.
2. A new favicon can return 404 for a while after a deploy, because of a cache. Check again before
   you debug.
3. A link check that knows only page folders flags root files such as `/favicon.ico`. Check files
   on disk.
4. A direct link into a search tool's URL inspection can fail; use its own search box.
5. "Request indexing" stops at a daily limit (source 15). Plan the rest for the next day.
6. The site name in results comes from the WebSite markup, not from the title (source 10).
7. Relative image paths break in language folders.

## Worked example

A bilingual static marketing site, built by a static site generator, with a knowledge base and a
blog. A focused page per important search intent, one route map for both languages, generated
sitemap and robots rules, the build check in CI, and a test domain that stayed `noindex` until the
owner chose otherwise. Practice from one project, not a rule.

## Sources

All read on 2026-11-14, in two check runs (research.md). Each line: `source:` and `valid:`.
- Source 1. source: https://developers.openai.com/api/docs/bots valid: 2026-11-14 to 2027-05-14
- Source 2. source: https://support.claude.com/en/articles/8896518-does-anthropic-crawl-data-from-the-web-and-how-can-site-owners-block-the-crawler valid: 2026-11-14 to 2027-05-14
- Source 3. source: https://docs.perplexity.ai/guides/bots valid: 2026-11-14 to 2027-05-14
- Source 4. source: https://developers.google.com/search/docs/crawling-indexing/google-common-crawlers valid: 2026-11-14 to 2027-05-14
- Source 5. source: https://support.apple.com/en-us/119829 valid: 2026-11-14 to 2027-05-14
- Source 6. source: https://commoncrawl.org/faq valid: 2026-11-14 to 2027-05-14
- Source 7. source: https://llmstxt.org/ valid: 2026-11-14 to 2027-05-14
- Source 8. source: https://developers.google.com/search/docs/appearance/ai-features valid: 2026-11-14 to 2027-05-14
- Source 9. source: https://developers.google.com/search/docs/appearance/title-link and https://developers.google.com/search/docs/appearance/snippet valid: 2026-11-14 to 2027-05-14
- Source 10. source: https://developers.google.com/search/docs/appearance/site-names valid: 2026-11-14 to 2027-05-14
- Source 11. source: https://developers.google.com/search/docs/appearance/favicon-in-search valid: 2026-11-14 to 2027-05-14
- Source 12. source: https://developers.google.com/search/docs/specialty/international/localized-versions valid: 2026-11-14 to 2027-05-14
- Source 13. source: https://developers.google.com/search/docs/appearance/structured-data/faqpage valid: 2026-11-14 to 2027-05-14
- Source 14. source: https://developers.google.com/search/docs/appearance/structured-data/review-snippet valid: 2026-11-14 to 2027-05-14
- Source 15. source: https://support.google.com/webmasters/answer/9012289 valid: 2026-11-14 to 2027-05-14
- Source 16. source: https://developers.google.com/search/docs/crawling-indexing/site-move-with-url-changes (at least 1 year) and https://support.google.com/webmasters/answer/9370220 (at least 180 days) valid: 2026-11-14 to 2027-05-14
- Source 17. source: https://web.dev/articles/vitals and https://developers.google.com/search/docs/appearance/core-web-vitals valid: 2026-11-14 to 2027-05-14
- Source 18. source: https://developers.google.com/search/docs/crawling-indexing/robots-meta-tag valid: 2026-11-14 to 2027-05-14
- Source 19. source: https://www.indexnow.org/ valid: 2026-11-14 to 2027-05-14
- Source 20. source: https://developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics valid: 2026-11-14 to 2027-05-14
