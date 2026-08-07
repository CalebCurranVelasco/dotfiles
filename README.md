# dotfiles

Personal macOS setup managed with [nix-darwin](https://github.com/nix-darwin/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager), applied with one command.

## What you get

Running the rebuild applies:

- **System settings** — dark mode, fast key repeat, auto-hide dock and menu bar, Finder in list view, tap-to-click (`configuration.nix`)
- **Homebrew** — `wezterm`, `discord`, `claude-code` (casks) and `herdr` (brew)
- **Nix user packages** — ripgrep, fd, fzf, jq, lazygit, Neovim, GitHub CLI (`gh`), Hack Nerd Font
- **Shell** — zsh with autosuggestions, syntax highlighting, and a starship prompt
- **Editor** — Neovim config (lazy.nvim, oil.nvim, snacks.nvim picker, neogit/gitsigns, which-key)
- **Terminal** — WezTerm config with the rose-pine-moon color scheme and dimmed unfocused windows
- **Agent configs** — `home/AGENTS.md` is symlinked in for Claude, Codex, and opencode so they share one instructions file
- **Herdr config** — `home/.config/herdr/config.toml` is symlinked into place (its runtime logs/session/lock files are gitignored, not tracked)

## Prerequisites

- A Mac. Apple Silicon by default.
- **Intel Mac:** in `configuration.nix`, change `nixpkgs.hostPlatform = "aarch64-darwin";` to `"x86_64-darwin"` (the line is commented to say the same thing).

## Setup

On a fresh Mac, from a bare clone of this repo:

```
git clone <this-repo-url>
cd dotfiles
./bootstrap.sh
```

`bootstrap.sh` does this, in order:

1. Installs Determinate Nix, if it isn't already installed.
2. Symlinks this repo to `~/.dotfiles` — `home.nix` resolves its config paths through there, so this has to exist before the first build.
3. Checks the `user = "..."` line in `flake.nix` against your actual macOS username, and offers to fix it for you if they differ.
4. Runs the first `darwin-rebuild switch`, fetching the `darwin-rebuild` tool itself from the nix-darwin 26.05 release branch, then applying this repo's locked flake config.

After that, `darwin-rebuild` exists and you're on the normal workflow below.

## Daily use

Edit files, then apply:

```
./rebuild.sh
```

It re-symlinks the repo to `~/.dotfiles` and runs `sudo darwin-rebuild switch --flake ~/.dotfiles#mac`.

Most edits under `home/` (Neovim, WezTerm, herdr config) take effect immediately without a rebuild — see **How the symlinks work** below. You only need `./rebuild.sh` for changes to packages, Homebrew casks/brews, or system defaults.

## Linux / Windows

This repo is **macOS-only** as written: `configuration.nix` uses nix-darwin and `system.defaults`/Homebrew, none of which exist on Linux, and there's no Windows support at all (Windows would need WSL2 running Linux first).

If you want this on Linux, nix-darwin and the Homebrew block don't apply, but the platform-agnostic parts of `home.nix` (packages, zsh, starship) and everything under `home/` (Neovim, WezTerm, herdr configs) would carry over into a plain home-manager (non-Darwin) setup — that setup isn't included here, though.

## Repo tour

- `flake.nix` — entry point; wires up nixpkgs, nix-darwin, home-manager, and nix-homebrew, declares the `mac` machine
- `configuration.nix` — system-level config: macOS defaults, Homebrew
- `home.nix` — user-level config: shell, packages, prompt, and the symlinks below
- `bootstrap.sh` — one-time setup on a fresh Mac; installs Nix and runs the first `darwin-rebuild switch`
- `rebuild.sh` — re-applies the config; run this after any change
- `home/` — the real config files, symlinked into place

## How the symlinks work

`home.nix` uses `mkOutOfStoreSymlink` to point paths like `~/.config/nvim` straight at `home/.config/nvim` in this repo, so editing a file here *is* editing your live config — no rebuild needed to see it in your editor. `./rebuild.sh` is only for things that aren't a symlinked file, like the package list or system defaults.

## Good to know

- **Username:** set once, as `user = "calebcurran-velasco";` in `flake.nix`, then threaded into `configuration.nix` and `home.nix` via `specialArgs`. `bootstrap.sh` checks this against your actual macOS username and can rewrite it for you.
- **Host label `"mac"`:** appears in `flake.nix` (`darwinConfigurations."mac"`) and `rebuild.sh` (`#mac` in the flake reference). Both have to match.
- **CPU architecture:** `nixpkgs.hostPlatform` in `configuration.nix` — see Prerequisites.
- **Git identity:** `home.nix` doesn't set `programs.git`, so it's not managed declaratively — set it with `git config --global user.name`/`user.email`, or add a `programs.git` block to `home.nix` to manage it here instead.
- **`home/AGENTS.md`:** agent instructions, symlinked in for Claude, Codex, and opencode alike.
- **Shell aliases in `home.nix`:** `co` is `codex --full-auto`, which skips Codex's normal confirmations. Know what it does before using it.
- **`herdr` in `brews`:** a real Homebrew formula (`homebrew/core`), so it installs fine.

## Notes

- The first `nvim` launch clones `lazy.nvim` and its plugins over the network; after that it works offline.
- Only WezTerm uses the rose-pine-moon color scheme — the Neovim config doesn't set a colorscheme.
