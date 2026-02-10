#!/bin/bash
# --- M3 Headless AWS Architect Bootstrap (macOS 26.x Optimized) ---
# Target: MacBook Air M3 (16GB RAM) - Headless via SSH/Tailscale

set -e # Exit on error

# --- 1. System Identity ---
echo "⚙️  Configuring System Identity..."
sudo scutil --set ComputerName "M3-Headless-UCSD"
sudo scutil --set HostName "M3-Headless-UCSD"
sudo scutil --set LocalHostName "M3-Headless-UCSD"

# --- 2. Headless Xcode Tooling (The Fix for 'git' and 'brew') ---
if ! xcode-select -p &> /dev/null; then
    echo "🛠️  Installing Xcode Command Line Tools (Headless Fix)..."
    # Create the placeholder to bypass the GUI dialog requirement
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    # Identify the specific CLT update available for this OS version
    PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n')
    sudo softwareupdate -i "$PROD" --verbose
    rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
fi

# --- 3. Persistence Daemon (Caffeinate Engine) ---
echo "☕ Ensuring M3 remains awake during long infrastructure applies..."
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

# --- 4. Remote & Power Management ---
echo "🖥️  Activating Remote Management & Power Policies..."
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
-activate -configure -access -on -privs -all -restart -agent
sudo systemsetup -setremotelogin on
# Set policies: No sleep, wake on network, auto-restart on power failure
sudo pmset -a sleep 0 displaysleep 0 disksleep 0 womp 1 autorestart 1 disablesleep 1

# --- 5. Tooling: Homebrew & Path Setup ---
if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Inject PATH immediately so the rest of the script can use 'brew'
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# --- 6. AWS Architect Core Stack ---
echo "📦 Installing Architect Suite (ARM64 Native)..."
# Granted: For multi-account SSO management
# Colima/Docker: For local container testing headlessly
brew install awscli aws-session-manager-plugin opentofu terragrunt jq yq granted colima docker

# --- 7. Architecture Configuration (SSH-over-SSM) ---
echo "🔗 Configuring SSH-over-SSM for Private VPC access..."
mkdir -p ~/.ssh
cat <<EOF >> ~/.ssh/config

# AWS SSM Tunneling configuration
host i-* mi-*
    ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSMConversationStream --parameters 'portNumber=%p'"
EOF

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

# Rig Status: Thermal and Memory Monitor (Essential for M3 Air)
cat <<'EOF' | sudo tee /usr/local/bin/rig-status
#!/bin/bash
printf "\033[1;34m--- M3 Architecture Stats ---\033[0m\n"
sysctl -n machdep.cpu.brand_string
printf "\033[1;34m--- Thermal State (Air Passive Cooling) ---\033[0m\n"
sudo powermetrics --samplers thermal --count 1 | grep "Thermal level"
printf "\033[1;34m--- Memory Pressure (16GB RAM) ---\033[0m\n"
memory_pressure | tail -n 1
EOF
sudo chmod +x /usr/local/bin/rig-status

echo "✅ ALL SYSTEMS BOOTSTRAPPED."
echo "-------------------------------------------------------"
echo "ARCHITECT NOTES:"
echo "1. Run 'rig-status' to check M3 thermals under load."
echo "2. Use 'remote-reboot' to bypass FileVault when updating."
echo "3. Tailscale should be configured next to secure ingress."
echo "-------------------------------------------------------"
