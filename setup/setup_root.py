"""
TODO: Add documentation
"""

import sys
import os
import setup_utils
from termcolor import cprint
import getpass
import time
import tempfile
from passlib.hash import sha512_crypt


def setup_root():
   """These are the installation steps which should happen as root."""
   # Installing cc linker and compiler which cargo will need.
   setup_utils.cached_apt_install("build-essential")

   # Setup zsh
   setup_utils.cached_run(
       "Setting up zsh",
       [
           f"sudo {setup_utils.APT_INSTALL} -y zsh",
           "sudo chsh -s $(which zsh)",
       ],
   )

   # Install netstat
   setup_utils.cached_apt_install("net-tools")

   # Install fancy search tools
   setup_utils.cached_apt_install("ripgrep")
   setup_utils.cached_apt_install("fzf")
   setup_utils.cached_apt_install("fd-find")

   # Install zip and unzip
   setup_utils.cached_apt_install("zip")
   setup_utils.cached_apt_install("unzip")

   # Install lsd, a prettier ls
   setup_utils.cached_apt_install("lsd")

   # Installing nodejs (for the GitHub plugin)
   setup_utils.cached_apt_install("nodejs")
   setup_utils.cached_run("Installing npm",
      ["curl -L https://www.npmjs.com/install.sh | sudo sh"])

   # Install bat, a prettier cat
   setup_utils.cached_apt_install("bat")

   # Need this for some more advanced Python ML packages that require C++ compilation
   setup_utils.cached_apt_install("python3.12-dev")

   # Set the timezone properly
   setup_utils.cached_run(
       "Setting timezone",
       [
           "sudo timedatectl set-timezone America/Los_Angeles",
       ],
   )

   # Install neovim build dependencies
   setup_utils.cached_apt_install("cmake")
   setup_utils.cached_apt_install("gettext")

   # Now build neovim from source
   setup_utils.cached_run(
       "Building neovim from source",
       [
           "git clone https://github.com/neovim/neovim ./neovim",
           "git -C ./neovim checkout stable",
           f"make -C ./neovim -j$(nproc) CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=/opt/nvim",
           "sudo make -C ./neovim install",
       ],
   )

   # I nice TUI for GIT - need to test thi
   arch_suffix = "Linux_arm64" if setup_utils.machine_is_arm64() else "Linux_x86_64"
   setup_utils.cached_run(
       "Installing lazygit",
       [
           r"""curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')_""" + arch_suffix + """.tar.gz" """,
           "tar xf lazygit.tar.gz lazygit",
           "sudo install lazygit /usr/local/bin",
       ],
   )

   # Create a user to SSH into this box.
   create_user("jroes")

   # Lock down ssh logins
   lock_down_ssh()

   # Turn on the firewall
   setup_utils.cached_run(
       "Turn on the firewall",
       [
           "sudo ufw allow ssh",
           "echo y | sudo ufw enable",
       ],
   )

def create_user(user):
   """Create a new user"""
   user_home = f"/home/{user}"
   cprint(f"Creating user {user}...", "blue", attrs=["bold"])
   if setup_utils.user_exists(user):
       cprint(f"User {user} already exists\n", "cyan")
       return
   password = getpass.getpass(f"Password for user {user}: ")
   password_again = getpass.getpass("Reenter password: ")
   if password != password_again:
       print("Passwords don't match.")
       sys.exit(-1)

   # Generate hash using passlib
   encrypted_password = sha512_crypt.hash(password)

   # Create user with sudo privileges
   add_user_cmd = f"sudo useradd -b /home -G sudo -m -p '{encrypted_password}' -s $(which zsh) -U {user}"
   os.system(add_user_cmd)

   temp_user_status = f'Adding {user} with {len(password)}-char password "{password[:2]}...{password[-2:]}"...'
   cprint(temp_user_status, "magenta", attrs=["bold"], end="\r")
   time.sleep(4.0)
   print(" " * len(temp_user_status), end="\r")  # clear the temp buffer
   cprint(f"Added user {user}.\n", "green")

   # Setting up the new user
   setup_utils.cached_run(
       f"Setting up {user}",
       [
           f"sudo mkdir {user_home}/.ssh",
           f"sudo cp -v ~/.ssh/authorized_keys {user_home}/.ssh",
           f"sudo cp -v ~/.ssh/known_hosts {user_home}/.ssh",
           f"sudo cp -v ~/dotfiles/setup/ssh_rc.bash {user_home}/.ssh/rc",
           f"sudo chmod 0700 {user_home}/.ssh",
           f"sudo touch {user_home}/.zshrc",
           f"sudo chown -vR {user}:{user} {user_home}",
       ],
   )


def lock_down_ssh():
   """Lock down ssh logins. Mostly, turn off root ssh login."""

   sshd_config_filename = "/etc/ssh/sshd_config"
   cprint(f"Updating {sshd_config_filename}...", "blue", attrs=["bold"])
   if os.path.exists(sshd_config_filename):
       config_changes = [
           ("PasswordAuthentication yes", "PasswordAuthentication no"),
           ("PermitRootLogin yes", "PermitRootLogin no"),
       ]
       sshd_config = open(sshd_config_filename).readlines()
       changed_config = False
       for line_number, config_line in enumerate(sshd_config):
           for change_from, change_to in config_changes:
               if config_line.strip() == change_from.strip():
                   print(f"{line_number+1}: {change_from} -> {change_to}")
                   sshd_config[line_number] = change_to + "\n"
                   changed_config = True
       print(f"changed config: {changed_config}")
       if changed_config:
           temp_file = tempfile.NamedTemporaryFile(mode="w", delete=False)
           temp_file.writelines(sshd_config)
           temp_file.close()
           os.system(f"sudo chmod -v --reference={sshd_config_filename} {temp_file.name}")
           os.system(f"sudo mv -v {temp_file.name} {sshd_config_filename}")
           print(f"Overwrote {sshd_config_filename}")
           print("Please restart the computer.")
       cprint("Done\n", "green")
   else:
       cprint(f"Could not find {sshd_config_filename}\n", "cyan")


def main():
   """Execution starts here."""
   # These installations require the user to be root.
   if not setup_utils.user_is_root():
       raise RuntimeError("Must run this script as root or with sudo privileges.")

   # Run the setup script.
   setup_root()

   # Tell the root user to reboot.
   cprint(f"Please reboot the computer:", "red", attrs=["bold"])
   print("  sudo shutdown -r now")


if __name__ == "__main__":
   main()
