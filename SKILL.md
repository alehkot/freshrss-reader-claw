---
name: freshrss
description: Query and interact with articles from a self-hosted FreshRSS instance. Use when the user asks for RSS news, latest headlines, feed updates, or wants to read, search, star, or mark articles as read from their FreshRSS reader. Supports filtering by keyword search, specific feed, category, time range, starred status, and unread.
---

# FreshRSS

Query headlines from a self-hosted FreshRSS instance via the Google Reader compatible API.

## Setup

Set these environment variables:

```bash
export FRESHRSS_URL="https://your-freshrss-instance.com"
export FRESHRSS_USER="your-username"
export FRESHRSS_API_PASSWORD="your-api-password"
```

API password is set in FreshRSS → Settings → Profile → API Management.

## Commands

### Get latest headlines

```bash
{baseDir}/scripts/freshrss.sh headlines --count 10
```

### Get headlines from the last N hours

```bash
{baseDir}/scripts/freshrss.sh headlines --hours 2
```

### Get headlines from a specific category

```bash
{baseDir}/scripts/freshrss.sh headlines --category "Technology" --count 15
```

### Get only unread headlines

```bash
{baseDir}/scripts/freshrss.sh headlines --unread --count 20
```

### Search by Keyword

```bash
{baseDir}/scripts/freshrss.sh headlines --search "apple" --count 50
```

### Get headlines from a specific feed

```bash
{baseDir}/scripts/freshrss.sh headlines --feed "123"
```

### Get starred (favorite) articles

```bash
{baseDir}/scripts/freshrss.sh headlines --starred
```

### Combine filters

```bash
{baseDir}/scripts/freshrss.sh headlines --category "News" --hours 4 --count 10 --search "tech" --unread
```

### List categories

```bash
{baseDir}/scripts/freshrss.sh categories
```

### List feeds

```bash
{baseDir}/scripts/freshrss.sh feeds
```

### Mark article as read

Requires the article ID from the `headlines` command.
```bash
{baseDir}/scripts/freshrss.sh mark-read "ID_STRING"
```

### Star an article

Requires the article ID from the `headlines` command.
```bash
{baseDir}/scripts/freshrss.sh star "ID_STRING"
```

### Unstar an article

Requires the article ID from the `headlines` command.
```bash
{baseDir}/scripts/freshrss.sh unstar "ID_STRING"
```

## Output

Headlines are formatted as:
```
[date] [source] Title
  ID: tag:google.com,2005:reader/item/0000000000000001
  URL: https://example.com/article
  Categories: cat1, cat2
```

## Notes

- Default count is 20 headlines if not specified
- Keyword searching (`--search`) checks article titles and content. Useful to fetch a larger `--count` when searching.
- Time filtering uses `--hours` for relative time (e.g., last 2 hours)
- Category names are case-sensitive and must match your FreshRSS categories
- Use `categories` command first to see available category names
- Use `feeds` command to see available feeds and their IDs
