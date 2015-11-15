ACLOCAL_AMFLAGS = -I m4
AUTOMAKE_OPTIONS = 1.7

# We need to build a shared library, which can be dlopened
# it does not work with noinst_LTLIBRARIES
testlib_LTLIBRARIES = libannotation.la libregress.la libgimarshallingtests.la

testlibdir = $(prefix)/unused
install-testlibLTLIBRARIES: # prevent it from being installed

libannotation_la_SOURCES = $(GI_DATADIR)/tests/annotation.c $(GI_DATADIR)/tests/annotation.h
libannotation_la_CFLAGS = $(GLIB_CFLAGS)
libannotation_la_LDFLAGS = -module -avoid-version

libregress_la_SOURCES = $(GI_DATADIR)/tests/regress.c $(GI_DATADIR)/tests/regress.h
libregress_la_CFLAGS = $(GIO_CFLAGS) $(CAIRO_CFLAGS)
libregress_la_LDFLAGS = -module -avoid-version $(GIO_LIBS) $(CAIRO_LIBS)

libgimarshallingtests_la_SOURCES = $(GI_DATADIR)/tests/gimarshallingtests.c $(GI_DATADIR)/tests/gimarshallingtests.h
libgimarshallingtests_la_CFLAGS = $(GIO_CFLAGS)
libgimarshallingtests_la_LDFLAGS = -module -avoid-version

# g-i doesn't ship these as shared libraries anymore; we build them here
RegressAnnotation-1.0.gir: libannotation.la Makefile
	$(AM_V_GEN) g-ir-scanner --include=cairo-1.0 --include=Gio-2.0 \
	--namespace=RegressAnnotation --nsversion=1.0 \
	--warn-all --warn-error \
	--library=libannotation.la \
	--libtool="$(top_builddir)/libtool" \
	--output $@ \
	$(libannotation_la_SOURCES)
RegressAnnotation-1.0.typelib: RegressAnnotation-1.0.gir Makefile
	$(AM_V_GEN) g-ir-compiler $< -o $@

Regress-1.0.gir: libregress.la Makefile
	$(AM_V_GEN) g-ir-scanner --include=cairo-1.0 --include=Gio-2.0 \
	--namespace=Regress --nsversion=1.0 --pkg=cairo-gobject \
	--warn-all --warn-error \
	--library=libregress.la \
	--libtool="$(top_builddir)/libtool" \
	--output $@ \
	$(libregress_la_SOURCES)
Regress-1.0.typelib: Regress-1.0.gir Makefile
	$(AM_V_GEN) g-ir-compiler $< -o $@

GIMarshallingTests-1.0.gir: libgimarshallingtests.la Makefile
	$(AM_V_GEN) g-ir-scanner --include=Gio-2.0 \
	--namespace=GIMarshallingTests --nsversion=1.0 \
	--symbol-prefix=gi_marshalling_tests \
	--warn-all --warn-error \
	--library=libgimarshallingtests.la \
	--libtool="$(top_builddir)/libtool" \
	--output $@ \
	$(libgimarshallingtests_la_SOURCES)
GIMarshallingTests-1.0.typelib: GIMarshallingTests-1.0.gir Makefile
	$(AM_V_GEN) g-ir-compiler $< -o $@

.la.so:
	test -L $@ || $(LN_S) .libs/$@ $@

all: $(testlib_LTLIBRARIES:.la=.so) RegressAnnotation-1.0.typelib Regress-1.0.typelib GIMarshallingTests-1.0.typelib
