# GirFFI

by Matijs van Zuijlen

## Description

Ruby bindings for GNOME using the GObject Introspection Repository.

## Status

[![Gem Version](https://badge.fury.io/rb/gir_ffi.svg)](http://badge.fury.io/rb/gir_ffi)
[![Dependency Status](https://gemnasium.com/mvz/gir_ffi.svg)](https://gemnasium.com/mvz/gir_ffi)
[![Build Status](https://travis-ci.org/mvz/gir_ffi.svg?branch=master)](https://travis-ci.org/mvz/gir_ffi)
[![Code Climate](https://codeclimate.com/github/mvz/gir_ffi/badges/gpa.svg)](https://codeclimate.com/github/mvz/gir_ffi)
[![Coverage Status](https://coveralls.io/repos/mvz/gir_ffi/badge.svg?branch=master&service=github)](https://coveralls.io/github/mvz/gir_ffi?branch=master)
[![Documentation Status](https://inch-ci.org/github/mvz/gir_ffi.svg?branch=master)](https://inch-ci.org/github/mvz/gir_ffi/branch/master)

## Features

* Create bindings to any GObject-based library.
* Bindings are generated at runtime.
* Provides overridden bindings for selected methods.
* Install `gir_ffi-gtk` and require `gir_ffi-gtk2` or `gir_ffi-gtk3` to
  load overrides for Gtk2 or Gtk3.

## Usage

    require 'gir_ffi'

    # Set up the namespace you wish to use
    GirFFI.setup :Gio

    # Create an object
    inet_address = Gio::InetAddress.new_from_string "127.0.0.1"

    # Call some methods on the object
    inet_address.is_loopback    # => true
    inet_address.is_multicast   # => false

    # Call a function in the namespace
    Gio.dbus_is_name "foo"   # => false

See the [documentation](docs/Documentation.md) for more usage information.

## Install

    gem install gir_ffi

## Requirements

GirFFI should work on CRuby 2.0.0, 2.1 and 2.2, JRuby 1.7.x in 1.9 or 2.0 mode,
JRuby 9.0.0.0, and on Rubinius. If you need support for CRuby 1.9.3, use
version 0.7.10.

You will also need gobject-introspection installed with some
introspection data.

Depending on the GIR data, GirFFI needs the actual libraries to be
available under the name ending in plain `.so`. If GirFFI complains that it
cannot find the library, try installing development packages for those
libraries.

GirFFI is developed on Debian sid, and tested through Travis CI on Ubuntu
12.04. Older versions of gobject-introspection than the ones used there
are therefore not officially supported (although they may work).

On Debian and Ubuntu, installing `libgirepository1.0-dev` and
`gobject-introspection` should be enough to get `rake test` working.

GirFFI has not been tested on Mac OS X or Microsoft Windows. YMMV.

## Overrides

Sometimes, the GIR data is incorrect, or not detailed enough, and a
reasonable binding cannot be created automatically. For these cases,
overrides can be defined. The following gems with overrides
already exist:

* `gir_ffi-gtk`: overrides for Gtk+ 2 and 3.
* `gir_ffi-gnome_keyring`: overrides for GnomeKeyring
* `gir_ffi-cairo`: overrides for Cairo
* `gir_ffi-pango`: overrides for Pango
* `gir_ffi-tracker`: overrides for Tracker

## Hacking and contributing

Please feel free to file bugs or send pull requests!

If you just want to help out but don't know where to start, have a look at
TODO.md, and check the notes in the code (e.g., using `dnote`).

If you want to send pull requests or patches, please try to follow these
instructions. If you get stuck, make a pull request anyway and I'll try to help
out.

* Make sure `rake test` runs without reporting any failures. If your code
  breaks existing stuff, it won't get merged in.
* Add tests for your feature. Otherwise, I can't see if it works or if I
  break it later.
* Make sure latest master merges cleanly with your branch. Things might
  have moved around since you forked.
* Try not to include changes that are irrelevant to your feature in the
  same commit.

## Contributors

The following people have contributed to GirFFI over the years:

* John Cupitt
* Marius Hanne
* Antonio Terceiro
* Matijs van Zuijlen

## License

Copyright &copy; 2009&ndash;2015 [Matijs van Zuijlen](http://www.matijs.net)

GirFFI is free software, distributed under the terms of the GNU Lesser
General Public License, version 2.1 or later. See the file COPYING.LIB for
more information.
