#!/bin/bash

packageManager=""
sudo=""
flags=""

packages=()
failedPackages=()

packages+=(git)
packages+=(vim)
packages+=(tmux)
packages+=(ctags)
packages+=(curl)    # needed to install vim-plug
packages+=(maven)   # needed to build vim-javautocomplete2 plugin
packages+=(golang)
[[ $os == "Darwin" ]] && packages+=(coreutils)   # linux terminal commands
[[ $os == "Darwin" ]] && packages+=(alacritty)   # OSX best terminal
[[ $os == "Linux" ]] && packages+=(openssh-server)
[[ $os == "Linux" ]] && packages+=(git-email)    # not bundled with git on linux

# MacOS
if [[ $os == "Darwin" ]]; then

    # instal Brew package manager
    /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" || \
        err=$?

    packageManager="brew"

# Linux distribution
else

    # get the package manager for different linux distributions
    version=`cat /etc/issue | head -1 | cut -d" " -f1`
    sudo="sudo"
    if [[ $version == "Ubuntu" ]]; then
        packageManager="apt-get"
    else
        packageManager="dnf"
    fi
    flags="-y"
fi

# update the list of available packages and there versions (doesn't install anything)
$sudo $packageManager $flags update || err=$?
# install new versions of packages from the last updated list
$sudo $packageManager $flags upgrade || err=$?

# install the packages
for p in ${packages[*]} ; do
    $sudo $packageManager $flags install $p || { err=$?; failedPackages+=($p); }
done

# install vim-plug for vim, curl is a dependency and already installed
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim || \
    { err=$?; failedPackages+=(vim-plug); }

# those repositories are needed for Golang and vim-go to work properly
mkdir -p ~/go/{bin,src}

