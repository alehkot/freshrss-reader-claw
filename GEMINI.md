# FreshRSS Reader Skill

## Project Overview
This project is a Gemini CLI skill that provides an interface to query headlines and articles from a self-hosted FreshRSS instance. It utilizes the Google Reader compatible API to fetch feeds, categories, and latest news. The core logic is implemented in a Bash script (`scripts/freshrss.sh`), which is packaged as a skill via the `SKILL.md` and `_meta.json` files.

## Directory Overview & Key Files
- `_meta.json`: Contains metadata about the skill, including its owner (`nickian`), slug (`freshrss-reader`), and version information.
- `SKILL.md`: Defines the skill for the Gemini CLI, including its prompt description, setup instructions, and available commands.
- `scripts/freshrss.sh`: The primary executable Bash script that authenticates and performs API requests to the FreshRSS instance using `curl`, then parses the JSON responses with `jq`.

## Configuration & Setup
To use this project, the following environment variables must be exported for authentication:
- `FRESHRSS_URL`: The URL of your self-hosted FreshRSS instance (e.g., `https://freshrss.example.com`).
- `FRESHRSS_USER`: Your FreshRSS username.
- `FRESHRSS_API_PASSWORD`: Your FreshRSS API password (this needs to be configured in FreshRSS → Settings → Profile → API Management).

## Usage & Commands
The `scripts/freshrss.sh` script exposes several commands to interact with RSS feeds:

### Get Latest Headlines
Retrieve the latest articles (default is 20 if `--count` is omitted):
```bash
./scripts/freshrss.sh headlines --count 10
```

### Filter by Time Range
Get headlines published within the last specified number of hours:
```bash
./scripts/freshrss.sh headlines --hours 2
```

### Filter by Category
Fetch headlines from a specific category (case-sensitive):
```bash
./scripts/freshrss.sh headlines --category "Technology"
```

### Get Unread Articles Only
```bash
./scripts/freshrss.sh headlines --unread
```

*Note: Filters can be combined, for example:* `./scripts/freshrss.sh headlines --category "News" --hours 4 --unread`

### List Categories
List all available category tags:
```bash
./scripts/freshrss.sh categories
```

### List Feeds
List all subscribed feeds and their associated categories:
```bash
./scripts/freshrss.sh feeds
```

## System Requirements
- `curl`: For making HTTP requests to the FreshRSS API.
- `jq`: For parsing and formatting the JSON responses.
