
# 📦 Linux Dev Setup Script

A clean and reliable setup script for fresh Linux installs. Designed to get your development environment up and running in minutes on any **apt-based** distro (Ubuntu, Pop!_OS, etc).

---

## 🚀 What This Script Installs

| Tool            | Description                                                   |
|-----------------|---------------------------------------------------------------|
| 🌱 **Bun**       | Lightning-fast JavaScript/TypeScript runtime                 |
| 🐹 **Go**        | Latest stable Go programming language                        |
| 🦋 **Flutter**   | UI toolkit for mobile, web, and desktop apps (includes Dart) |
| 💫 **Starship**  | Minimal, blazing-fast shell prompt                           |
| 🧠 **Neovim**    | Modern, extensible Vim-based editor                          |
| 💻 **WezTerm**   | GPU-accelerated terminal emulator                            |
| 🔤 **Nerd Fonts**| RobotoMono, FiraCode, Iosevka (patched with glyphs)          |

It also:
- Creates **shims** for `node`, `npm`, and `npx` to use `bun` by default
- Sets up proper **PATH updates** in your `.bashrc` or `.zshrc`
- Refreshes the **system font cache** after installing Nerd Fonts

---

## 📥 Installation

If this is a **fresh machine**, just run:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/jpleatherland/.config/main/bootstrap.sh)
```

This will:

1. Clone the `.config` repo (tries SSH, falls back to HTTPS)
2. Set up the `main` branch and remote
3. Pull the latest config
4. Run the main install script in `.config/startup/install.sh`

---

## 🧼 Designed For

- Me
- Fresh installs

---

## 💻 Screenshot (optional)

> _(Insert a screenshot of your terminal here if you like)_  
> Example: WezTerm with RobotoMono Nerd Font, Starship, and Neovim open

---
