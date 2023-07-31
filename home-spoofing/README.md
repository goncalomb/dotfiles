# Home Spoofing

*This is a very old feature that I don't use for a long time. Current state is untested.*

With home spoofing you can carry your home directory with you!

Clone this repository to an external drive, then run `YOUR_DRIVE_LOCATION/dotfiles/home-spoofing/spoof.sh bash` this will open a new bash instance with the HOME path set to the external drive (see [spoof.sh](home-spoofing/spoof.sh)). It also compiles and preloads a shared library (see [preload.c](home-spoofing/preload.c)) using LD_PRELOAD, which intercepts some standard C functions to better spoof the HOME directory.

All programs started from that shell will see the spoofed HOME directory and use it to store their config files, making your HOME directory portable.

It's not required to start a shell to spoof the HOME for a specific program, just run `YOUR_DRIVE_LOCATION/dotfiles/home-spoofing/spoof.sh your_program some_argument`.

If you use GNOME, it's useful to create a `open-terminal.desktop` file on the external drive to quickly open a spoofed shell or other programs:

    [Desktop Entry]
    Terminal=true
    Name=Terminal
    Exec=bash -c "$(dirname -- "%k")/dotfiles/home-spoofing/spoof.sh bash"
    Type=Application
    Icon=gnome-panel-launcher
