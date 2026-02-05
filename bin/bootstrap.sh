#!/bin/bash
# Headless Bootstrap & Persistence Master Script

# --- 1. System Identity ---
echo "⚙️  Configuring System Identity..."
sudo scutil --set ComputerName "M3-Headless-UCSD"
sudo scutil --set HostName "M3-Headless-UCSD"
sudo scutil --set LocalHostName "M3-Headless-UCSD"

# --- 2. Persistence Daemon (The 'Caffeinate' Engine) ---
echo "☕ Creating Persistence Daemon..."
cat <<EOF | sudo tee /Library/LaunchDaemons/com.headless.caffeinate.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.headless.caffeinate</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/caffeinate</string>
        <string>-dimsu</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF
sudo launchctl load -w /Library/LaunchDaemons/com.headless.caffeinate.plist

# --- 3. Remote Management (kickstart) ---
echo "🖥️  Activating Remote Management..."
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
-activate -configure -access -on -privs -all -restart -agent
sudo systemsetup -setremotelogin on

# --- 4. Power Management (pmset) ---
echo "⚡ Setting Power Policies..."
sudo pmset -a sleep 0 displaysleep 0 disksleep 0 womp 1 autorestart 1 disablesleep 1

# --- 5. FileVault 'AuthRestart' Shortcut ---
echo "🔄 Creating Remote-Reboot helper..."
cat <<'EOF' | sudo tee /usr/local/bin/remote-reboot
#!/bin/bash
echo "Initiating Authenticated Restart (FileVault Bypass)..."
echo "You will be prompted for your macOS password to authorize the next boot."
sudo fdesetup authrestart
EOF
sudo chmod +x /usr/local/bin/remote-reboot

# --- 6. Tooling (Homebrew & Tailscale) ---
if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
echo "📦 Installing Tailscale & NoMachine..."
brew install --cask tailscale nomachine

echo "✅ ALL SYSTEMS BOOTSTRAPPED."
echo "-------------------------------------------------------"
echo "HOW TO REBOOT REMOTELY:"
echo "Simply type 'remote-reboot' in your terminal."
echo "This will use FileVault AuthRestart so it doesn't get stuck."
echo "-------------------------------------------------------"
