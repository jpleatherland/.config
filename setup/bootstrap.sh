#!/bin/bash
set -e

echo "📁 Bootstrapping ~/.config from GitHub..."

# Ensure .config directory exists
mkdir -p ~/.config
cd ~/.config

# Initialize git if needed
if [ ! -d ".git" ]; then
  echo "🔧 Initializing git repo..."
  git init
  git remote add origin git@github.com:jpleatherland/.config.git
else
  echo "🔄 Git repo already initialized"
fi

# Set branch to main
git checkout -B main
git branch --set-upstream-to=origin/main

# Pull latest from main
echo "⬇️  Pulling latest changes from origin/main..."
git pull origin main

chmod +x ./setup/install.sh
# Run the install script
if [ -x "./setup/install.sh" ]; then
  echo "🚀 Running setup/install.sh..."
  ./setup/install.sh
else
  echo "⚠️  ./setup/install.sh not found or not executable!"
  exit 1
fi

echo "✅ .config bootstrapped and install script complete!"

