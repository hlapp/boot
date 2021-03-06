#!/bin/bash

# install brew package manager
echo "Installing brew package manager"
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

# install pip python package manager
echo "Installing pip package manager"
curl -fsSL https://raw.github.com/pypa/pip/master/contrib/get-pip.py --output get-pip.py
sudo python get-pip.py
sudo pip install virtualenv

# installing brew formulae
for pkg in `cat brew-formulae.txt` ; do
    brew install $pkg
done

# create python virtual envs
echo "Creating Python virtual environments"

# directory holding virtualenvs
pyenv_dir=$HOME/.pyenv
test -d $pyenv_dir || mkdir $pyenv_dir

for venv in `ls requirements-*.txt | perl -p -e 's/.*-(\w+)\.txt/$1/;'` ; do
    echo "########### $venv"
    (cd $pyenv_dir; virtualenv $venv)
done

# install packages needed in each virtual env
echo "Installing package requirements for Python virtual environments" 

# this is needed at least for numpy to build successfully
export CC=clang
export CXX=clang++
export FFLAGS=-ff2c

# this is needed for matplotlib to build successfully
test -d /usr/local/include/freetype || sudo ln -s /usr/X11/include/freetype2/freetype /usr/local/include/freetype

for venv in `ls requirements-*.txt | perl -p -e 's/.*-(\w+)\.txt/$1/;'` ; do
    echo "########### $venv"
    . $pyenv_dir/$venv/bin/activate
    pip install -r requirements-$venv.txt
done

# cleanup in case we add stuff later
unset CC
unset CXX
unset FFLAGS

# finally, we'll switch from the bootstrapped Git OSX Installer-installed
# version of git to the one managed by brew
echo "Uninstalling and reinstalling git"
sudo bash uninstall-bootstrapped-git.sh
brew install git
