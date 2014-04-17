# TODO

## Memory managment

GirFFI does not attempt to free any memory at the moment, or lower the
reference count of any objects it gets from GObject. This task therefore involves two parts:

- Free non-GObject pointers as needed (at garbage-collection time)
- Lower reference count of GObjects (at garbage-collection time)

## Refactorings

These in the order they occured to me, and may therefore be fixed in any order.

- Create Type objects for all FFI types, including the ones currently
  represented by a single symbol, so we can always do stuff like

  > `GirFFI::Types::UInt8.get_value_from_pointer(ptr)`

  rather than having awkward dynamic method dispatch inside GirFFI::InOutPointer.

- Move to a single Pointer class, rather than InPointer, InOutPointer and
  Pointer monkeypatching.

- Move special types like SizedArray to sane namespaces. Types (like
  GLib::List) that have actual GLib implementations go to the GLib namespace.
  Other types go to the GirFFI namespace.

## Derived types

Derived classes can now be registered with GObject, but the way to do this is
not very nice:

    class Derived < Base
    end

    GirFFI.define_type Derived do |info|
      info.install_property GObject.param_spec_int("foo", "foo bar",
                                                   "The Foo Bar Property",
                                                   10, 20, 15, 3)
      # assume Base defines a virtual function called 'some_vfunc'
      info.install_vfunc_implementation :some_vfunc, proc {|obj|
        #implementation goes here
      }
    end

It would be good to replace this with something that's easier to use:
* Perhaps auto-register types, like Gtk# does
* Perhaps automagically find vfunc implementations, like PyGObject and
  Ruby-GNOME do
* What about properties?

## Persistent Ruby GObject identity

GirFFI should make sure that if it gets a pointer to a GObject for which a Ruby
object already exists, the existing object is returned. This involves the use
of WeakRef, no doubt.

## Handle fundamental objects that are not GObject.

This is a big one. See commit 1e9822c7817062a9b853269b9418fd78782090b5 in
gobject-introspection, and TestFundamentalObject in Regress.

The tests for TestFundamentalObject accidentally pass, but there may be
hidden issues.

## Check binding of GObject:

    (11:37:03 PM) walters: the basic story is that GObject should be manually bound
    (11:47:02 PM) ebassi: the really necessary bits are: GObject/GInitiallyUnowned memory management; properties accessors; GSignal connection API
    (11:47:15 PM) ebassi: the rest is "nice to have"
    (11:47:37 PM) ebassi: oh, and probably GBinding - but that's just because I wrote it ;-)

## Use FFI::DataConverter to automatically convert GObject types

GirFFI now generates loads of Something.wrap(ptr) calls; Perhaps these can be
replace by implementing to_native and from_native in ClassBase and including
FFI::DataConverter.

## Handle Variants more nicely

Currently, GirFFI requires the user to create GVariant objects by hand, and
retrieve values from them by hand as well. Ideally, we would have `.from_ruby` and
`#to_ruby` methods or somesuch that do this for us. Some classes, like GAction,
require a specifice VariantType to be used consistently. Special logic will have
to be put in place for that.

## Handle ownership-transfer correctly

For how to handle objects, see https://bugzilla.gnome.org/show_bug.cgi?id=657202#c1

## See Also

  dnote
