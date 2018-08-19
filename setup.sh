#!/bin/bash 


# install the fastest terminal available because all macOS terminal are slow
function install_alacritty_termianl {

    currentDir=`pwd`
    cd ~

    # download and install Rust compiler needed to build alacritty
    curl https://sh.rustup.rs -sSf | sh

    # make sure to have the right compiler installed
    rustup override set stable
    rustup update stable

    # clone and install alacritty
    git clone https://github.com/jwilm/alacritty.git
    cd alacritty
    make app

    # add it to mac applications
    cp -r target/release/osx/Alacritty.app /Applications/

    # remove cloned folder
    rm -rf ~/alacritty

    # remove 2 last line of ~.bash_profile because this installation is adding
    # /home/.cargo/bin to $PATH but this is already done in ~/.bashrc
    cp ~/.bash_profile ~/.bash_profile.tmp1
    sed '$ d' ~/.bash_profile.tmp1 > ~/.bash_profile.tmp2
    sed '$ d' ~/.bash_profile.tmp2 > ~/.bash_profile
    rm -f ~/.bash_profile.tmp1 ~/.bash_profile.tmp2

    cd $currentDir
}


# install all the packages received in arguments and update failedPackages array.
function install_packages {

    packageManager=""
    sudo=""

    # install vim-plug for vim
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim || \
        failedPackages+=(vim-plug)

    # MacOS
    if [[ $os == "Darwin" ]]; then

        # instal Brew package manager
        /usr/bin/ruby -e \
            "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

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
    fi

    # install the packages
    for p in $@ ; do
        $sudo $packageManager install $p || failedPackages+=($p)
    done


    # this is done last
    $sudo $packageManager update
}


# create soft links for all dotfiles
function create_dotfiles_soft_links {

    for l in $@; do

        # ssh.config need a special repo in ~
        if [[ $l == "ssh.config" ]]; then
            if ! [[ -d ~/.ssh ]]; then
                mkdir ~/.ssh
            fi
            ln -s -f $clonedDir/dotfiles/$l ~/.ssh/config && echo "copy .$l..."
        else
            ln -s -f $clonedDir/dotfiles/$l ~/.$l && echo "copy .$l..."
        fi
    done
}


# create soft links for all acfiles (auto-completion files)
function create_acfiles_soft_links {

    for l in $@; do
        ln -s -f $clonedDir/acfiles/$l /usr/local/etc/bash_completion.d/$l && \
            echo "copy /usr/local/etc/bash_completion.d/$l..."
    done
}


# get script parameters
flag=$1

# determine which OS is running, "Linux" for linux and "Darwin" for macOS
os=`uname -s`
if [[ $os != "Darwin" && $os != "Linux" ]];then
    echo ------------------------
    echo "Cannot determine OS!"
    echo ------------------------
    exit 1
fi

if [[ $flag == "--help" ]]; then
    echo "usage: $0 [--no-sudo]"
    exit
fi


# install alacritty terminal for macOS
if [[ $os == "Darwin" ]]; then
    install_alacritty_termianl
fi


# if --no-sudo flag is on then skip the commands that require sudo
if [[ $flag != "--no-sudo" ]]; then

    # create a list of packages and install them
    packages=()
    failedPackages=()
    packages+=(vim)
    packages+=(tmux)
    packages+=(ctags)
    packages+=(cscope)
    packages+=(valgrind)
    packages+=(curl)    # needed to install vim-plug
    packages+=(figlet)  # needed for scripts/git_check_status.sh output
    packages+=(maven)   # needed to build vim-javautocomplete2 plugin
    [[ $os == "Darwin" ]] && packages+=(coreutils)   # linux terminal commands
    [[ $os == "Linux" ]] && packages+=(openssh-server)
    install_packages ${packages[*]}

fi


# creates soft links to all dotfile
links=()
failedLinks=()
GIT_DIR_NAME="MyLinuxConfig"
clonedDir=`find ~ -name $GIT_DIR_NAME`
links+=("bashrc")
links+=("bash_profile")
links+=("aliases")
links+=("vimrc")
links+=("tmux.conf")
links+=("launchers")
links+=("gitconfig")
links+=("ssh.config")
[[ $os == "Darwin" ]] && links+=("alacritty.yml")
create_dotfiles_soft_links ${links[*]}


# creates soft links to all acfile
links=()
failedLinks=()
GIT_DIR_NAME="MyLinuxConfig"
clonedDir=`find ~ -name $GIT_DIR_NAME`
links+=("ssh")
[[ $os == "Darwin" ]] && create_acfiles_soft_links ${links[*]}


# without this sometimes ssh command doesn't work
chmod 600 ~/.ssh/config


# make sure all VMs are accessible via SSH
if [[ $os == "Linux" ]]; then
    systemctl restart sshd
    systemctl enable sshd
fi


# macOS terminal source .bash_profile and linux terminal source .bashrc, so
# this solution covers both cases since .bash_profile source .bashrc
if [ -e ~/.bash_profile ] ; then
    echo source ~/.bash_profile...
    source ~/.bash_profile
fi


# print summary
echo --------------------------------------------------------
echo "SUMMARY:"
if (( ${#failedPackages[*]} > 0)); then
    echo -e "\n\tCannot install:"
    for up in ${failedPackages[*]}; do
        echo -e "\t\t-$up"
    done
else
    echo -e "\n\tAll packages were installed successfully"
fi
echo --------------------------------------------------------

