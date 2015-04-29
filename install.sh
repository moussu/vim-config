#!/bin/bash

error() {
	echo -e "${CRED}ERROR: $*${CNC}" >&2
	exit 1
}


safe() {
	echo -e "${CGREEN}$@${CNC}"
	"$@" || error "FAILED command:\n$*";
}


if [ $# -ne 1 ]; then
	error "Usage: $0 (vim|nvim)"
fi


TARGET_DIR=~
TARGET_DIR=$TARGET_DIR

# Backup existing configuration.
BACKUP_DIR=backup.`date +%F-%R`
mkdir -p $BACKUP_DIR

TARGET_VIMRC=$TARGET_DIR/.vimrc
TARGET_VIM_CONFIG=$TARGET_DIR/.vim

install() {
	if [ $# -ne 1 ]; then
		error "Wrong number of arguments."
	fi
	VIM=$1
	VIMDIR=$TARGET_DIR/.${VIM}
	VIMRC=$TARGET_DIR/.${VIM}rc

	echo "Backing up existing configuration to $BACKUP_DIR"
	if [ -f $VIMRC ] ; then
		safe mv $VIMRC $BACKUP_DIR/
	fi
	if [ -d $VIMDIR ] ; then
		safe mv $VIMDIR $BACKUP_DIR/
	fi

	echo "Copying new files."
	safe cp -R .vim $VIMDIR
	safe ln -s `pwd`/.vimrc $VIMRC

	echo "Installing the plugin manager."
	safe git clone https://github.com/gmarik/vundle.git $VIMDIR/bundle/vundle

	echo "Installing plugins."
	safe $VIM -c PluginInstall -c qall

	echo "Minor fixes to the config."
	# Use the diffgofile plugin for git diffs.
	safe mkdir -p $VIMDIR/ftplugin/
	safe ln -s $VIMDIR/bundle/vim-diffgofile/ftplugin/diff_gofile.vim $VIMDIR/ftplugin/git_diffgofile.vim

	echo "Done."
}

install $1
