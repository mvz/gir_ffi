# GirFFI

by Matijs van Zuijlen

## Description

Ruby bindings for GNOME using the GObject Introspection Repository.

## Status

[![Gem Version](https://badge.fury.io/rb/gir_ffi.svg)](http://badge.fury.io/rb/gir_ffi)
[![Build Status](https://github.com/mvz/gir_ffi/actions/workflows/ruby.yml/badge.svg)](https://github.com/mvz/gir_ffi/actions/workflows/ruby.yml)
[![Code Climate](https://codeclimate.com/github/mvz/gir_ffi/badges/gpa.svg)](https://codeclimate.com/github/mvz/gir_ffi)
[![Documentation Status](https://inch-ci.org/github/mvz/gir_ffi.svg?branch=master)](https://inch-ci.org/github/mvz/gir_ffi)

## Features

* Create bindings to any GObject-based library.
* Bindings are generated at runtime.
* Provides overridden bindings for selected methods.
* Install `gir_ffi-gtk` and require `gir_ffi-gtk2` or `gir_ffi-gtk3` to
  load overrides for Gtk2 or Gtk3.

## Usage

```ruby
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
```

See the [documentation](docs/Documentation.md) for more usage information.

## Examples

Have a look in the `examples/` directory for some simple examples. More
examples can be found in the repositories for
[`gir_ffi-gtk`](https://github.com/mvz/gir_ffi-gtk) and
[`gir_ffi-gst`](https://github.com/mvz/gir_ffi-gst/).

## Install

```bash
gem install gir_ffi
```

## Requirements

GirFFI is supported on CRuby 2.7, 3.0 and 3.1.

You will also need gobject-introspection installed with some
introspection data.

Depending on the GIR data, GirFFI needs the actual libraries to be
available under the name ending in plain `.so`. If GirFFI complains that it
cannot find the library, try installing development packages for those
libraries.

GirFFI should work with gobject-introspection 1.56.0 and up, and glib 2.56.0
and up.

On Debian and Ubuntu, installing `libgirepository-1.0-1` and `gir1.2-glib-2.0`
should be enough to use GirFFI in your application.

To run the tests, you should additionally install `libgirepository1.0-dev`,
`gobject-introspection`, `libcairo2-dev`, `gir1.2-gtop-2.0`, `gir1.2-gtk-3.0`,
`gir1.2-pango-1.0`, `gir1.2-gtksource-3.0`, `gir1.2-secret-1` and
`gir1.2-gstreamer-1.0`. This should be enough to get `rake test` working.

GirFFI has not been tested on Mac OS X or Microsoft Windows. YMMV. Pull
requests to support these platforms are welcome.

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
* `gir_ffi-gst`: overrides for GStreamer

## Contributing

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## Contributors

The following people have contributed to GirFFI over the years:

* John Cupitt
* Marius Hanne
* Antonio Terceiro
* Matijs van Zuijlen

## License

Copyright &copy; 2009&ndash;2022 [Matijs van Zuijlen](http://www.matijs.net)

GirFFI is free software, distributed under the terms of the GNU Lesser
General Public License, version 2.1 or later. See the file COPYING.LIB for
more information.
