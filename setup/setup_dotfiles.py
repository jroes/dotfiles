"""
Cross-platform dotfiles setup script supporting Linux and macOS.
Handles installation of development tools and configuration files.
"""

import setup_utils
import os
import sys
from termcolor import cprint


def install_dotfiles():
    """Install all the dotfiles from the dotfiles dirctory into the home
    directory, moving all backups to ~/dofiles/setup/backup."""
    # Setup a backup dirctory to move old dotfiles.
    home_path = os.path.expanduser("~")
    dotfiles_path = os.path.join(home_path, "dotfiles")
    backup_path = os.path.join(dotfiles_path, "setup/backup")
    setup_utils.cached_run(
        "Setting up backup dirctory",
        [
            f"mkdir -pv {backup_path}",
        ],
        skip_if=os.path.exists(backup_path),
    )

    # Setup a backup dirctory to move old dotfiles.
    cprint(f"Installing dotfiles...", "blue", attrs=["bold"])
    for dotfile in os.listdir(dotfiles_path):
        if dotfile in [".git", ".gitignore"] or not dotfile.startswith("."):
            continue
        orignal_dotfile_path = os.path.join(dotfiles_path, dotfile)
        install_dotfile_path = os.path.join(home_path, dotfile)
        backup_dotfile_path = os.path.join(backup_path, dotfile)

        cprint(f"Installing {dotfile}", "green")
        if os.path.exists(install_dotfile_path):
            if os.path.exists(backup_dotfile_path):
                os.system(f"rm -rfv {install_dotfile_path}")
            else:
                os.system(f"mv -v {install_dotfile_path} {backup_dotfile_path}")
            assert os.path.exists(backup_dotfile_path)
        assert not os.path.exists(install_dotfile_path)
        os.system(f"ln -sv {orignal_dotfile_path} {install_dotfile_path}")
    cprint(f"Done\n", "green")

    # Removing bash config files.
    setup_utils.cached_run(
        "Removing extraneous home folder files",
        [
            "rm -fv ~/.bashrc ~/.bash_history ~/.bash_logout",
            "rm -fv ~/.cloud-locale-test.skip",
            "rm -fv ~/.zcompdump",
        ],
    )


def install_pure():
    """Installs a prettier prompt for zsh."""
    pure_repo = "https://github.com/sindresorhus/pure.git"
    zsh_plugin_path = os.path.expanduser("~/.local/share/zsh")
    pure_path = os.path.join(zsh_plugin_path, "pure")
    setup_utils.cached_run(
        "Installing pure, a prettier prompt for zsh",
        [f"mkdir -pv {zsh_plugin_path}", f"git clone {pure_repo} {pure_path}"],
        skip_if=os.path.exists(pure_path),
    )


def install_tmux_plugins():
    """Make tmux work with its plugins."""
    tmux_plugin_path = os.path.expanduser("~/.config/tmux/plugins")
    tpm_plugin_path = os.path.join(tmux_plugin_path, "tpm")
    tpm_plugin_repo = "https://github.com/tmux-plugins/tpm"
    
    # Create plugin directory if it doesn't exist
    if not os.path.exists(tmux_plugin_path):
        setup_utils.cached_run(
            "Creating tmux plugin directory",
            [f"mkdir -pv {tmux_plugin_path}"],
        )
    
    # Install TPM if not present
    if not os.path.exists(tpm_plugin_path):
        setup_utils.cached_run(
            "Installing the tmux plugin manager",
            [f"git clone {tpm_plugin_repo} {tpm_plugin_path}"],
        )
    
    # Install/update plugins
    setup_utils.cached_run(
        "Installing/updating tmux plugins",
        [f"{tpm_plugin_path}/bindings/install_plugins || true"],
    )


def install_bun():
    """Install bun runtime in the home directory."""
    home_path = os.path.expanduser("~")
    bun_path = os.path.join(home_path, ".bun")
    setup_utils.cached_run(
        "Installing bun",
        ["curl -fsSL https://bun.sh/install | bash"],
        skip_if=os.path.exists(bun_path),
    )


def install_direnv():
    """Install direnv using the appropriate package manager."""
    setup_utils.cached_package_install("direnv", "Installing direnv")


def install_asdf():
    """Install asdf version manager and plugins."""
    home_path = os.path.expanduser("~")
    asdf_path = os.path.join(home_path, ".asdf")
    asdf_repo = "https://github.com/asdf-vm/asdf.git"
    
    # Install asdf
    setup_utils.cached_run(
        "Installing asdf version manager",
        [f"git clone {asdf_repo} {asdf_path}"],
        skip_if=os.path.exists(asdf_path),
    )
    
    # Add plugins and install latest versions
    asdf_bin = os.path.join(asdf_path, "bin/asdf")
    # Check for existing plugins
    nodejs_plugin = os.path.join(asdf_path, "plugins/nodejs")
    ruby_plugin = os.path.join(asdf_path, "plugins/ruby")
    
    if not os.path.exists(nodejs_plugin):
        setup_utils.cached_run(
            "Installing nodejs plugin for asdf",
            [
                f"{asdf_bin} plugin add nodejs",
                f"{asdf_bin} install nodejs latest",
                f"{asdf_bin} global nodejs latest",
            ],
        )
    
    if not os.path.exists(ruby_plugin):
        setup_utils.cached_run(
            "Installing ruby plugin for asdf",
            [
                f"{asdf_bin} plugin add ruby",
                f"{asdf_bin} install ruby latest",
                f"{asdf_bin} global ruby latest",
            ],
        )


def install_rust():
    """Installs rust in the home directory."""
    home_path = os.path.expanduser("~")
    cargo_home = os.path.join(home_path, ".local/rust/cargo")
    rustup_home = os.path.join(home_path, ".local/rust/rustup")
    rust_env = f"CARGO_HOME={cargo_home} RUSTUP_HOME={rustup_home}"
    rustup_bin = os.path.join(cargo_home, "bin/rustup")

    # Install rust if not present
    if not os.path.exists(cargo_home) or not os.path.exists(rustup_home):
        setup_utils.cached_run(
            "Installing rust",
            [f"curl https://sh.rustup.rs -sSf | {rust_env} sh -s -- -y"],
        )

    # Update and configure rust components
    if os.path.exists(rustup_bin):
        setup_utils.cached_run(
            "Updating and configuring rust",
            [
                f"{rust_env} {rustup_bin} update",
                f"{rust_env} {rustup_bin} default stable",
                f"{rust_env} {rustup_bin} component add rust-analyzer",
            ],
        )


def main():
    """Execution starts here."""
    # Check for required tools
    if setup_utils.is_macos():
        if not os.path.exists("/usr/local/bin/brew") and not os.path.exists("/opt/homebrew/bin/brew"):
            setup_utils.cached_run(
                "Installing Homebrew",
                ['/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'],
            )
    elif not setup_utils.is_linux():
        cprint("This script only supports macOS and Linux.", "red", attrs=["bold"])
        sys.exit(1)

    install_pure()
    install_dotfiles()
    install_tmux_plugins()
    install_rust()
    install_bun()
    install_direnv()
    install_asdf()

    cprint("Everything installed. To get all the goodies, run:", "blue", attrs=["bold"])
    print(". ~/.zshrc")


if __name__ == "__main__":
    main()
