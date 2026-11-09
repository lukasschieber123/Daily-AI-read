# Adding a new batch

A batch is one month's supply (30–31 articles). Doing this with Claude works well:
point it at this file and `ARTICLE_HISTORY.md`.

1. **Read `ARTICLE_HISTORY.md` first.** Nothing listed there may be added again.
   `build.sh` also refuses to build if a URL appears twice in `DailyRead.swift`.
2. **Check what's still unread:**
   ```sh
   defaults read com.lukasschieber.dailyread readURLs
   ```
   Keep unread leftovers in the `articles` array (they're already in the history,
   that's fine), remove the ones you've read, and add enough new ones to cover the
   coming month.
3. **Keep the source mix varied.** Batch 1 was about half Anthropic, so lean on other
   writers next time.
4. **Verify every link** with curl (status 200 and a real `<title>`), and estimate
   minutes from word count (~250 wpm). Medium and openai.com block curl (403), so
   skip them unless you can verify them another way. Never add an unverified URL.
5. **Log it:** append the new articles to `ARTICLE_HISTORY.md` under a new
   `## Batch N — <Month Year>` heading.
6. Update the comment above `articles` in `DailyRead.swift` (the menu counts update
   on their own), then run `./build.sh`.
