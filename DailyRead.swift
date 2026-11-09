// DailyRead — a menu bar app that serves one hand-picked AI article per day.
// Build: ./build.sh  (compiles into ~/Applications/DailyRead.app)

import AppKit

struct Article {
    let title: String
    let source: String
    let minutes: Int
    let url: String
}

// Hand-picked for November 2026. Every link was checked on 2026-10-29.
let articles: [Article] = [
    Article(title: "Tracing the thoughts of a large language model", source: "Anthropic", minutes: 13, url: "https://www.anthropic.com/research/tracing-thoughts-language-model"),
    Article(title: "Mapping the mind of a large language model", source: "Anthropic", minutes: 8, url: "https://www.anthropic.com/research/mapping-mind-language-model"),
    Article(title: "Claude's character", source: "Anthropic", minutes: 7, url: "https://www.anthropic.com/research/claude-character"),
    Article(title: "Alignment faking in large language models", source: "Anthropic", minutes: 9, url: "https://www.anthropic.com/research/alignment-faking"),
    Article(title: "Effective context engineering for AI agents", source: "Anthropic", minutes: 13, url: "https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents"),
    Article(title: "Writing effective tools for AI agents", source: "Anthropic", minutes: 13, url: "https://www.anthropic.com/engineering/writing-tools-for-agents"),
    Article(title: "Project Vend: Can Claude run a small shop?", source: "Anthropic", minutes: 11, url: "https://www.anthropic.com/research/project-vend-1"),
    Article(title: "How we built our multi-agent research system", source: "Anthropic", minutes: 15, url: "https://www.anthropic.com/engineering/multi-agent-research-system"),
    Article(title: "Agentic misalignment: LLMs as insider threats", source: "Anthropic", minutes: 30, url: "https://www.anthropic.com/research/agentic-misalignment"),
    Article(title: "Reasoning models don't always say what they think", source: "Anthropic", minutes: 8, url: "https://www.anthropic.com/research/reasoning-models-dont-say-think"),
    Article(title: "Emergent introspective awareness in LLMs", source: "Anthropic", minutes: 15, url: "https://www.anthropic.com/research/introspection"),
    Article(title: "Natural emergent misalignment from reward hacking", source: "Anthropic", minutes: 8, url: "https://www.anthropic.com/research/emergent-misalignment-reward-hacking"),
    Article(title: "Disrupting an AI-orchestrated cyber espionage campaign", source: "Anthropic", minutes: 6, url: "https://www.anthropic.com/news/disrupting-AI-espionage"),
    Article(title: "Auditing language models for hidden objectives", source: "Anthropic", minutes: 12, url: "https://www.anthropic.com/research/auditing-hidden-objectives"),
    Article(title: "Claude's constitution", source: "Anthropic", minutes: 14, url: "https://www.anthropic.com/news/claudes-constitution"),
    Article(title: "Machines of Loving Grace", source: "Dario Amodei", minutes: 60, url: "https://darioamodei.com/essay/machines-of-loving-grace"),
    Article(title: "The Urgency of Interpretability", source: "Dario Amodei", minutes: 19, url: "https://darioamodei.com/post/the-urgency-of-interpretability"),
    Article(title: "Centaurs and Cyborgs on the Jagged Frontier", source: "Ethan Mollick", minutes: 9, url: "https://www.oneusefulthing.org/p/centaurs-and-cyborgs-on-the-jagged"),
    Article(title: "On Working with Wizards", source: "Ethan Mollick", minutes: 9, url: "https://www.oneusefulthing.org/p/on-working-with-wizards"),
    Article(title: "The Shape of AI: Jaggedness, Bottlenecks and Salients", source: "Ethan Mollick", minutes: 8, url: "https://www.oneusefulthing.org/p/the-shape-of-ai-jaggedness-bottlenecks"),
    Article(title: "Thinking Like an AI", source: "Ethan Mollick", minutes: 10, url: "https://www.oneusefulthing.org/p/thinking-like-an-ai"),
    Article(title: "AI as Normal Technology", source: "Narayanan & Kapoor", minutes: 70, url: "https://www.normaltech.ai/p/ai-as-normal-technology"),
    Article(title: "The lethal trifecta for AI agents", source: "Simon Willison", minutes: 7, url: "https://simonwillison.net/2025/Jun/16/the-lethal-trifecta/"),
    Article(title: "2025: The year in LLMs", source: "Simon Willison", minutes: 30, url: "https://simonwillison.net/2025/Dec/31/the-year-in-llms/"),
    Article(title: "Animals vs Ghosts", source: "Andrej Karpathy", minutes: 7, url: "https://karpathy.bearblog.dev/animals-vs-ghosts/"),
    Article(title: "Verifiability", source: "Andrej Karpathy", minutes: 2, url: "https://karpathy.bearblog.dev/verifiability/"),
    Article(title: "The Bitter Lesson", source: "Rich Sutton", minutes: 5, url: "http://www.incompleteideas.net/IncIdeas/BitterLesson.html"),
    Article(title: "Why I don't think AGI is right around the corner", source: "Dwarkesh Patel", minutes: 11, url: "https://www.dwarkesh.com/p/timelines-june-2025"),
    Article(title: "Measuring AI ability to complete long tasks", source: "METR", minutes: 9, url: "https://metr.org/blog/2025-03-19-measuring-ai-ability-to-complete-long-tasks/"),
    Article(title: "Why large language models struggle with long contexts", source: "Understanding AI", minutes: 13, url: "https://www.understandingai.org/p/why-large-language-models-struggle"),
]

let startDate = "2026-11-01"

// Persistent state in UserDefaults: which articles are read, and which article belongs to which day.
final class Store {
    private let defaults = UserDefaults.standard

    var readURLs: Set<String> {
        get { Set(defaults.stringArray(forKey: "readURLs") ?? []) }
        set { defaults.set(Array(newValue), forKey: "readURLs") }
    }

    // "yyyy-MM-dd" -> article url
    var picks: [String: String] {
        get { defaults.dictionary(forKey: "picks") as? [String: String] ?? [:] }
        set { defaults.set(newValue, forKey: "picks") }
    }

    var unread: [Article] { articles.filter { !readURLs.contains($0.url) } }

    func todayKey() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    // Today's article: the one already picked for today, else a random unread one.
    func todaysArticle() -> Article? {
        let key = todayKey()
        if let url = picks[key], let a = articles.first(where: { $0.url == url }) { return a }
        guard let a = unread.randomElement() else { return nil }
        picks[key] = a.url
        return a
    }

    func isReadToday() -> Bool {
        guard let url = picks[todayKey()] else { return false }
        return readURLs.contains(url)
    }

    func shuffle() {
        let current = picks[todayKey()]
        let options = unread.filter { $0.url != current }
        guard let a = options.randomElement() else { return }
        picks[todayKey()] = a.url
    }

    func markRead(_ a: Article) { readURLs.insert(a.url) }
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem!
    private let store = Store()
    private let menu = NSMenu()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        menu.delegate = self
        statusItem.menu = menu
        updateIcon()
        // Refresh the icon periodically so it resets after midnight.
        Timer.scheduledTimer(withTimeInterval: 600, repeats: true) { [weak self] _ in self?.updateIcon() }
    }

    private var hasStarted: Bool { store.todayKey() >= startDate }

    private func updateIcon() {
        let done = hasStarted && (store.isReadToday() || store.unread.isEmpty)
        let image = NSImage(systemSymbolName: done ? "book.fill" : "book", accessibilityDescription: "Daily Read")
        image?.isTemplate = true
        statusItem.button?.image = image
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()

        if !hasStarted {
            menu.addItem(label("Your first read arrives Sun, Nov 1"))
        } else if let a = store.todaysArticle() {
            let read = store.readURLs.contains(a.url)
            menu.addItem(label(read ? "✓ Today's read" : "Today's read"))

            let titleItem = NSMenuItem(title: "", action: #selector(openArticle), keyEquivalent: "")
            titleItem.target = self
            titleItem.attributedTitle = articleTitle(a)
            menu.addItem(titleItem)

            menu.addItem(.separator())
            let open = NSMenuItem(title: read ? "Open again" : "Open article", action: #selector(openArticle), keyEquivalent: "o")
            open.target = self
            menu.addItem(open)
            if !read && store.unread.count > 1 {
                let shuffle = NSMenuItem(title: "Shuffle", action: #selector(shuffleArticle), keyEquivalent: "s")
                shuffle.target = self
                menu.addItem(shuffle)
            }
        } else {
            menu.addItem(label("All \(articles.count) read 🎉"))
            menu.addItem(label("Ask Claude for a new batch"))
        }

        menu.addItem(.separator())
        let readCount = articles.count - store.unread.count
        menu.addItem(label("\(readCount) read · \(store.unread.count) left"))
    }

    private func label(_ text: String) -> NSMenuItem {
        let item = NSMenuItem(title: text, action: nil, keyEquivalent: "")
        item.isEnabled = false
        return item
    }

    private func articleTitle(_ a: Article) -> NSAttributedString {
        let s = NSMutableAttributedString(string: a.title + "\n", attributes: [.font: NSFont.boldSystemFont(ofSize: 13)])
        s.append(NSAttributedString(string: "\(a.source) · ~\(a.minutes) min", attributes: [
            .font: NSFont.systemFont(ofSize: 11),
            .foregroundColor: NSColor.secondaryLabelColor,
        ]))
        return s
    }

    @objc private func openArticle() {
        guard let a = store.todaysArticle(), let url = URL(string: a.url) else { return }
        NSWorkspace.shared.open(url)
        store.markRead(a)
        updateIcon()
    }

    @objc private func shuffleArticle() {
        store.shuffle()
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
