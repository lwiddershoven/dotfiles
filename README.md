# Dotfiles to automate Mac setup

Automated, reproducible macOS developer setup targeting full-stack development with Java/Quarkus and Angular. Tweak it to your preferences.
  

## Quickstart

Download bootstrap.sh. This will install XCode which installs git.

Clone this repository:
```console
$ git clone https://github.com/casparderksen/dotfiles.git ~/.dotfiles
```

Tweak configuration to your preferences:
- Edit `Brewfile` for apps and packages to install (use `mas` to lookup apps in App Store)
- Edit `mise/.config/mise/config.toml` to configure tools and runtimes to install (with local versions per project)
- Edit `macos.sh` for macOS settings

Run the bootstrap script:
```console
$ cd ~/.dotfiles
$ ./bootstrap.sh
```

## Overview

### Bootstrap script (`bootstrap.sh`)

Orchestrates a full machine setup end-to-end: installs Xcode CLI tools,
Homebrew, all packages, stows dotfiles, installs runtimes, generates an SSH
key, configures git identity and commit signing, and applies macOS defaults.
Safe to re-run.

### Homebrew (`Brewfile`)

Declares all CLI tools, GUI applications, and Mac App Store apps. Highlights:
- Modern CLI replacements: `bat`, `eza`, `fd`, `ripgrep`, `delta`, `zoxide`
- Shell enhancements: `fzf`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `starship`
- Developer tools: `gh`, `httpie`, `jq`, `yq`, `gnupg`, `ansible`, `ffmepg`, `pandoc`
- AI tools: `claude-code` (see [Claude Code](#claude-code)), `ollama`
- Apps: IntelliJ IDEA, VS Code, OrbStack, DBVisualizer, Proxyman

### macOS defaults (`macos.sh`)

Non-interactive `defaults write` configuration for Finder, Dock, screenshots,
hot corners, trackpad, and security settings.

### GNU Stow

Symlink manager that maps each tool's subdirectory to `$HOME`, keeping
configuration source-controlled and organised by package (`git/`, `zsh/`, `ssh/`, `mise/`, …).

### Mise (`mise/.config/mise/config.toml`)

Polyglot runtime version manager replacing `nvm`, `sdkman`, etc. Manages:
Node.js, Java (OpenJDK), Maven, Python, Angular CLI, OpenTofu, kubectl, and
Helm. Respects per-project version files under `~/projects/`.

### Shell — Zsh (`zsh/.zshrc`, `zsh/.alias`)

- Mise activation, zoxide, fzf, autosuggestions, syntax highlighting
- Starship prompt showing git, language versions, and container context
- Aliases for `eza`, `bat`, and common git operations

### Starship prompt (`starship/.config/starship.toml`)

- Context sensitive prompt showing project type and git status, when applicable. 
  See [https://starship.rs](https://starship.rs).

### Git (`git/.config/git`)

- Delta diff pager, histogram diff algorithm, zdiff3 conflict style
- Fast-forward-only pull, auto-setup remote push, rerere, SSH commit signing
- Aliases: `undo`, `wip`, `nuke`

### Eclipse (`scripts/bin/install-eclipse.sh`)

Eclipse is not installed by defaults. Run this script for a fully automated
installation. The script is safe to re-run.

- Downloads and configures an Eclipse Modelling Tools installation to
`~/eclipse/modeling-<release>`. 
- Installs UML2, ATL, Acceleo, Emfatic, and XML/XSL
on top of the pre-bundled features. 
- Configures JVM memory.
  
### Claude Code (`claude/.claude/settings.json`)

- [Claude Code](https://claude.ai/code) (requires subscription) is installed via Homebrew.
- Claude Code settings (`.claude/settings.json`) are managed via Stow.
- Run `~/bin/install-claude-plugins.sh` to install Claude plugins and skills

### Claude Code statusline

- [ccstatusline](https://github.com/sirmalloc/ccstatusline) is installed via Mise. 
- Configuration is managed via Stow (`ccstatusline/.config/ccstatusline/settings.json`). 
- Run `ccstatusline` to configure the statusline.

## AI Disclosure

This project uses artificial intelligence tools for research, coding, or documentation. All  final content
was  reviewed, edited, and validated by the human author before publication.
