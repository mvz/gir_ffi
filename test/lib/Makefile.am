ACLOCAL_AMFLAGS = -I m4
AUTOMAKE_OPTIONS = 1.7

# We need to build a shared library, which can be dlopened
# it does not work with noinst_LTLIBRARIES
testlib_LTLIBRARIES = libannotation.la libdrawable.la libeverything.la \
		      libgimarshallingtests.la libregress.la libutility.la

testlibdir = $(prefix)/unused
install-testlibLTLIBRARIES: # prevent it from being installed

libannotation_la_SOURCES = $(GI_DATADIR)/tests/annotation.c $(GI_DATADIR)/tests/annotation.h
libannotation_la_CFLAGS = $(GLIB_CFLAGS)
libannotation_la_LDFLAGS = -module -avoid-version

libdrawable_la_SOURCES = $(GI_DATADIR)/tests/drawable.c $(GI_DATADIR)/tests/drawable.h
libdrawable_la_CFLAGS = $(GLIB_CFLAGS)
libdrawable_la_LDFLAGS = -module -avoid-version

libeverything_la_SOURCES = $(GI_DATADIR)/tests/everything.c $(GI_DATADIR)/tests/everything.h
libeverything_la_CFLAGS = $(GLIB_CFLAGS)
libeverything_la_LDFLAGS = -module -avoid-version

libgimarshallingtests_la_SOURCES = $(GI_DATADIR)/tests/gimarshallingtests.c $(GI_DATADIR)/tests/gimarshallingtests.h
libgimarshallingtests_la_CFLAGS = $(GIO_CFLAGS)
libgimarshallingtests_la_LDFLAGS = -module -avoid-version

libregress_la_SOURCES = $(GI_DATADIR)/tests/regress.c $(GI_DATADIR)/tests/regress.h
libregress_la_CFLAGS = $(GIO_CFLAGS) $(CAIRO_CFLAGS)
libregress_la_LDFLAGS = -module -avoid-version $(GIO_LIBS) $(CAIRO_LIBS)

libutility_la_SOURCES = $(GI_DATADIR)/tests/utility.c $(GI_DATADIR)/tests/utility.h \
			$(GI_DATADIR)/tests/gitestmacros.h
libutility_la_CFLAGS = $(GLIB_CFLAGS)
libutility_la_LDFLAGS = -module -avoid-version

# g-i doesn't ship these as shared libraries anymore; we build them here
Annotation-1.0.gir: libannotation.la
	$(AM_V_GEN) g-ir-scanner --include=cairo-1.0 --include=Gio-2.0 \
	--namespace=Annotation --nsversion=1.0 \
	--identifier-prefix=RegressAnnotation \
	--symbol-prefix=regress_annotation \
	--warn-all --warn-error \
	--library=libannotation.la \
	--libtool="$(top_builddir)/libtool" \
	--output $@ \
	$(libannotation_la_SOURCES)
Annotation-1.0.typelib: Annotation-1.0.gir
	$(AM_V_GEN) g-ir-compiler $< -o $@

Drawable-1.0.gir: libdrawable.la
	$(AM_V_GEN) g-ir-scanner --include=GLib-2.0 \
	--namespace=Drawable --nsversion=1.0 \
	--identifier-prefix=RegressTestInherit \
	--symbol-prefix=regress_test_inherit \
	--warn-all --warn-error \
	--library=libdrawable.la \
	--libtool="$(top_builddir)/libtool" \
	--output $@ \
	$(libdrawable_la_SOURCES)
Drawable-1.0.typelib: Drawable-1.0.gir
	$(AM_V_GEN) g-ir-compiler $< -o $@

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

Regress-1.0.gir: libregress.la
	$(AM_V_GEN) g-ir-scanner --include=cairo-1.0 --include=Gio-2.0 \
	--namespace=Regress --nsversion=1.0 --pkg=cairo-gobject \
	--warn-all --warn-error \
	--library=libregress.la \
	--libtool="$(top_builddir)/libtool" \
	--output $@ \
	$(libregress_la_SOURCES)
Regress-1.0.typelib: Regress-1.0.gir
	$(AM_V_GEN) g-ir-compiler $< -o $@

Utility-1.0.gir: libutility.la
	$(AM_V_GEN) g-ir-scanner --include=GLib-2.0 \
	  --namespace=$(@:-1.0.gir=) --nsversion=1.0 \
	  --warn-all --warn-error \
	  --library=$< --libtool="$(top_builddir)/libtool" \
	  --output $@ $(libutility_la_SOURCES)
Utility-1.0.typelib: Utility-1.0.gir
	$(AM_V_GEN) g-ir-compiler $< -o $@

.la.so:
	test -L $@ || $(LN_S) .libs/$@ $@

all: $(testlib_LTLIBRARIES:.la=.so) \
  Annotation-1.0.typelib \
  Drawable-1.0.typelib \
  Everything-1.0.typelib \
  GIMarshallingTests-1.0.typelib \
  Regress-1.0.typelib \
  Utility-1.0.typelib
