ACLOCAL_AMFLAGS = -I m4
AUTOMAKE_OPTIONS = 1.7

# We need to build a shared library, which can be dlopened
# it does not work with noinst_LTLIBRARIES
testlib_LTLIBRARIES = libregress.la

testlibdir = $(prefix)/unused
install-testlibLTLIBRARIES: # prevent it from being installed

libregress_la_SOURCES = $(GI_DATADIR)/tests/regress.c $(GI_DATADIR)/tests/regress.h
libregress_la_CFLAGS = $(GIO_CFLAGS) $(CAIRO_CFLAGS)
libregress_la_LDFLAGS = -module -avoid-version $(GIO_LIBS) $(CAIRO_LIBS)

# g-i doesn't ship these as shared libraries anymore; we build them here
Regress-1.0.gir: libregress.la Makefile
	$(AM_V_GEN) g-ir-scanner --include=cairo-1.0 --include=Gio-2.0 \
	--namespace=Regress --nsversion=1.0 \
	--warn-all --warn-error \
	--library=libregress.la \
	--libtool="$(top_builddir)/libtool" \
	--output $@ \
	$(libregress_la_SOURCES)
Regress-1.0.typelib: Regress-1.0.gir Makefile
	$(AM_V_GEN) g-ir-compiler $< -o $@

all: Regress-1.0.typelib
