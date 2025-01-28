"""
This file lets you run a set of commands and cache them so that they
they needn't be run a second time. Supports both Linux and macOS.
"""

from termcolor import cprint
import os
import sys
import hashlib
import pickle
import subprocess
from typing import Optional
import platform
import shutil

def is_macos():
    """Check if running on macOS."""
    return platform.system() == "Darwin"

def is_linux():
    """Check if running on Linux."""
    return platform.system() == "Linux"

# Platform-specific package installation commands
APT_INSTALL = "sudo DEBIAN_FRONTEND=noninteractive apt install -y"
BREW_INSTALL = "brew install"

def machine_is_arm64():
    """Determine if the machine architecture is ARM64."""
    return platform.machine() == "aarch64"

def cached_run(title, commands, skip_if=False):
    """Runs the given set of commands, prepending the title."""
    # Inidcate the command we're running
    cprint(f"{title}...", "blue", attrs=["bold"])

    # Create the cache filename
    hasher = hashlib.sha256()
    hasher.update(pickle.dumps((title, commands)))
    cache_folder = os.path.expanduser("~/.local/cache/digital_ocean_setup")
    cache_filename = f"{hasher.hexdigest()}_{title.lower().replace(' ', '_')}.txt"
    cache_filename = os.path.join(cache_folder, cache_filename)

    # Skip running the command if the skip_if command is true.
    if skip_if:
        cprint("Skipping", "cyan")
        print()
        return

    # Skip running the command if we already have it cached
    if os.path.exists(cache_filename):
        cprint("Already done", "cyan")
        print()
        return

    # Run the commmands
    for command in commands:
        cprint(command, attrs=["bold"])
        return_value = os.system(command)
        if return_value != 0:
            cprint(f"Error: {return_value}", "red", attrs=["bold"])
            sys.exit(return_value)

    # Write the cached file.
    os.makedirs(cache_folder, exist_ok=True)
    with open(cache_filename, "w") as cached_command_record:
        cached_command_record.writelines("\n".join(commands) + "\n")
    print("Wrote:", cache_filename)
    cprint("Done", "green")
    print()


def cached_package_install(package: str, title: Optional[str] = None):
    """Install a package using the appropriate package manager for the platform."""
    if title is None:
        title = "Installing " + package

    if is_macos():
        if not shutil.which("brew"):
            cprint("Homebrew not found. Please install it first.", "red", attrs=["bold"])
            sys.exit(1)
        cached_run(title, [f"{BREW_INSTALL} {package}"])
    else:
        cached_run(title, [f"{APT_INSTALL} {package}"])

def cached_apt_install(package: str, title: Optional[str] = None):
    """Install a package using apt and the cached_run mechanism (Linux only)."""
    if is_macos():
        cprint("Warning: apt-get is not available on macOS", "yellow", attrs=["bold"])
        return
    
    if title is None:
        title = "Installing " + package

    cached_run(title, [f"{APT_INSTALL} {package}"])


def user_exists(user):
    """Returns true if the named user exists"""
    return bool(subprocess.run(["getent", "passwd", user], capture_output=True).stdout)


def user_is_root():
    """Returns true if this user has passwordless sudo access."""
    try:
        # Try to run a harmless sudo command with -n flag (non-interactive)
        # This will fail if user needs a password for sudo
        result = subprocess.run(
            ["sudo", "-n", "true"],
            capture_output=True,
            text=True
        )
        return result.returncode == 0
    except Exception:
        return False
