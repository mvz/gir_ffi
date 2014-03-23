# Design of Gir-FFI

## Basic Idea

Gir-FFI uses FFI to read information from the GObject Introspection
Repository. Based on that it creates bindings for the information read.

## Class and method creation

GirFFI::Builder creates classes and modules at runtime and adds appropriate
method_missing methods to them to generate methods and perhaps other
classes when required.

The following options were discarded, at least for now.

* Create classes and all of their methods at runtime. This would be very
  similar to the method chosen, but would concentrate all the overhead at
  start-up, some of which would be used for creating methods that will
  never get called.

* Allow offline creation of ruby source generated from the GIR. This is
  still in interesting idea, but off-line source code generation is not
  really the Ruby way.

## Method Naming

Probably, get_x/set_x pairs should become x and x= to be more Ruby-like.
This should be done either by defining them as such directly, or by
aliasing. Blindly going by the name leads to weird results thoough, like
having x, x= and x_full= as a set. Also, some get_ or set_ methods take
extra arguments. These probably shouldn't become accessors either.

Boolean-valued methods could get a ? at the end.

This requires a lot more thought. For now, the full method names as
defined in the GIR are used.

## Ruby-GNOME Compatibility

Full Ruby-GNOME compatibility cannot be achieved automatically, since its
object hierarchy differs from that of standard GObject: It puts Object in
the GLib namespace, and defines signal_connect and friends as methods of
GLib::Instantiable; In standard GObject they are functions.

Possibly, compatibility enhancing code can be added for these specific
exceptions.

## Reference Counting

Because we can always make sure GObjects are unref'd when the Ruby object
is GC'd, the mechanism of floating references actually gets in the way a
bit. Therefore, when floating GObjects are constructed, GirFFI will sink
them. All GObjects can then safely be unref'd using a Ruby finalizer.
GObjects obtained through other mechanisms than with a constructor will be
ref'd once when wrapping them in a ruby object.

## Bootstrapping Class Design

The interface to the GObject Introspection Repository itself is also
introspectable. The interface is specified in terms of structs and
functions rather than objects and methods. For now, the hard-coded Ruby
bindings for this don't follow the introspected specification: Gir-FFI
cannot bootstrap itself.

## Object initialization

An attempt at making Thing.new less hacky.

Goals:

* No aliasing of Ruby's new. Overriding is possible with super being called.
* #initialize should behave as expected. We may enforce use of super in Ruby
  subclasses.

Schematic depiction of what happens (can happen):

```ruby
class GObject::Object
  def self.new *args
    # Stage A
    super(*other_args)
    # Stage C
  end

  def initialize *other_args
    # Stage B
  end
end
