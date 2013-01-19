# GirFFI

by Matijs van Zuijlen

[![Build Status](https://secure.travis-ci.org/mvz/ruby-gir-ffi.png)](http://travis-ci.org/mvz/ruby-gir-ffi)

## Description

Ruby bindings for GNOME using the GObject Introspection Repository.

## Features/Notes

* Create bindings to any GObject-based library.
* Bindings generated at runtime.
* Provides overridden bindings for selected methods.
* Install 'gir_ffi-gtk' and require 'gir_ffi-gtk2' or 'gir_ffi-gtk3' to
  load overrides for Gtk2 or Gtk3.

## Usage

    require 'gir_ffi'

    GirFFI.setup :TheNamespace

    TheNamespace.some_function

    obj = TheNamespace::SomeClass.new
    obj.some_method with, some, args

## Install

    gem install gir_ffi

## Requirements

GirFFI should work on MRI 1.8 and 1.9, and JRuby in both 1.8 and 1.9
modes. It does not work on Rubinius yet.

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

## Hacking and contributing

If you want to help out, have a look at TODO.rdoc, and check the notes
in the code (e.g., using `dnote`). Feel free to file bugs or send pull
requests.

If you want to send pull requests or patches, please:

* Make sure `rake test` runs without reporting any failures. If your code
  breaks existing stuff, it won't get merged in.
* Add tests for your feature. Otherwise, I can't see if it works or if I
  break it later.
* Make sure latest master merges cleanly with your branch. Things might
  have moved around since you forked.
* Try not to include changes that are irrelevant to your feature in the
  same commit.

## License

Copyright &copy; 2009&ndash;2013 [Matijs van Zuijlen](http://www.matijs.net)

GirFFI is free software, distributed under the terms of the GNU Lesser
General Public License, version 2.1 or later. See the file COPYING.LIB for
more information.
