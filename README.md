# 📖 Daily Read

A tiny macOS menu bar app that gives you **one hand-picked AI article per day**.

Click the book icon in the menu bar and you get today's article: title, source and
reading time. Open it and it's marked as read (the icon fills in). Not in the mood for
that one? Hit **Shuffle** for a different pick. The goal is to learn a little about AI
every day without going down a rabbit hole of feeds and newsletters.

```
📖  ┌─────────────────────────────────┐
    │ Today's read                    │
    │ The Bitter Lesson               │
    │ Rich Sutton · ~5 min            │
    ├─────────────────────────────────┤
    │ Open article               ⌘O   │
    │ Shuffle                    ⌘S   │
    ├─────────────────────────────────┤
    │ 8 read · 22 left                │
    └─────────────────────────────────┘
```

## How it works

- **One file of Swift** (`DailyRead.swift`, ~200 lines, AppKit only, no dependencies).
- The article list is hardcoded in the `articles` array at the top of the file. One
  "batch" is a month's worth (~30 articles).
- Each day it picks a random unread article and sticks with it for that day.
  Missed days don't pile up: unread picks just go back into the pool.
- Read status and daily picks are saved in `UserDefaults`
  (`com.lukasschieber.dailyread`), keyed by URL, so swapping in a new batch keeps
  your history.
- It runs as a background LaunchAgent: starts at login and restarts if it ever
  quits. There's deliberately no Quit menu item.

## Install

Requires macOS 13+ and the Swift compiler (comes with Xcode or the Command Line
Tools: `xcode-select --install`).

```sh
git clone https://github.com/lukasschieber123/Daily-AI-read.git
cd Daily-AI-read
./build.sh
```

`build.sh` will:
1. refuse to build if any article URL appears twice,
2. compile `DailyRead.swift` into `~/Applications/DailyRead.app`,
3. ad-hoc sign it,
4. install a LaunchAgent in `~/Library/LaunchAgents/` and start the app.

The 📖 icon should appear in your menu bar right away.

> If you change `startDate` in `DailyRead.swift`, the app shows a
> "first read arrives…" message until that date. It's set to 2026-11-01, so it's
> live immediately.

### Uninstall

```sh
launchctl bootout gui/$(id -u)/com.lukasschieber.dailyread
rm ~/Library/LaunchAgents/com.lukasschieber.dailyread.plist
rm -rf ~/Applications/DailyRead.app
defaults delete com.lukasschieber.dailyread   # wipes read history
```

## Picking the articles

The list is the whole point, so it's curated by hand (with Claude's help). The
criteria:

- **Not beginner material.** Assumes you already know what an LLM is.
- **Articles only.** No videos or podcasts.
- **Readable.** Essays, explainers and research write-ups, not papers full of math.
- **Varied sources.** Batch 1 mixes Anthropic research/engineering posts with
  Ethan Mollick, Simon Willison, Andrej Karpathy, Dario Amodei, Dwarkesh Patel,
  METR, Understanding AI, *AI as Normal Technology* and Rich Sutton.
- **Every link verified** (HTTP 200 + real page title) before it goes in. Reading
  time is estimated from word count at ~250 wpm.
- **No repeats, ever.** [`ARTICLE_HISTORY.md`](ARTICLE_HISTORY.md) logs every article
  that has been in a batch.

See [`ADDING_A_BATCH.md`](ADDING_A_BATCH.md) for the step-by-step process of
refilling it when you run out. When everything is read, the menu says
"All N read 🎉 · Ask Claude for a new batch".

## Make it yours

Want a different topic (design, history, finance…)? Replace the `articles` array
with your own list, keep the same `Article(title:source:minutes:url:)` shape, and
run `./build.sh` again.

## Files

| File | What it is |
|---|---|
| `DailyRead.swift` | The whole app, including the article list |
| `build.sh` | Compile, sign, install the LaunchAgent, (re)start |
| `ARTICLE_HISTORY.md` | Every article ever used, so batches never repeat |
| `ADDING_A_BATCH.md` | How to add next month's articles |
