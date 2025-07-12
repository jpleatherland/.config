#!/bin/bash

set -e

echo "🛠 Updating system..."
sudo apt update && sudo apt upgrade -y

echo "📦 Installing core dependencies..."
sudo apt install -y curl git unzip build-essential software-properties-common gnupg ca-certificates wget clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev xz-utils zip libglu1-mesa jq

echo "🌱 Installing Bun (https://bun.sh)..."
if ! command -v bun >/dev/null 2>&1; then
  curl -fsSL https://bun.sh/install | bash
  echo "✅ Bun installed"
else
  echo "✅ Bun is already installed"
fi

# Add Bun to PATH
BUN_PATH='export PATH="$HOME/.bun/bin:$PATH"'
SHELL_RC="$HOME/.bashrc"
[[ "$SHELL" == *zsh ]] && SHELL_RC="$HOME/.zshrc"

if ! grep -qF "$BUN_PATH" "$SHELL_RC"; then
  echo "$BUN_PATH" >> "$SHELL_RC"
  echo "✅ Added Bun to PATH in $SHELL_RC"
else
  echo "✅ Bun already in PATH in $SHELL_RC"
fi

echo "📎 Creating shims for node, npm, and npx..."
create_shim() {
  local name="$1"
  local target="$2"
  local shim_path="/usr/local/bin/$name"
  echo "#!/bin/bash" | sudo tee "$shim_path" > /dev/null
  echo "exec $target \"\$@\"" | sudo tee -a "$shim_path" > /dev/null
  sudo chmod +x "$shim_path"
  echo "✔️  Created shim: $shim_path → $target"
}
create_shim "node" "bun"
create_shim "npm" "bun"
create_shim "npx" "bunx"

echo "✅ Bun is now your system-wide node/npm/npx"

echo "🐹 Installing Go (latest stable)..."
GO_LATEST=$(curl -s https://go.dev/VERSION?m=text | head -n1)
echo "Latest Go version is $GO_LATEST"
wget "https://dl.google.com/go/${GO_LATEST}.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "${GO_LATEST}.linux-amd64.tar.gz"
rm "${GO_LATEST}.linux-amd64.tar.gz"
if ! grep -q '/usr/local/go/bin' ~/.profile; then
  echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
fi

echo "🦋 Installing Flutter (latest stable)..."
# Ensure jq is available
if ! command -v jq >/dev/null 2>&1; then
  echo "📦 Installing jq (required for Flutter version check)..."
  sudo apt install -y jq
fi

# Get latest Flutter stable release archive URL
FLUTTER_JSON=$(curl -s https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json)
FLUTTER_VERSION=$(echo "$FLUTTER_JSON" | jq -r '.current_release.stable')
FLUTTER_ARCHIVE=$(echo "$FLUTTER_JSON" | jq -r ".releases[] | select(.hash == \"$FLUTTER_VERSION\") | .archive")
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/$FLUTTER_ARCHIVE"

# Download and extract
echo "⬇️  Downloading Flutter from $FLUTTER_URL..."
curl -LO "$FLUTTER_URL"
sudo tar -C /opt -xf flutter_linux_*.*
rm flutter_linux_*.*

# Add to PATH
FLUTTER_PATH='export PATH="$PATH:/opt/flutter/bin"'
if ! grep -qF "$FLUTTER_PATH" "$SHELL_RC"; then
  echo "$FLUTTER_PATH" >> "$SHELL_RC"
  echo "✅ Added Flutter to PATH in $SHELL_RC"
else
  echo "✅ Flutter already in PATH in $SHELL_RC"
fi

echo "✅ Flutter installed successfully!"

echo "🚀 Installing Starship..."
curl -sS https://starship.rs/install.sh | sh -s -- -y
echo 'eval "$(starship init bash)"' >> ~/.bashrc
echo 'eval "$(starship init zsh)"' >> ~/.zshrc

echo "🧠 Installing Neovim..."
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
rm nvim-linux-x86_64.tar.gz

echo "💻 Installing WezTerm (latest release)..."
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg
sudo apt update
sudo apt install -y wezterm

echo "🔤 Installing Nerd Fonts (RobotoMono, FiraCode, Iosevka)..."
FONT_TMP=$(mktemp -d)
cd "$FONT_TMP"

download_and_install_font() {
  local font="$1"
  echo "⬇️  Downloading $font Nerd Font..."
  wget -q "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.zip" -O "${font}.zip"
  unzip -q "${font}.zip" -d "$font"
  sudo mkdir -p /usr/local/share/fonts/${font}
  sudo cp "$font"/*.ttf /usr/local/share/fonts/${font}/
  echo "✅ Installed $font Nerd Font"
}

download_and_install_font "RobotoMono"
download_and_install_font "FiraCode"
download_and_install_font "Iosevka"

wget -q "https://github.com/jpleatherland/fonts/blob/main/FragmentMonoNerdFont-Regular.otf"
sudo mv ./FragmentMonoNerdFont-Regular.otf /usr/local/share/fonts

echo "🔄 Refreshing font cache..."
sudo fc-cache -fv > /dev/null
cd ~
rm -rf "$FONT_TMP"

echo "🎉 Setup complete! Restart your shell or source your shell RC file for PATH and font updates."

