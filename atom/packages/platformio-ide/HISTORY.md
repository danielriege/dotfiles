# Release Notes

# 2.7.2

* Fixed an issue when Atom has become unresponsive (issue [#2444](https://github.com/platformio/platformio-atom-ide/issues/2444))

## 2.7.1 (2020-06-14)

* Fixed an error "ENOENT: no such file or directory, open '~/.platformio/homestate.json'"

## 2.7.0 (2020-06-13)

* New PlatformIO Core Installer
  - Switched to the cross-platform and portable [get-platformio.py](https://github.com/platformio/platformio-core-installer) installer script
  - Use built-in portable Python 3 on Windows
* Added support for ``extends`` option in ``platformio.ini`` project configuration file
* Reduced startup time (PIO Core verification process)

## 2.6.0 (2019-11-20)

- Minimal requirements for PlatformIO Core is >=4.1.0
- Added PIO Check project task
- Automatically shutdown PIO Home server after 1-hour inactivity
- Ignore PIO Home from Proxy using `NO_PROXY` environment variable
- PlatformIO Core Installer:
    * Updated default Python installer to 3.7.5
    * Check Python's "urllib" SSL module
    * Skip Python from msys, mingw, emacs installations

## 2.5.0 (2019-10-31)

* Handle "openTextDocument" in VSCode from upcoming PIO Home 3.0 and Project Inspect
* Use single PIO Home Server instance per multiple windows/sessions
* Fixed an issue with broken GCC Linter

## 2.4.1 (2019-07-19)

* Fixes typos in modal windows

## 2.4.0 (2019-07-19)

* Full support for [PlatformIO Core 4.0](https://community.platformio.org/t/platformio-core-4-0-is-finally-released/8587)
* PlatformIO Core Installer:
    - Added support for Python 3 and its "venv" module
    - Added [PIO Remote](http://docs.platformio.org/en/latest/plus/pio-remote.html) project tasks
    - Added "Fuses" related project tasks
    - Added "Erase" project task for Espressif and Nordic dev/platforms
    - Implemented ProjectConfig parser following PIO Core 4.0 specification
    - Support custom port for PIO Home server
    - Override default `~/.platformio/penv` folder with environment variable `PLATFORMIO_PENV_DIR`
* Removed 'showPlatformIOFiles' configuration option, `.pio` folder will shown automatically in project tree

## 2.3.1 (2018-12-12)

* Use stable PlatformIO Core by default
* Updated minimal dependency of PlatformIO Core to >=3.6.3

## 2.3.0 (2018-11-30)

* PlatformIO Core Installer:
    * Drop SockJS, switch to native WebSockets
    * Catch errors when upgrading PIP (issue [#436](https://github.com/platformio/platformio-vscode-ide/issues/436))
    * Check for official Python installation on Windows (resolves issue with a static "sys.prefix" and custom Python builds) (issue [#154](https://github.com/platformio/platformio-vscode-ide/issues/154))
* Updated minimal dependency of PlatformIO Core to >=3.6.2

## 2.2.6 (2018-11-23)

* Use actual Python path when creating a virtual environment
* Shutdown all PIO Home servers when can't start a new one
* Better explanation about PIP issue on Windows

## 2.2.5 (2018-11-17)

* Added support for upcoming native WebSockets for PIO Home
* Updated PlatformIO Core installer's `virtualenv` to 16.1.0

## 2.2.4 (2018-10-29)

* Removed "Upload and Monitor" project task (fixed "Inappropriate ioctl for device (error 25)")
  If you need this task, please switch to [PlatformIO IDE for VSCode](https://marketplace.visualstudio.com/items?itemName=platformio.platformio-ide)

## 2.2.3 (2018-10-26)

* Handle "Error: Could not create PIO Core Virtual Environment" and propose user to file an issue

## 2.2.2 (2018-09-08)

* Improved performance of Project IntelliSense Indexer
* Fixed PlatformIO Core "ImportError: cannot import name remove_dead_weakref"
* Fixed PIO Home "[Errno 48] Address already in use"

## 2.2.1 (2018-08-31)

* Fixed issue with broken Project IntelliSense Indexer

## 2.2.0 (2018-08-28)

* Refactored Project IntelliSense Indexer and Task Manager

## 2.1.13 (2018-08-11)

* Fixed double URI encoding when reporting issue to GitHub

## 2.1.12 (2018-07-27)

* Improved PlatformIO Core installer

## 2.1.11 (2018-07-19)

* Fixed "Cannot find module 'tslib'"

## 2.1.10 (2018-07-19)

* Fixed broken integration with PIO Home

## 2.1.9 (2018-07-19)

* Fixed "PIP: Command "python setup.py egg_info" failed" (issue [#1950](https://github.com/platformio/platformio-atom-ide/issues/1950))

## 2.1.8 (2018-07-17)

* Instruction how to manually create [PIO Core Virtual Environment](http://docs.platformio.org/page/installation.html#virtual-environment)
* Deprecate [PIO Unified Debugger](http://docs.platformio.org/page/plus/debugging.html) for Atom

## 2.1.7 (2018-06-26)

* Handle PIO Home server errors
* Install `virtualenv` to the global scope if possible

## 2.1.6 (2018-06-21)

* Fixed an issue with infinite PIO Core installation [#1925](https://github.com/platformio/platformio-atom-ide/issues/1925))

## 2.1.5 (2018-06-20)

* Pre-fill GitHub issue template with system data
* Improved PIO Core installer using `pip` as Python module

## 2.1.4 (2018-04-09)

* Automatically install related packages to PIO Home

## 2.1.3 (2018-03-13)

* Speed up the loading of [PIO Home](http://docs.platformio.org/page/home/index.html)

## 2.1.2 (2018-03-08)

* Fixed endless loop with installing PIO Core when `platformio-ide.useDevelopmentPIOCore` is set to `false`

## 2.1.1 (2018-03-05)

* Fixed "Cannot read property 'theme' of undefined" when opening [PIO Home](http://docs.platformio.org/page/home/index.html)

## 2.1.0 (2018-03-03)

* Multiple themes (Dark & Light) for [PIO Home](http://docs.platformio.org/page/home/index.html)
* Fixed GitHub's "TLSV1_ALERT_PROTOCOL_VERSION" issue with PIO Core installer (issue [#1551](https://github.com/platformio/platformio-atom-ide/issues/1551))

## 2.0.1 (2018-01-30)

* Significantly improved startup time of [PIO Unified Debugger](http://docs.platformio.org/page/plus/debugging.html)

## 2.0.0 (2018-01-23)

* PlatformIO Home
  - PIO Account
  - Library Manager
  - Board Explorer
  - Platform Manager
* New PlatformIO IDE Installer
  - Asynchronous tasks
  - Compatible with Anaconda
  - Allowed disabling non-required Atom's dependencies
* [PIO Unified Debugger](http://docs.platformio.org/page/plus/debugging.html)
* Added command/hotkey for PIO Core `program` target ([#154](https://github.com/platformio/platformio-atom-ide/issues/154))
* Intelligent Code Completion + GoTo Declaration for Windows
* Switched to Apache License 2.0

## 1.7.3 (2017-03-04)

* Notify about outdated Atom
* Revert to the previous version of `request` package and fixed ([#249](https://github.com/platformio/platformio-atom-ide/issues/249))

## 1.7.2 (2017-02-01)

* Fixed "deprecations" warning in Atom 1.13

## 1.7.1 (2016-12-02)

* Fixed Atom issue with initial installation

## 1.7.0 (2016-12-01)

* Added new Toolbar button to run other targets
* Added new Toolbar button to toggle Build Panel
* Added file specific icons to TreeView
* Added Minimap with preview of the full source code
* Fixed "Menu: PlatformIO > Install Shell Commands" for Windows
* Fixed issue with "Uncought Error: Failed to get boards"

## 1.6.0 (2016-09-19)

* Library Manager page with advanced explanations how to use it
* Asynchronous C/C++ project index rebuilding (Autocomplete, Linter)
* Added new setting `Show PlatformIO service files` in Tree View that is turned off by default
* Added new baudrates (460800 and 921600) to Serial Port Monitor

## 1.5.0 (2016-09-08)

* Full support of PlatformIO CLI 3.0
* Integrated Local and Embedded [PlatformIO Unit Testing](http://docs.platformio.org/en/stable/plus/unit-testing.html)
* Added new baudrates (74880 and 250000) to Serial Port Monitor
* Updated "Initialize or Update PlatformIO Project" wizard with explanations

## 1.4.0 (2016-08-02)

* Added "Local echo" to advanced settings for Serial Port Monitor ([#144](https://github.com/platformio/platformio-atom-ide/issues/144))
* Improved PlatformIO IDE Installer for Linux Arch and macOS ([#146](https://github.com/platformio/platformio-atom-ide/issues/146))

## 1.3.6 (2016-07-25)

* Reverted back to Python's `virtualenv` 15.0.1. Previous
  version doesn't work on Windows ([virtualenv #929](https://github.com/pypa/virtualenv/issues/929))

## 1.3.5 (2016-07-22)

* Fixed broken download URL for Python's `virtualenv` package

## 1.3.4 (2016-07-21)

* Improved cache system of PlatformIO IDE Installer
* Force open Tree View when new project is added/opened
* Fixed issue "‘platformio’ is not recognized as an internal or external command" for Windows OS ([#138](https://github.com/platformio/platformio-atom-ide/issues/138))

## 1.3.3 (2016-07-14)

* Fixed issue with "Import Arduino IDE Project..." when compatibility is enabled

## 1.3.2 (2016-07-13)

* Hotfix for "Uncaught Error" issue when "Settings" or "About" tabs are opened ([#137](https://github.com/platformio/platformio-atom-ide/issues/137))

## 1.3.1 (2016-07-12)

* Handle `Path` and `PATH` environment variables for Windows OS ([#134](https://github.com/platformio/platformio-atom-ide/issues/134))
* Better handling of opened projects with soft links ([#136](https://github.com/platformio/platformio-atom-ide/issues/136))
* Improved compatibility with Arduino IDE when "Import Arduino IDE Project..." is used
* Fixed issue with upgrading PlatformIO IDE from Atom Registry

## 1.3.0 (2016-06-28)

* Initial support of PlatformIO 3.0 CLI
* Added advanced "Encoding" option (`hexlify`) for the Serial Monitor ([#118](https://github.com/platformio/platformio-atom-ide/issues/118))
* Automatically select active project directory for "Initialize Project..." ([#131](https://github.com/platformio/platformio-atom-ide/issues/131))
* Export IDE's process `PATH` to the PlatformIO Terminal ([#47](https://github.com/platformio/platformio-atom-ide/issues/47))
* Cleanup dead installation lock file ([#113](https://github.com/platformio/platformio-atom-ide/issues/113))
* Fixed issue with Python and system locale ([#112](https://github.com/platformio/platformio-atom-ide/issues/112))

## 1.2.2 (2016-05-13)

* Fixed typo in the "Home Screen"

## 1.2.1 (2016-04-29)

* Fixed issue with Project Examples under Windows OS

## 1.2.0 (2016-04-28)

* **Home Screen**: Recent projects, quick access panel, IDE/CLI version information
* **Project Examples**: Learn PlatformIO with pre-configured Project Examples
* Jump to C/C++ Declaration via hotkey `f3`
* Added `DTR` and `RTS` options to Serial Monitor
* Added `Raw` (do not apply any encodings/transformations) option to Serial Monitor
* Remember all Serial Monitor options (including advanced settings)

## 1.1.2 (2016-04-15)

* Hotfix for Atom's bug with `process.env.PATH` ([#94](https://github.com/platformio/platformio-atom-ide/issues/94))
* Updated PlatformIO IDE Terminal for Atom 1.7
* Use confirmation instead notification when can't activate Smart Code Linter
  or Intelligent Code Completion

## 1.1.1 (2016-03-28)

* Added `Menu: PlatformIO > Update Atom packages` item
* Fixed "Uncaught Error: ENOENT: no such file or directory, scandir
  'atom://config'" ([#80](https://github.com/platformio/platformio-atom-ide/issues/80))

## 1.1.0 (2016-03-22)

* Automatically rebuild C/C++ Project Index (Autocomplete, Linter) when new
  libraries are added or "platformio.ini" is modified
* Pause serial monitor during (serial) upload ([#45](https://github.com/platformio/platformio-atom-ide/issues/45))
* Better handling of an active project
* Prevented unnecessary displaying of "PlatformIO IDE installation suspended"
* Fixed "'platformio' could not be spawned" ([#66](https://github.com/platformio/platformio-atom-ide/issues/66))
* Fixed error matcher for build results. Use `cmd-alt-g` / `ctrl-alt-g` /
  `f4` to cycle through causes of build error

## 1.0.5 (2016-03-07)

* Show progress information while initializing new project ([#49](https://github.com/platformio/platformio-atom-ide/issues/49))
* Highlight active project when more than one is opened (can be disabled
  in PlatformIO IDE Settings)
* Added settings for dependent packages to `Menu: PlatformIO > Settings` ([#57](https://github.com/platformio/platformio-atom-ide/issues/57))
* Added hotkey `cmd-shift-m / alt-shift-m` for Serial Monitor  ([#59](https://github.com/platformio/platformio-atom-ide/issues/59))
* Redirect for donation to main site http://platformio.org/donate
* Removed "Serial Ports List" from PlatformIO Toolbar
* Updated icons for Serial Monitor and Library Manager
* Fixed auto installer behind proxy ([#48](https://github.com/platformio/platformio-atom-ide/issues/48))
* Fixed loop in updater ([#55](https://github.com/platformio/platformio-atom-ide/issues/55), [#63](https://github.com/platformio/platformio-atom-ide/issues/63))
* Fixed issue with Serial Monitor when port contains spaces ([#62](https://github.com/platformio/platformio-atom-ide/issues/62))
* Fixed bug with incorrect determining of active project ([#58](https://github.com/platformio/platformio-atom-ide/issues/58))

## 1.0.4 (2016-02-20)

* Fixed IDE keep showing "Reload Now" popup at launch

## 1.0.3 (2016-02-20)

* Fixed installer for dependencies

## 1.0.2 (2016-02-20)

* Use PlatformIO DL infrastructure to download dependencies instead SourceForge

## 1.0.1 (2016-02-19)

* Automatically rebuild C/C++ Project Index (Autocomplete, Linter) for non IDE projects
* Improved layout for Init/Import Project panels
* Disable "Initialize" button while initializing new project (it may take for a while)
* Notify that Smart Code Linter is disabled by default for Arduino files (`*.ino` and `*.pde`)

## 1.0.0 (2016-02-18)

* New Terminal with PTY support
* Built-in Serial Monitor
* Implemented "Import Arduino IDE Project..."
* Added "Donate" form
* Remember serial port and speed when selecting Serial Monitor ([#31](https://github.com/platformio/platformio-atom-ide/issues/32))
* Fixed with multi-projects building ([#31](https://github.com/platformio/platformio-atom-ide/issues/31))

## 0.3.3 (2016-01-31)

* Temporary switched to `virtualenv` 14.0.1 because ([virtualenv bug #856](https://github.com/pypa/virtualenv/issues/856))

## 0.3.2 (2016-01-31)

* Note: Switched to PlatformIO development version
* Improved PlatformIO installer
* Fixed with ignoring position of Toolbar specified by user

## 0.3.1 (2016-01-29)

* Added `Find in Project...` button to Toolbar
* Set Toolbar to the left position by default

## 0.3.0 (2016-01-29)

* Added Toolbar with buttons for the most useful commands
* Generate env-specific build targets ([#10](https://github.com/platformio/platformio-atom-ide/issues/10))
* Reverted back "Serial Terminal"
* Allowed to rebuild C/C++ Project Index (Autocomplete, Linter) ([#20](https://github.com/platformio/platformio-atom-ide/issues/20))
* Multiple projects workflow within single window using `File > Add Project Folder...`.
* Allowed to use development version of PlatformIO (package settings)

## 0.2.1 (2016-01-25)

* Temporary disabled Serial Monitor (`kill` doesn't work)
* Fixed missed link for error line in the build output

## 0.2.0 (2016-01-25)

* Implemented Serial Monitor using [platformio serialports monitor](http://docs.platformio.org/en/stable/userguide/cmd_serialports.html#platformio-serialports-monitor) ([#13](https://github.com/platformio/platformio-atom-ide/issues/13))
* New improved Terminal for PlatformIO CLI (`pio`, `platformio`)
* Improved C/C++ code linting using PlatformIO’s platform dependent GCC toolchains
* Added `Library Manager` to menu
* Use short `pio` command instead of `platformio` in Terminal
* Fixed incorrect IDE version in `Menu: PlatformIO > Help > About`

## 0.1.1 (2016-01-24)

* Force intelligent code completion and code linting for `*.ino` and `*.pde` files
* Disabled progress bar for PlatformIO's package/library downloader and uploader

## 0.1.0 (2016-01-24)

* Birth! First release
