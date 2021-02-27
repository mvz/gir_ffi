# Instructions
# ------------
#
# Build the Docker image using:
#
#   docker build -t test-gir_ffi .
#
# You can pick any image name instead of test-gir_ffi, of course. After the
# build is done, run bash interactively inside the image like so:
#
#   docker run -v $PWD:/gir_ffi --rm -it test-gir_ffi:latest bash
#
# The `-v $PWD:/gir_ffi` will make the container pick up any changes to the
# code, so you can edit and re-run the tests.

FROM ruby:2.5

RUN apt-get update
# Provides libgirepository-1.0.so.1
RUN apt-get install -y libgirepository-1.0-1
# Provides source code for test libraries and tools to generate introspection data
RUN apt-get install -y gobject-introspection
# Provides gir files for various libraries, needed for generating gir files
# for test libraries
RUN apt-get install -y libgirepository1.0-dev
# The following packages provide typelibs for various libraries
RUN apt-get install -y gir1.2-gtop-2.0
RUN apt-get install -y gir1.2-gtk-3.0
RUN apt-get install -y gir1.2-pango-1.0
RUN apt-get install -y gir1.2-secret-1
RUN apt-get install -y gir1.2-gstreamer-1.0
RUN apt-get install -y gir1.2-gtksource-3.0

# Ensure Bundler 2.x is installed
RUN gem update bundler

RUN mkdir /gir_ffi
WORKDIR /gir_ffi

# Add just the files needed for running bundle
ADD Gemfile gir_ffi.gemspec Manifest.txt /gir_ffi/
ADD lib/gir_ffi/version.rb /gir_ffi/lib/gir_ffi/version.rb

# Install dependencies
RUN bundle

# Add the full source code
ADD . /gir_ffi
