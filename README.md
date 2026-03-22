# FreshRSS Reader Claw Skill

This is an AI Assistant CLI skill that provides a complete interface to query and interact with a self-hosted FreshRSS instance. It utilizes the Google Reader compatible API to fetch feeds, search articles, mark them as read, star favorites, and retrieve the latest news.

The core logic is implemented in a Bash script (`scripts/freshrss.sh`), which is packaged as a skill via the `SKILL.md` and `_meta.json` files.

## Fork Details

This project is an advanced fork of the original FreshRSS Reader skill by `nickian`, which can be found at:
[https://github.com/openclaw/skills/tree/main/skills/nickian/freshrss-reader](https://github.com/openclaw/skills/tree/main/skills/nickian/freshrss-reader)

This modernized repository enhances the original functionality with:
- Client-side keyword string search and filtering via `jq`
- Specifying individual feeds for headlines
- Fetching exclusively starred (favorite) articles
- Starring and unstarring articles via the `edit-tag` endpoint
- Manually marking specific articles as read via a command

## Usage & Integration

See [SKILL.md](./SKILL.md) for detailed configuration, commands, and functionality that your AI Assistant can execute.
