GPGMail
=======

GPGMail is a plugin for OS X's Mail.app, which let's you <br>send
and receive secure, OpenPGP encrypted and signed messages.

Updates
-------

The latest releases of GPGMail can be found on our official website [http://www.gpgtools.org/gpgmail/index.html](http://www.gpgtools.org/gpgmail/index.html).

The project is currently in a heavy state of development. For the latest news and updates check our Twitter [http://twitter.com/gpgtools](http://twitter.com/gpgtools)

Build
-----

Building is as easy a make command.

### Clone the repository

    git clone --recursive https://github.com/GPGTools/GPGMail.git -b dev
    cd GPGMail

### Aaaand build

    make update-libmacgpg && CONFIG=Debug make


Enjoy your custom GPGMail.

