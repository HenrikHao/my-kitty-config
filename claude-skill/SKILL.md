---
name: setting-up-terminal-dotfiles
description: Use when setting up the user's terminal environment (kitty + zsh + oh-my-zsh + powerlevel10k) on a new machine, restoring shell or terminal config from version control, or syncing terminal dotfiles
---

# Setting Up Terminal Dotfiles

## Overview

The user's terminal config — kitty plus zsh/oh-my-zsh/powerlevel10k — lives in one git repo at `~/.config/kitty/`, hosted at `git@github.com:HenrikHao/my-kitty-config.git`. The repo name is historical (kitty came first); it now also covers shell config. Edits to either kitty or zsh files happen through symlinks pointing into this repo, so every change is in version control automatically.

## Repo Layout

```
~/.config/kitty/                  (= repo root)
├── kitty.conf                    main kitty config
├── current-theme.conf            kitty theme (sourced from kitty.conf)
├── zsh/
│   ├── zshrc                     symlinked to ~/.zshrc
│   ├── p10k.zsh                  symlinked to ~/.p10k.zsh (powerlevel10k prompt)
│   └── install.sh                installs oh-my-zsh + plugins, sets up symlinks
└── claude-skill/
    └── SKILL.md                  this file
```

oh-my-zsh, `zsh-autosuggestions`, `zsh-syntax-highlighting`, and `powerlevel10k` are NOT vendored. `zsh/install.sh` clones them from upstream so we keep getting upstream fixes.

## Setup on a New Machine

```bash
# 1. Clone the repo into the kitty config path (back up first if non-empty)
mv ~/.config/kitty ~/.config/kitty.bak 2>/dev/null
git clone git@github.com:HenrikHao/my-kitty-config.git ~/.config/kitty

# 2. Make this skill discoverable to Claude
mkdir -p ~/.claude/skills
ln -s ~/.config/kitty/claude-skill ~/.claude/skills/setting-up-terminal-dotfiles

# 3. Install oh-my-zsh + plugins/theme and symlink ~/.zshrc and ~/.p10k.zsh
~/.config/kitty/zsh/install.sh

# 4. Create ~/.zshrc.local for per-machine secrets (NOT tracked in git).
#    The tracked zshrc sources this file at the end if it exists.
#    Typical contents: `export GITHUB_TOKEN="ghp_..."` etc.
touch ~/.zshrc.local && chmod 600 ~/.zshrc.local
```

If SSH to GitHub isn't set up yet, swap in the HTTPS URL: `https://github.com/HenrikHao/my-kitty-config.git`.

Reload kitty (`Ctrl+Shift+F5`, or restart) for kitty config; open a new zsh shell or `exec zsh` for the shell config.

`install.sh` is idempotent — safe to re-run. It installs/clones only what's missing, leaves existing symlinks alone, and backs up any existing real files before linking over them.

## Verifying

```bash
cd ~/.config/kitty && git status                  # should be clean
readlink ~/.zshrc                                 # → ~/.config/kitty/zsh/zshrc
readlink ~/.p10k.zsh                              # → ~/.config/kitty/zsh/p10k.zsh
ls ~/.oh-my-zsh/custom/plugins                    # zsh-autosuggestions, zsh-syntax-highlighting
ls ~/.oh-my-zsh/custom/themes                     # powerlevel10k
kitty --debug-config | head                       # confirm kitty reads this config
```

## Updating

- Edit any file under `~/.config/kitty/` directly — the symlinks mean shell-config edits land in the repo automatically. Then `git add -A && git commit && git push`.
- To pull upstream plugin/theme updates: `cd ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && git pull` (and similarly for the others). These aren't tracked here.
- Adding a new oh-my-zsh plugin: append a `clone_if_missing` line in `zsh/install.sh` and add it to the `plugins=(...)` line in `zsh/zshrc`.
