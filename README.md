# my-kitty-config

Personal terminal dotfiles: [kitty](https://sw.kovidgoyal.net/kitty/) + zsh + [oh-my-zsh](https://ohmyz.sh/) + [powerlevel10k](https://github.com/romkatv/powerlevel10k).

The repo doubles as the live working tree — it lives at `~/.config/kitty/`, and `~/.zshrc` and `~/.p10k.zsh` are symlinks pointing back into it. Edit any tracked file in place and `git commit && git push` — there's no separate dotfiles directory.

Works on both Linux and macOS. Linux-specific lines in `zshrc` (ROS, Linuxbrew) are guarded and silently skipped on Mac; Homebrew is detected at whichever of `/opt/homebrew`, `/usr/local`, or `/home/linuxbrew` is present.

## Layout

```
.
├── kitty.conf            kitty terminal config (split bindings, copy-on-select, etc.)
├── current-theme.conf    kitty color theme (sourced from kitty.conf)
├── zsh/
│   ├── zshrc             → symlinked to ~/.zshrc
│   ├── p10k.zsh          → symlinked to ~/.p10k.zsh (powerlevel10k prompt)
│   └── install.sh        installs oh-my-zsh + plugins, sets up symlinks (idempotent)
├── claude-skill/
│   └── SKILL.md          setup instructions for Claude Code / agents
└── README.md             this file
```

oh-my-zsh, `zsh-autosuggestions`, `zsh-syntax-highlighting`, and `powerlevel10k` are **not** vendored — `zsh/install.sh` clones them from upstream so they stay current.

## Setup on a new machine

```bash
# 1. Clone into the kitty config path (back up first if non-empty)
mv ~/.config/kitty ~/.config/kitty.bak 2>/dev/null
git clone git@github.com:HenrikHao/my-kitty-config.git ~/.config/kitty
# HTTPS fallback: https://github.com/HenrikHao/my-kitty-config.git

# 2. Install oh-my-zsh + plugins/theme and symlink ~/.zshrc and ~/.p10k.zsh
~/.config/kitty/zsh/install.sh

# 3. Per-machine secrets (NOT tracked) — see "Secrets" below
touch ~/.zshrc.local && chmod 600 ~/.zshrc.local

# 4. (Optional) make this repo's setup skill discoverable to Claude Code
mkdir -p ~/.claude/skills
ln -s ~/.config/kitty/claude-skill ~/.claude/skills/setting-up-terminal-dotfiles
```

Reload kitty (`Ctrl+Shift+F5` or restart) and open a new zsh shell (or `exec zsh`) to pick up the configs.

`install.sh` is idempotent — re-running it only installs/clones what's missing, leaves existing symlinks alone, and backs up any real files before linking over them.

## Secrets

Anything sensitive (PATs, API keys, machine-specific tokens) goes in `~/.zshrc.local`, which the tracked `zshrc` sources at the very end if it exists. That file is **not** in the repo and never should be.

```bash
# ~/.zshrc.local example
export GITHUB_TOKEN="ghp_..."
export OPENAI_API_KEY="sk-..."
```

## Updating

| What | How |
|---|---|
| Edit kitty / zsh / p10k config | Edit the file under `~/.config/kitty/` directly, then commit + push. |
| Pull upstream plugin/theme updates | `cd ~/.oh-my-zsh/custom/plugins/<name> && git pull` (these aren't tracked here). |
| Add a new oh-my-zsh plugin | Append a `clone_if_missing` line in `zsh/install.sh` and add it to `plugins=(...)` in `zsh/zshrc`. |
| Pick up changes on another machine | `cd ~/.config/kitty && git pull`, then reload kitty / `exec zsh`. |

## Verifying a fresh setup

```bash
cd ~/.config/kitty && git status                   # clean
readlink ~/.zshrc                                  # → ~/.config/kitty/zsh/zshrc
readlink ~/.p10k.zsh                               # → ~/.config/kitty/zsh/p10k.zsh
ls ~/.oh-my-zsh/custom/plugins                     # zsh-autosuggestions, zsh-syntax-highlighting
ls ~/.oh-my-zsh/custom/themes                      # powerlevel10k
kitty --debug-config | head                        # confirms kitty is reading this config
```
