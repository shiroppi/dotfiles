# dotfiles
shiroppi's dotfiles.

## Quick Start
This dotfiles is managed by [dots](https://github.com/shiroppi/dots) that is an declarative, brief dotfiles manager.

```bash
git clone https://github.com/shiroppi/dotfiles.git
cd dotfiles
dots apply

# If there isn't dots, install it referencing here (https://github.com/shiroppi/dots#installation).
```
 ## For me, when I set up desktop environment of Unix OS
 Generally, when I put things in local, I like keeping packages separated in case:

 1. It’s a system package like boot loader, login manager
I basically install it with os-based package manager like pkg, dnf, apt, except the tools such as hyprland, wezterm. and so on that I want to use lately version, expected to be installed with the tools providing latest package like yay(aur), ports.

 2. It’s a tool
I mainly install cli tools, programming language like neovim, nodejs with mise.

But, I cannot decide whether I should install desktop tools like Firefox, Discord.
It is a tool, while I want it to have a availability that can be removed and switched quickly.
Possibly, Firefox is often used, so I can write it down in mise config, but is the tools I little use installed for trial-purpose like some browser, some text editor eligible for being written in mise config?
