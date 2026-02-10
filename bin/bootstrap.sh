#!/bin/bash
# --- M3 Headless AWS Architect Bootstrap (macOS 26.x Optimized) ---
# Target: MacBook Air M3 (16GB RAM) - Headless via SSH/Tailscale

set -e

# --- 1. System Identity ---
echo "⚙️  Configuring System Identity..."
sudo scutil --set ComputerName "M3-Headless-UCSD"
sudo scutil --set HostName "M3-Headless-UCSD"
sudo scutil --set LocalHostName "M3-Headless-UCSD"

# --- 2. Headless Xcode Tooling ---
if ! xcode-select -p &> /dev/null; then
    echo "🛠️  Installing Xcode Command Line Tools (Headless Fix)..."
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n')
    sudo softwareupdate -i "$PROD" --verbose
    rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
fi

# --- 3. Persistence Daemon ---
if [ ! -f /Library/LaunchDaemons/com.headless.caffeinate.plist ]; then
    echo "☕ Creating Caffeinate Engine..."
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
fi

# --- 4. Remote & Power Management ---
echo "🖥️  Activating Remote Management..."
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
-activate -configure -access -on -privs -all -restart -agent
sudo systemsetup -setremotelogin on
sudo pmset -a sleep 0 displaysleep 0 disksleep 0 womp 1 autorestart 1 disablesleep 1

# --- 5. Tooling: Homebrew & Path Setup ---
if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Setup PATH for current session
    eval "$(/opt/homebrew/bin/brew shellenv)"

    # Idempotent path injection for ALL shell types
    for rcfile in "$HOME/.zprofile" "$HOME/.zshrc"; do
        if [ -f "$rcfile" ] && ! grep -q "brew shellenv" "$rcfile"; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$rcfile"
        elif [ ! -f "$rcfile" ]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$rcfile"
        fi
    done
fi

# --- 6. AWS Architect Core Stack ---
echo "📦 Installing Architect Suite..."
brew update
# --- 6. AWS Architect Core Stack ---
echo "📦 Installing Architect Suite via Brewfile..."
# This command reads your Brewfile and installs EVERYTHING listed at once
brew bundle --file=Brewfile-headless-M3

# --- 7. Architecture Configuration (SSH-over-SSM) ---
echo "🔗 Configuring SSH-over-SSM..."
mkdir -p ~/.ssh
if [ ! -f ~/.ssh/config ] || ! grep -q "AWS-StartSSMConversationStream" ~/.ssh/config 2>/dev/null; then
cat <<EOF >> ~/.ssh/config

# AWS SSM Tunneling configuration
host i-* mi-*
    ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSMConversationStream --parameters 'portNumber=%p'"
EOF
fi

# --- 8. Persistence & Helper Shortcuts ---
echo "🔄 Finalizing Helper Scripts..."

# FileVault Remote Reboot
cat <<'EOF' | sudo tee /usr/local/bin/remote-reboot
#!/bin/bash
printf "\033[1;33mChecking Power Status...\033[0m\n"
pmset -g batt
printf "\033[1;34mInitiating Authenticated Restart (FileVault Bypass)...\033[0m\n"
sudo fdesetup authrestart
EOF
sudo chmod +x /usr/local/bin/remote-reboot

# Rig Status
cat <<'EOF' | sudo tee /usr/local/bin/rig-status
#!/bin/bash
printf "\033[1;34m--- M3 Architecture Stats ---\033[0m\n"
sysctl -n machdep.cpu.brand_string
printf "\033[1;34m--- Thermal State ---\033[0m\n"
sudo powermetrics --samplers thermal --count 1 | grep "Thermal level"
printf "\033[1;34m--- Memory Pressure ---\033[0m\n"
memory_pressure | tail -n 1
EOF
sudo chmod +x /usr/local/bin/rig-status

echo "✅ ALL SYSTEMS BOOTSTRAPPED."
