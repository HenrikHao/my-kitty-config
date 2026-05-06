---
name: setting-up-kitty-config
description: Use when setting up the user's kitty terminal configuration on a new machine, restoring kitty config from version control, or syncing kitty dotfiles
---

# Setting Up Kitty Config

## Overview

The user's kitty terminal config is tracked as a git repo at `~/.config/kitty/`, hosted at `git@github.com:HenrikHao/my-kitty-config.git`. The repo also ships this skill itself in `claude-skill/`, symlinked into `~/.claude/skills/` so edits sync automatically.

## Repo Layout

```
~/.config/kitty/                          (= repo root)
├── kitty.conf                            main configuration
├── current-theme.conf                    active theme (sourced from kitty.conf)
└── claude-skill/
    └── SKILL.md                          this file
```

## Setup on a New Machine

```bash
# Back up any existing kitty config (git clone refuses non-empty target)
mv ~/.config/kitty ~/.config/kitty.bak 2>/dev/null

# Clone the repo into the kitty config path
git clone git@github.com:HenrikHao/my-kitty-config.git ~/.config/kitty

# Make this skill discoverable to Claude
mkdir -p ~/.claude/skills
ln -s ~/.config/kitty/claude-skill ~/.claude/skills/setting-up-kitty-config
```

Restart kitty (or `Ctrl+Shift+F5` inside kitty) to reload the config.

If SSH to GitHub isn't set up yet, swap in the HTTPS URL: `https://github.com/HenrikHao/my-kitty-config.git`.

## Verifying

```bash
cd ~/.config/kitty && git status                  # should be clean
readlink ~/.claude/skills/setting-up-kitty-config # should point into the repo
kitty --debug-config | head                       # confirm kitty reads this config
```

## Updating

Edit `kitty.conf`, `current-theme.conf`, or this `SKILL.md` directly inside `~/.config/kitty/` — the symlink means skill edits land in the repo automatically. Then commit and push as normal.
