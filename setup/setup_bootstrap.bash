# Bootstrap the setup of a digital ocean installation by:
#
# 1. Installing the dotfiles repo
# 2. Installing python3.12-venv if necessary
# 3. Creating a venv
# 4. Running a script in the venv
#     - if root: setup_root.py
#     - not root: setup_user.py

# Variables
GIT_REPO="git@github.com:jroes/dotfiles.git"
GIT_BRANCH="main"
DOTFILES_PATH="dotfiles"
SETUP_PATH="${DOTFILES_PATH}/setup"
VENV_PATH="${DOTFILES_PATH}/setup/venv"

# Determine if we have passwordless sudo access
sudo -n true &> /dev/null
IS_ROOT=$?  # $? is 0 (true) if user has passwordless sudo, 1 (false) otherwise

# Tell the user what we're doing at the start of each block.
start_block()
{
    echo -e "\e[1m\e[34m$@...\e[0m"
    set -v
}

# Tell the user that the block is complete.
end_block()
{
    set +v
    echo -e "\e[32mDone\e[0m\n"
}

# Print something in red letters
echo_red()
{
    echo -e "\e[1m\e[31m$@\e[0m"
}

# Prevent interactive restart dialogs
prevent_restart_dialog()
{
  if [ $IS_ROOT -eq 0 ];
  then
    echo_red "Turning off interactive restart during install process...\n"
    sudo sed -i "s/^#\$nrconf{restart}\ =\ '.';/\$nrconf{restart} = 'l';/g" /etc/needrestart/needrestart.conf
    if [[ $? -ne 0 ]];
    then
      echo_red "Failed to disable restart dialogs. Continuing anyway..."
    fi
  fi
}

# Install the dotfiles repo
install_dotfiles()
{
  # Clone the repo
  start_block "Cloning the repo"

  if [[ -d ${DOTFILES_PATH} ]];
  then
    echo_red "Repo \"${DOTFILES_PATH}\" already exists."
  else
    # Check whether we can log into github. If not, something is wrong.
    if [ ! -S "$SSH_AUTH_SOCK" ];
    then
      echo "Unable to log into Github. Exiting."
      exit 255
    fi

    # Clone the repo
    git clone -b ${GIT_BRANCH} ${GIT_REPO}
    if [[ $? -ne 0 ]];
    then
      echo_red "Failed to clone branch \"${GIT_BRANCH}\" from \"${GIT_REPO}\"."
      exit 1
    fi
  fi

  end_block
}

# Install the python3.12-venv required to use Python venv in Ubuntu.
install_python_venv()
{
  # Only run if the user has sudo access
  if [ $IS_ROOT -ne 0 ];
  then
    return 255
  fi

  # apt install python3.12-venv
  PYTHON_VENV_PACKAGE="python3.12-venv"
  start_block "Installing ${PYTHON_VENV_PACKAGE}."
  sudo dpkg -s ${PYTHON_VENV_PACKAGE} &> /dev/null
  if [[ $? -eq 0 ]];
  then
    echo_red "The package ${PYTHON_VENV_PACKAGE} already exists."
  else
    sudo DEBIAN_FRONTEND=noninteractive apt update -y
    sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
    sudo DEBIAN_FRONTEND=noninteractive apt install ${PYTHON_VENV_PACKAGE} -y
  fi
  end_block
}

# Create the virtual environment and install the requirements file.
setup_venv()
{
  start_block "Creating virtual environment at ${VENV_PATH}."
  if [[ -d ${VENV_PATH} ]];
  then
    echo_red "Virtual environment \"${VENV_PATH}\" already exists."
  else
    python3 -m venv "${VENV_PATH}"
    if [[ $? -ne 0 ]];
    then
      echo_red "Failed to create virtual environment."
      exit 1
    fi
    ${VENV_PATH}/bin/pip install -r ${SETUP_PATH}/requirements.txt
    if [[ $? -ne 0 ]];
    then
      echo_red "Failed to install requirements."
      exit 1
    fi
  fi
  end_block
}

# Run a python script in the virtual environment
run_python_script()
{
  if [ $IS_ROOT -eq 0 ];
  then
    PYTHON_SCRIPT="setup_root"
  else
    PYTHON_SCRIPT="setup_dotfiles"
  fi
  echo_red "Executing setup script ${PYTHON_SCRIPT}.py."
  PYTHONPATH=${SETUP_PATH} ${VENV_PATH}/bin/python -m ${PYTHON_SCRIPT}
}

# Actually run the script
prevent_restart_dialog
install_dotfiles
install_python_venv
setup_venv
run_python_script
