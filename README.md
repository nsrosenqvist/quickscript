QuickScript
===========

QuickScript is a small BASH-framework for fast script development - less worry about input, error handling and logging, more creativity.

It's been added to gradually over time, mostly consisting of functions providing a stdlib functionality that is missing from BASH. A lot of the functions are short hands to built in BASH-functionality, like it's string manipulation methods, that can be very hard for beginners to discover and even harder to remember.

Features include logging functions, script instance management, and a custom getopts alternative, **qs_opts**, which is not as performant but a whole lot more flexible. It supports both long and short options, option groups, option aliases and different syntax for assigning values. It also includes input from the command line, pipes and files and abstracting it away from the user.

Check the [wiki](https://github.com/nsrosenqvist/quickscript/wiki) for API documentation.

## Installation

Clone the repository and then use make.

```BASH
git clone https://github.com/nsrosenqvist/quickscript.git && cd quickscript
make && sudo make install
```

## Development

Every part of the library must be independent from other parts, this save us from having to rebuild and eases testing and enables faster iteration. Test cases should be provided for as much as possible and tests are run with `shunit2` which can be installed from the debian repositories:

```BASH
sudo apt-get install shunit2
```

## Notices

The library is in the Public Domain (see the file UNLICENSE for info) which means that you are free to reuse the entire library or parts of it and integrate into your scripts without worrying about licensing issues. If you make improvements, please consider making a pull request.

This library is a work in progress, I'm adding as long as I go and if you want something to use as a base for all your future BASH projects then you should probably wait until 1.0.0
