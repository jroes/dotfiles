# Dotfiles Setup

This repository contains configuration files managed using Homebrew Bundle and some additional setup scripts.

## Prerequisites

*   **Homebrew:** Make sure you have Homebrew installed. If not, follow the instructions at [https://brew.sh/](https://brew.sh/).

## Installation

1.  **Install Homebrew packages:**

    Run the following command in your terminal from the root of this repository:

    ```bash
    brew bundle --file Brewfile
    ```

    This will install all the CLI tools and GUI applications listed in the `Brewfile`.

2.  **Run additional setup:**

    Run the script for other setup items:

    ```bash
    bash setup_extras.sh
    ```

    This script will:
    *   Install Oh My Zsh.
    *   Tap the Homebrew font cask repository.
    *   Install a list of Nerd Fonts.
    *   Automatically configure Ghostty, Cursor, and VSCode to use "RobotoMono Nerd Font Mono".
    *   Install `warpd`.

    **Note:** The Oh My Zsh installation might take over your shell session. The `warpd` installation uses `sudo` and may prompt for your password.
