#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.59)
AC_INIT(dummy_test_lib, 0.0.1)
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([1.7 foreign])
AM_MAINTAINER_MODE
AM_CONFIG_HEADER([config.h])

m4_ifdef([AM_SILENT_RULES],[AM_SILENT_RULES([yes])],)

# Checks for programs.
AC_PROG_CC
AM_PROG_CC_C_O
AC_PROG_LIBTOOL
PKG_PROG_PKG_CONFIG

if test "$GCC" = "yes"; then
  JH_ADD_CFLAG([-Wall])
  JH_ADD_CFLAG([-fno-strict-aliasing])
fi

PKG_CHECK_MODULES(GIO, [gio-2.0])
PKG_CHECK_MODULES(CAIRO, [cairo])

GI_DATADIR=$($PKG_CONFIG --variable=gidatadir gobject-introspection-1.0)
AC_SUBST(GI_DATADIR)

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
