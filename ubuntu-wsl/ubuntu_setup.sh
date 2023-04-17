#!/bin/bash

# Store script directory name full path to use later
script_dir_path=$(cd `dirname $0` && pwd -P)
echo "Setup script directory path: $script_dir_path"

# ----------------------------------------------------------------------------
#####
# Check which user is running the script
#####


print_usage() {
  printf "Usage: ..."
}


# Check if script was executed as ROOT
if ((${EUID:-0} || "$(id -u)")); then
   echo "ERROR: This script must be run as root." 
   exit 1
fi

# Check if a user is passed as parameter
if [ $# -eq 0 ]; then
    echo "ERROR: You need to inform a user as parameter to be used in GNOME and Applications configuration."
    echo "Example: sudo -E bash ubuntu-setup.sh user1"
    exit 1
fi

# Check if the user session environment variables were preserved
# if [ -v $DBUS_SESSION_BUS_ADDRESS ]; then
# 	echo "ERROR: You need to run 'sudo -E' to preserve session environment variables."
# 	exit 1
# fi

# Storing USER and HOME variables for later configurations
user_selected=$1
home_selected="/home/${user_selected}"


echo 
echo "UBUNTU-SETUP: Initializing setup process."
echo "-----------------------------------------------------------------------"
echo 

echo "-----------------------------------------------------------------------"
echo "UBUNTU-SETUP: Updating and upgrading existent packages."
echo 

apt update -y
apt upgrade -y

echo "-----------------------------------------------------------------------"
echo "UBUNTU-SETUP: Updating and upgrading existent packages finished."
echo 

echo "-----------------------------------------------------------------------"
echo "UBUNTU-SETUP: Installing 'nala' package manager wrapper."
echo 

apt install -y nala

echo "-----------------------------------------------------------------------"
echo "UBUNTU-SETUP: Installing 'nala' package manager wrapper finished."
echo 

echo "-----------------------------------------------------------------------"
echo "UBUNTU-SETUP: Installing base packages and terminal applications."
echo 

nala install \
-y `# Do not ask for confirmation` \
bat `# cat(1) clone with syntax highlighting and git integration` \
ca-certificates `# Common CA certificates` \
curl `# A utility for getting files from remote servers (FTP, HTTP, and others)` \
exa `# Modern replacement for ls` \
fzf `# general-purpose command-line fuzzy finder` \
gcc `# Various compilers (C, C++, Objective-C, ...)` \
git `# fast, scalable, distributed revision control system (all subpackages)` \
htop `# Interactive CLI process monitor` \
httpie `# CLI, cURL-like tool for humans` \
jq `# lightweight and flexible command-line JSON processor` \
nano `# Because pressing i is too hard sometimes` \
neovim `# Vim-fork focused on extensibility and agility` \
nload `# A tool can monitor network traffic and bandwidth usage in real time` \
openssl `# Utilities from the general purpose cryptography library with TLS implementation` \
p7zip-full `# 7z and 7za file archivers with high compression ratio` \
pv `# A tool for monitoring the progress of data through a pipeline ( | )` \
python3 `# Python core library` \
python3-dev `# Python Development Gear` \
snapd `# A transactional software package manager. Analogous to Flatpak.` \
unar `# free rar decompression` \
unzip `# A utility for unpacking zip files` \
wget `# retrieves files from the web` \
zsh `# zshell installation in preparation for oh-my-zsh`

# configure batcat (bat name in ubuntu) to be used as bat
mkdir -p ${home_selected}/.local/bin
chown -R $user_selected:$user_selected ${home_selected}/.local/
ln -s /usr/bin/batcat ${home_selected}/.local/bin/bat

echo 
echo "UBUNTU-SETUP: Installing base packages and terminal applications finished."
echo "-----------------------------------------------------------------------"
echo 

echo "-----------------------------------------------------------------------"
echo "UBUNTU-SETUP: Installing LSD (substitute for 'ls' tool)."
echo 

LSD_VERSION=$(echo "$(curl -Ls -o /dev/null -w '%{url_effective}' https://github.com/lsd-rs/lsd/releases/latest)" | grep -Eo '[0-9]{1,2}.[0-9]{1,2}.[0-9]{1,2}')

sudo -E -u $user_selected wget -q -O "$home_selected/lsd.deb" -o "/dev/null" \
"https://github.com/lsd-rs/lsd/releases/download/${LSD_VERSION}/lsd_${LSD_VERSION}_amd64.deb"

dpkg -i ${home_selected}/lsd.deb

rm -rf ${home_selected}/lsd.deb

echo 
echo "UBUNTU-SETUP: Installing LSD (substitute for 'ls' tool) finished."
echo "-----------------------------------------------------------------------"

echo 
echo "-----------------------------------------------------------------------"
echo "UBUNTU-SETUP: Installing packages to be used by pyenv for build python from source."
echo 

nala install \
-y `# Do not ask for confirmation` \
build-essential `# Informational list of build-essential packages` \
libssl-dev `# Secure Sockets Layer toolkit - development files` \
zlib1g-dev `# compression library - development` \
libbz2-dev `#  high-quality block-sorting file compressor library - development` \
libreadline-dev `# GNU readline and history libraries, development files` \
libsqlite3-dev `# SQLite 3 development files` \
libncursesw5-dev `# transitional package for libncurses-dev` \
xz-utils `# XZ-format compression utilities` \
tk-dev `# Toolkit for Tcl and X11 (default version) - development files` \
libxml2-dev `# GNOME XML library - development files` \
libxmlsec1-dev `# Development files for the XML security library` \
libffi-dev `# Foreign Function Interface library (development files)` \
liblzma-dev `# XZ-format compression library - development files` \
llvm `# Low-Level Virtual Machine (LLVM)`

echo 
echo "UBUNTU-SETUP: Installing packages to be used by pyenv for build python from source finished."
echo "-----------------------------------------------------------------------"

{

# Install oh-my-szh
export ZSH="/usr/share/oh-my-zsh"
sh -c "$(curl -fSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# # Add oh-my-zsh to /usr/share
# mv /root/.oh-my-zsh /usr/share
# mv /usr/share/.oh-my-zsh /usr/share/oh-my-zsh
if [ -f  "/root/.zshrc" ] 
then
    mv /root/.zshrc /usr/share/oh-my-zsh
    mv /usr/share/oh-my-zsh/.zshrc /usr/share/oh-my-zsh/zshrc
else
    mv "${home_selected}"/.zshrc /usr/share/oh-my-zsh
    mv /usr/share/oh-my-zsh/.zshrc /usr/share/oh-my-zsh/zshrc
fi 

# # Modify zshrc to point to /usr/share/oh-my-zsh
# sed -i 's|export ZSH="$HOME/.oh-my-zsh"|export ZSH="\/usr\/share\/oh-my-zsh"|g' /usr/share/oh-my-zsh/zshrc

# Activate update reminder
sed -i "s/# zstyle ':omz:update' mode reminder  # just remind me to update when it's time/zstyle ':omz:update' mode reminder  # just remind me to update when it's time/" /usr/share/oh-my-zsh/zshrc

# Enable Autocorrection for zsh
sed -i 's/# ENABLE_CORRECTION="true"/ENABLE_CORRECTION="true"/g' /usr/share/oh-my-zsh/zshrc

# Enable Autosuggestions, sintax highlighting and fzf plugins for zsh
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-/usr/share/oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-/usr/share/oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
sed -i 's/plugins=(git)/plugins=(git)\nZSH_DISABLE_COMPFIX=true/' /usr/share/oh-my-zsh/zshrc
sed -i 's/plugins=(git)/plugins=(\n  git\n  zsh-autosuggestions\n  zsh-syntax-highlighting\n  fzf\n)/' /usr/share/oh-my-zsh/zshrc


# Create a backup copy of original zshrc
cp /usr/share/oh-my-zsh/zshrc /usr/share/oh-my-zsh/zshrc.backup

# Configure LSD alias over 'ls'
tee -a /usr/share/oh-my-zsh/zshrc > /dev/null << 'EOI'

# Configuration for LSD alias over LS
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree --depth'
alias lta='ls -la --tree --depth'

EOI

# Configure FZF
tee -a /usr/share/oh-my-zsh/zshrc > /dev/null << 'EOI'

# ZFZ configuration
export FZF_BASE="$(which fzf)/.fzf"
export FZF_DEFAULT_COMMAND='rg --hidden --no-ignore --files -g "!.git/"'
export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

EOI

# other aliases
tee -a /usr/share/oh-my-zsh/zshrc > /dev/null << 'EOI'

# General aliases
alias python=python3
alias gs="git status"
alias fp="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'"

EOI

# add user .local/bin and /bin to PATH
tee -a /usr/share/oh-my-zsh/zshrc > /dev/null << 'EOI'

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

EOI

# Create Symbolic Links to /etc/skel
sudo ln -s /usr/share/oh-my-zsh/zshrc /etc/skel/.zshrc

# Copy zshrc to $HOME for root and change default shell to ZSH
ln -s /usr/share/oh-my-zsh/zshrc /root/.zshrc
echo "$USER" | chsh -s /bin/zsh

# Copy zshrc to $HOME for user and change default shell to ZSH
ln -s /usr/share/oh-my-zsh/zshrc ${home_selected}/.zshrc
usermod --shell $(which zsh) $user_selected
chown -R $user_selected:$user_selected ${home_selected}/.zshrc
chown -R $user_selected:$user_selected /usr/share/oh-my-zsh


echo 
echo "UBUNTU-SETUP: Succesfully installed Oh-My-Zsh."
echo 

} || {

echo 
echo "UBUNTU-SETUP: Failed to install Oh-My-Zsh."
echo 

}

{
## Install Powelevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-/usr/share/oh-my-zsh/custom}/themes/powerlevel10k

# Configure .zshrc file to use Powerlevel10k
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' /usr/share/oh-my-zsh/zshrc


echo 
echo "UBUNTU-SETUP: Succesfully installed Powerlevel10k."
echo 

} || {

echo 
echo "UBUNTU-SETUP: Failed to install Powerlevel10k."
echo 

}

{

echo 
echo "UBUNTU-SETUP: Succesfully configured Powerlevel10k."
echo 

} || {

echo 
echo "UBUNTU-SETUP: Failed to configure Powerlevel10k."
echo 

}


echo 
echo "UBUNTU-SETUP: Installing and Configuring Oh-My-Zsh with Powerlevel10k finished."
echo "UBUNTU-SETUP: Please run  'p10k configure' to create powerline10k configuration file. "
echo "-----------------------------------------------------------------------"
echo 

echo
echo "-----------------------------------------------------------------------"
echo "UBUNTU-SETUP: Installing pyenv."
echo 

export PYENV_ROOT=${home_selected}/.pyenv
curl -s https://pyenv.run | bash


tee -a /usr/share/oh-my-zsh/zshrc ${home_selected}/.profile ${home_selected}/.bashrc > /dev/null << 'EOI'

# Configuration for pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

EOI

# echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "${home_selected}/.profile"
# echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> "${home_selected}/.profile"
# echo 'eval "$(pyenv init -)"' >> "${home_selected}/.profile"

# echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "${home_selected}/.bashrc"
# echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> "${home_selected}/.bashrc"
# echo 'eval "$(pyenv init -)"' >> "${home_selected}/.bashrc"

# echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "${home_selected}/.zshrc"
# echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> "${home_selected}/.zshrc"
# echo 'eval "$(pyenv init -)"' >> "${home_selected}/.zshrc"

chown -R $user_selected:$user_selected ${home_selected}/.pyenv

echo 
echo "UBUNTU-SETUP: Installing pyenv finished."
echo "-----------------------------------------------------------------------"

echo
echo "-----------------------------------------------------------------------"
echo "UBUNTU-SETUP: Installing and Configuring Oh-My-Zsh with Powerlevel10k."
echo 

# ----------------------------------------------------------------------------
#####
# Ending setup process
#####

echo "-----------------------------------------------------------------------"
echo "UBUNTU-SETUP: Ending setup."
echo "-----------------------------------------------------------------------"
echo 

# Restart
echo "-----------------------------------------------------------------------"
echo "UBUNTU-SETUP: Please, restart terminal."
echo "-----------------------------------------------------------------------"
echo 