# GPGMail

This is the source code for the GPG plugin for OS X's Mail.app

The latest version of the plugin for OS X 10.6.4 can be found in the Downloads
section at [http://github.com/gpgmail/GPGMail/downloads](http://github.com/gpgmail/GPGMail/downloads).

This project is currently in a heavy state of development.  For the latest
news and updates check out the mailing list at [http://sourceforge.net/mailarchive/forum.php?forum_name=gpgmail-users](http://sourceforge.net/mailarchive/forum.php?forum_name=gpgmail-users).

To build this project first run the following from the root of the repository:

    git submodule init
    git submodule update

Once that brings in the MacGPGME submodule, the project can be built from the
command line by running:

    make

