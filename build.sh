#!/bin/zsh
# Compiles DailyRead.swift into ~/Applications/DailyRead.app and (re)launches it.
set -e
cd "$(dirname "$0")"
APP=~/Applications/DailyRead.app
# Refuse to build if any article link appears twice.
DUPES=$(grep -o 'url: "[^"]*"' DailyRead.swift | sort | uniq -d)
if [[ -n "$DUPES" ]]; then echo "Duplicate articles:\n$DUPES"; exit 1; fi
mkdir -p "$APP/Contents/MacOS"
swiftc -O DailyRead.swift -o "$APP/Contents/MacOS/DailyRead"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleName</key><string>Daily Read</string>
  <key>CFBundleIdentifier</key><string>com.lukasschieber.dailyread</string>
  <key>CFBundleExecutable</key><string>DailyRead</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSUIElement</key><true/>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
</dict></plist>
PLIST
codesign --force --sign - "$APP"
# Runs under launchd (starts at login, restarts if it ever quits).
AGENT=~/Library/LaunchAgents/com.lukasschieber.dailyread.plist
mkdir -p ~/Library/LaunchAgents
cat > "$AGENT" <<AGENTPLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>com.lukasschieber.dailyread</string>
  <key>ProgramArguments</key><array><string>$APP/Contents/MacOS/DailyRead</string></array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
</dict></plist>
AGENTPLIST
pkill -x DailyRead || true
launchctl bootout gui/$(id -u)/com.lukasschieber.dailyread 2>/dev/null || true
launchctl bootstrap gui/$(id -u) "$AGENT"
