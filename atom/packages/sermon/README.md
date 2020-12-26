# Serial Monitor for Atom

A simple serial monitor for Atom which allows you to e.g. connect to the serial line of your embedded device and view debug output from that device within Atom.

Please note, that this is a monitor which just prints what was received on the serial line. It does not support sending data to the device!

![screenshot](https://raw.githubusercontent.com/wendlers/atom-sermon/master/doc/sermon_0.png)

![screenshot](https://raw.githubusercontent.com/wendlers/atom-sermon/master/doc/sermon_1.png)

## Prerequisites

A working Python setup (version 2.7 or 3.x) including pySerial with version >= 2.7.
If in doubt, install with:

    sudo pip install pyserial

## Install

To install this package from the package repository:

    apm install sermon

To install from git:

    cd $HOME/.atom/packages
    git clone https://github.com/wendlers/atom-sermon sermon
    cd sermon
    apm install

## Usage

Open the settings dialog with `shift+alt+m`, select port and baudrate, then hit connect.

Beside port and baudrate, the following display settings are available from
the dialog:

* _Output format_:
  - _RAW_: Just print what was read from the serial line. Please note that with this format, there is no color and no time-stamping.
  - _Line_: This mode expects, that the output from the serial line are lines based (with new-line at the end). With this mode, it is possible to add color and time-stamps.
  - _HEX_: Show every byte received as two digit hex value. With this mode, it is possible to add color and time-stamps.
  - _HEX+ASCII_: Same as above, but with ASCII representation of the received bytes too.
* _Add timestamp_: Add a time-stamp to each line printed. Works only for _Line_ and _HEX_ / _HEX+ASCII_ formats.
* _Use color_: Add some color to the time-stamps and the ASCII representation.

The settings from the dialog are stored on a per project
basis in the the file `sermon_settings.json`.
