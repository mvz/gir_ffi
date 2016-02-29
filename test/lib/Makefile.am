ACLOCAL_AMFLAGS = -I m4
AUTOMAKE_OPTIONS = 1.7

# We need to build a shared library, which can be dlopened
# it does not work with noinst_LTLIBRARIES
testlib_LTLIBRARIES = \
	libeverything.la \
	libgimarshallingtests.la libregress.la libutility.la libwarnlib.la

testlibdir = $(prefix)/unused
GI_TESTDIR = $(GI_DATADIR)/tests
install-testlibLTLIBRARIES: # prevent it from being installed

libeverything_la_SOURCES = $(GI_DATADIR)/tests/everything.c $(GI_DATADIR)/tests/everything.h
libeverything_la_CFLAGS = $(GLIB_CFLAGS)
libeverything_la_LDFLAGS = -module -avoid-version

libgimarshallingtests_la_SOURCES = $(GI_DATADIR)/tests/gimarshallingtests.c $(GI_DATADIR)/tests/gimarshallingtests.h
libgimarshallingtests_la_CFLAGS = $(GIO_CFLAGS)
libgimarshallingtests_la_LDFLAGS = -module -avoid-version

libregress_la_SOURCES = $(GI_TESTDIR)/regress.c $(GI_TESTDIR)/regress.h

if HAVE_EXTRA_TEST_FILES
libregress_la_SOURCES += \
	$(GI_TESTDIR)/annotation.c $(GI_TESTDIR)/annotation.h \
	$(GI_TESTDIR)/foo.c $(GI_TESTDIR)/foo.h \
	$(GI_TESTDIR)/drawable.c $(GI_TESTDIR)/drawable.h
endif

libregress_la_CFLAGS = $(GIO_CFLAGS) $(CAIRO_CFLAGS)
libregress_la_LDFLAGS = -module -avoid-version $(GIO_LIBS) $(CAIRO_LIBS)

if HAVE_EXTRA_TEST_FILES
libutility_la_SOURCES = $(GI_DATADIR)/tests/utility.c $(GI_DATADIR)/tests/utility.h
libutility_la_CFLAGS = $(GLIB_CFLAGS)
libutility_la_LDFLAGS = -module -avoid-version

libwarnlib_la_SOURCES = $(GI_DATADIR)/tests/warnlib.c $(GI_DATADIR)/tests/warnlib.h
libwarnlib_la_CFLAGS = $(GIO_CFLAGS)
libwarnlib_la_LDFLAGS = -module -avoid-version
endif

GIRS = Everything-1.0.gir GIMarshallingTests-1.0.gir Regress-1.0.gir

Everything-1.0.gir: libeverything.la
	$(AM_V_GEN) g-ir-scanner --include=GLib-2.0 \
	--namespace=$(@:-1.0.gir=) --nsversion=1.0 \
	--warn-all --warn-error \
	--library=$< --libtool="$(top_builddir)/libtool" \
	--output $@ $(libeverything_la_SOURCES)
Everything-1.0.typelib: Everything-1.0.gir
	$(AM_V_GEN) g-ir-compiler $< -o $@

GIMarshallingTests-1.0.gir: libgimarshallingtests.la
	$(AM_V_GEN) g-ir-scanner --include=Gio-2.0 \
	--namespace=GIMarshallingTests --nsversion=1.0 \
	--symbol-prefix=gi_marshalling_tests \
	--warn-all --warn-error \
	--library=libgimarshallingtests.la \
	--libtool="$(top_builddir)/libtool" \
	--output $@ \
	$(libgimarshallingtests_la_SOURCES)
GIMarshallingTests-1.0.typelib: GIMarshallingTests-1.0.gir
	$(AM_V_GEN) g-ir-compiler $< -o $@

regress_SCANNER_INCLUDES= --include=cairo-1.0 --include=Gio-2.0

Regress-1.0.gir: libregress.la
	$(AM_V_GEN) g-ir-scanner $(regress_SCANNER_INCLUDES) \
	--namespace=Regress --nsversion=1.0 --pkg=cairo-gobject \
	--warn-all --warn-error \
	--library=libregress.la \
	--libtool="$(top_builddir)/libtool" \
	--output $@ \
	$(libregress_la_SOURCES)
Regress-1.0.typelib: Regress-1.0.gir
	$(AM_V_GEN) g-ir-compiler --includedir=. $< -o $@

if HAVE_EXTRA_TEST_FILES

GIRS += Utility-1.0.gir WarnLib-1.0.gir
Regress-1.0.gir: Utility-1.0.gir
regress_SCANNER_INCLUDES += --include-uninstalled=Utility-1.0.gir

Utility-1.0.gir: libutility.la
	$(AM_V_GEN) g-ir-scanner --include=GLib-2.0 --include=GObject-2.0 \
	--namespace=$(@:-1.0.gir=) --nsversion=1.0 \
	--warn-all --warn-error \
	--library=$< --libtool="$(top_builddir)/libtool" \
	--output $@ $(libutility_la_SOURCES)
Utility-1.0.typelib: Utility-1.0.gir
	$(AM_V_GEN) g-ir-compiler $< -o $@

WarnLib-1.0.gir: libwarnlib.la
	$(AM_V_GEN) g-ir-scanner --include=Gio-2.0 \
	--namespace=$(@:-1.0.gir=) --nsversion=1.0 \
	--symbol-prefix=warnlib \
	--warn-all \
	--library=$< --libtool="$(top_builddir)/libtool" \
	--output $@ $(libwarnlib_la_SOURCES)
WarnLib-1.0.typelib: WarnLib-1.0.gir
	$(AM_V_GEN) g-ir-compiler $< -o $@

endif

.la.so:
	test -L $@ || $(LN_S) .libs/$@ $@

all: $(testlib_LTLIBRARIES:.la=.so) $(GIRS:.gir=.typelib)
