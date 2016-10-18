FROM ruby:2.3.1

RUN apt-get update
RUN apt-get install -y libgirepository1.0-dev
RUN apt-get install -y libcairo2-dev
RUN apt-get install -y gobject-introspection
RUN apt-get install -y gir1.2-gtop-2.0
RUN apt-get install -y gir1.2-pango-1.0
RUN apt-get install -y gir1.2-secret-1
RUN apt-get install -y gir1.2-gstreamer-1.0
RUN apt-get install -y gir1.2-gtk-3.0

RUN mkdir /gir_ffi
WORKDIR /gir_ffi
ADD . /gir_ffi
