# Changelog

## 0.16.1 / 2023-10-07

* Support Ruby 3.2 ([#331] by [mvz])
* Require at least ffi 1.16.3 to avoid 'Can't modify frozen Hash' error ([#350]
  by [mvz])

[mvz]: https://github.com/mvz

[#331]: https://github.com/mvz/gir_ffi/pull/331
[#350]: https://github.com/mvz/gir_ffi/pull/350

## 0.16.0 / 2022-05-21

* Support Ruby 3.1
* Rename `#object_class` to `#class_struct`
* Remove `GObject.object_class_from_instance`
* Limit public interface of `BaseMethodBuilder`
* Remove deprecated methods from `GObject::Object`
* Stop accepting blocks when defining a type
* Check parameter direction in signal argument conversion
* Drop support for JRuby
* Drop support for Ruby 2.6

## 0.15.9 / 2021-12-05

* Skip setting destroy notifier state if types don't make sense
* Handle functions with multiple user-supplied callback arguments

## 0.15.8 / 2021-11-20

* Drop support for Ruby 2.5
* Bump minimum supported version of gobject-introspection to 1.56.0
* Bump minimum supported version of glib to 2.56.0
* Handle functions that have swapped closure annotation
* Handle GPtrArray arguments in signal handlers

## 0.15.7 / 2021-01-15

* Handle sized arrays with interface element types

## 0.15.6 / 2021-01-10

* Officially support Ruby 3.0
* Rely on `GObject.boxed_free` to free GValue objects
* Require 'set' in `callback_base.rb`, which needs it (thanks, Jordan Webb!)
* Make SizedArray handle `:filename` elements

## 0.15.5 / 2020-11-13

* Make building and finding metaclasses via `Builder.build_class` work again

## 0.15.4 / 2020-11-01

* Support disguised object class structs
* Handle the case where vfunc object arguments are null
* Bail out earlier when trying to register non-GObject class
* Small improvements
* Use `Module#prepend` for overrides
* Clean up initialization of structs, unions, and boxed types
* Make `GObject::Object#store_pointer` private like in the superclass
* Handle creating SizedArray of uint8 from a string
* Improve derived class setup
* Improve List and SList methods
* Make `ByteArray#append` return self
* Improve packaging infrastructure (thanks, utkarsh2102!)

## 0.15.3 / 2020-06-14

* Officially support Ruby 2.7
* Officially drop support for Ruby 2.4
* Store classes representing inline callback types in the class that defines
  them instead of in the main namespace, thus avoiding some potential name
  clashes
* Update development dependencies
* Various code quality improvements
* Record approved licenses for dependencies

## 0.15.2 / 2019-11-29

* Load girepository-1.0 library in a way that does not require installing a
  development package.

## 0.15.1 / 2019-10-20

* Allow access to properties for unintrospectable classes.

## 0.15.0 / 2019-10-19

* Drop support for gobject-introspection below 1.46, the version available in
  Ubuntu Xenial.
* Merge extended property getter and setter into regular ones. This means you
  can always just use `#get_property` and `#set_property`. The methods
  `#get_property_extended` and `#set_property_extended` are deprecated and will
  be removed in GirFFI version 0.16 or later.
* Support setting ByteArray properties directly with string values.
* Target Ruby 2.4+
* Implement getting and setting of flag properties and GValues.
* Add support for basic hashtable values larger than pointer.
* Support unintrospectable classes not derived from GObject but from some other
  fundamental object type.
* Make GPtrArray work with boxed types.
* Do not try to ref method reciever for struct instance methods marking the
  instance receiver as transfer `:everything`.
* Support signals with GError arguments.
* Cache various methods on IBaseInfo and its subclasses.
* Generate aliases for accessor methods instead of relying on `method_missing`.

## 0.14.1 / 2018-09-27

* Add enum values as constants in the generated module.

## 0.14.0 / 2018-09-25

* Do not generate field accessors for Object types. Object data should normally
  not be accessed directly.

## 0.13.1 / 2018-09-24

* Silence some warnings.
* Allow overrides to be applied using `Module#prepend`, as an alternative to
  alias chaining.
* Make `ZeroTerminated` array work with enum elements.
* Various refactorings.
* Improve consistency of conversion between symbols and integers for enum
  types.

## 0.13.0 / 2018-09-08

* Drop support for Ruby 2.1
* Support GLib 2.58
* Add `setup_method!` and `setup_instance_method!`, that raise an error when
  the given method is not found.

## 0.12.1 / 2018-05-20

* Restore support for Ruby 2.1 and 2.2

## 0.12.0 / 2018-03-24

* Drop support for GLib::IConv, which is no longer introspectable in glib 2.56.
* Drop support for Ruby 2.1 and 2.2
* Add support for Ruby 2.5

## 0.11.4 / 2017-09-19

* Support glib 2.54 and gobject-introspection 1.54

## 0.11.3 / 2017-05-05

* Allow conversion to native Boolean from any Ruby value

## 0.11.2 / 2017-04-20

* Allow vfunc implementation using a regular method

## 0.11.1 / 2017-01-07

* Fix build on JRuby
* Allow clearing properties that take a GObject value
* Handle GLists requiring an Interface type

## 0.11.0 / 2016-10-16

* Internal test and code improvements. Some internal APIs have been removed or
  changed.
* Make `Strv#each` thread-safe.
* Drop support for CRuby 2.0.
* Move `::type_init` and base `Strv` implementation into `GObjectIntrospection`,
  making it stand-alone.
* Move `GLib::Boolean` to `GirFFI::Boolean`.
* Guard against instantiating abstract classes using the default constructor.
* Handle user-defined properties containing dashes
* Handle user-defined properties of a large number of types

## 0.10.2 / 2016-04-29

* Update `ffi-bit_masks` dependency and remove monkey-patch
* Support gobject-introspection version 1.48

## 0.10.1 / 2016-03-28

* Restore JRuby compatibility.
  - Introduce #owned to flag unions and structs for release at garbage collection time.
    In JRuby's implementation, FFI::Pointer does not implement #autorelease=
    and #autorelease?, so this different technique is used to free pointers
    allocated by GLib. It is in fact doubtful that setting autorelease had any
    actual effect even on CRuby.
  - Immediately free string pointers whose ownership is transfered. Again, the
    #autorelease technique doesn't work on JRuby.
  - Fix handling of callee-allocated out parameters in vfuncs. The `put_pointer`
    method was wrongly called, and JRuby is more picky about what types that
    method expects, exposing the bug.

## 0.10.0 / 2016-03-23

* Ensure ownership of created RubyClosure objects

## 0.10.0.pre1 / 2016-03-22

* Rework generated method code to use less indirection.
* Remove unused classes and methods
* Clearly distinguish boxed types from other structs
* Take ownership transfer into account in generated methods
* Properly free unions, structs and boxed types owned by GirFFI
* Block access to fields that have disguised types

## 0.9.5 / 2016-03-05

* Abort if modules were defined earlier, e.g., through the gems from the
  ruby-gnome family.
* Extend integration testing with GObjectIntrospection's test libraries.
* Find signals on user-defined types.
* Allow getting and setting of properties with a callback value.
* Handle pointer-like signal arguments such as GList.
* Handle static methods on interface modules.
* Free most self-allocated boxed types using `GObject.boxed_free`.
* Correctly assign length arguments for zero-terminated arguments

## 0.9.4 / 2016-02-22

* Pass nil user data as null pointer, and store a missing callback as nil. This
  avoids passing a null callback and a non-null user data value, which causes
  problems with `vte_terminal_spawn_sync()` and perhaps other functions.

## 0.9.3 / 2016-02-20

* Make allow-none arguments optional in Ruby
* Add Clutter example
* Clean up mainloop example
* Use bit masks for relevant functions in GObjectIntrospection

## 0.9.2 / 2016-02-05

* Do not create a property accessor when a corresponding getter method exists

## 0.9.1 / 2016-02-04

* Add field accessors for Object types for fields that don't have corresponding
  properties or getter methods
* Improve error handling for signals and properties that are not found
* Handle signals without GIR data
* Add interrupt handler to break out of main loops

## 0.9.0 / 2016-01-21

* Propagate exceptions from callbacks during event loops
* Make default object constructor take a hash of properties
* Fix implementation of `ObjectBase.object_class`
* Make object class struct types inherit from their parent structs. This makes
  parent methods and fields available.
* Use `ObjectBase.object_class` instead of old `Object#type_class` to find
  properties
* Remove `Object#type_class`
* Automatically unpack GValue return values
* Use a BitMask to handle flag values
* Handle callback arguments as Ruby block arguments
* Use user data and destroy notify arguments to automate callback cleanup. This
  means you can no longer supply your own user data and notifiers.
* Support CRuby 2.3 and Rubinius 3.x
* Drop support for JRuby 1.7 and Rubinius 2.x.

## 0.8.6 / 2015-12-09

* Change handling of initializers in subclasses
  * Subclasses with their own GType revert to the default GObject constructor
  * Subclasses cannot use their parent classes' non-default contructors
* Find signals in ancestor classes of unintrospectable types

## 0.8.5 / 2015-12-04

* Improve GObject::Value
  * Make `#wrap_ruby_value` work for object classes
  * Use non-deprecated methods for getting and setting char values
  * Make `set_value` and `get_value` work for interface types

## 0.8.4 / 2015-12-03

* Handle classes with lower-case names
* Make `ObjectBase` a `DataConverter` so FFI handles it natively
* Use more of gobject-introspection's test libraries for testing
* Simplify constructor overrides: Custom initializers will no longer be
  overwritten when setting up the corresponding constructor.
* Override `GObject::Object.new` to not require a GType argument

## 0.8.3 / 2015-11-13

* Fix handling of signal handler return values
* Do not create setters for properties that cannot be set

## 0.8.2 / 2015-10-10

* Use inherited constructor for boxed types
* Make `InOutPointer` work correctly for boxed types
  * Make `.for` work with boxed types
  * Make `#set_value` work with boxed types
* Make GObject::Value support nil type:
  * Make `.wrap_ruby_value(nil)` work
  * Make `#set_value` and `#get_value` work when the type is `TYPE_INVALID`
  * Make `.for_gtype` work with `TYPE_INVALID` and `TYPE_NONE`
  * Make `.from(nil)` return a `GObject::Value` instead of nil
  * Make `#set_ruby_value` private
* Make `GObject::Object.signal_emit` work with gobject-introspection 1.46
* Replace or remove all custom `.new` methods
* Make `setup_method` and `setup_instance_method` handle symbol arguments

## 0.8.1 / 2015-10-04

* Handle struct array fields with related length fields
* Update test library build process

## 0.8.0 / 2015-09-18

* Drop official support for CRuby 1.9.3
* Officially support JRuby 9.0.0.0
* Change handling of initializers in custom subclasses

## 0.7.10 / 2015-09-16

* Allow `ffi-gobject` and `ffi-glib` to be required directly
* Improve documentation
* Remove arbitrary refcount check from finalizer (by John Cupitt)

## 0.7.9 / 2015-05-05

* Unset GValues in finalizer
* Dereference GObjects in finalizer
* Increase refcount for ingoing :object arguments of functions with full
  ownership transfer
* Increase refcount for receiver arguments with full ownership transfer
* Increase refcount for ingoing :object arguments of vfuncs with no ownership
  transfer
* Increase refcount for :object return values of vfuncs with full transfer
* Increase refcount for outgoing :object arguments of vfuncs with full ownership
  transfer
* Support Ruby 2.2
* Rename several methods. The old names are deprecated and will be removed in 0.8.0.

## 0.7.8 / 2014-12-09

* Support constants with a falsy value
* Support type aliases that resolve to a type that is not introspectable
* Support callback arguments with direction :inout
* Provide `GObject.signal_connect_after` and `GObject::Object.signal_connect_after`
* Handle setting GValues (and hence, properties) that have enum values
* Various refactorings & coding style cleanups

## 0.7.7 / 2014-10-21

* Handle introspecting boolean constants
* Provide `config.h` for versions of the test libs that need it
* Include gemspec in the gem
* Avoid needless casting from string to symbol by making `#setup_and_call` take a
  string
* Avoid argument list unpacking by making `#setup_and_call` take an array of
  arguments rather than a variable number of arguments
* Remove old example files
* Let rubygems know about required Ruby version
* Various clean-ups

## 0.7.6 / 2014-08-22

* Work around `respond_to?` behavior in JRuby 1.6.13
* Deprecate `setup_class` in favor of `load_class`
* Support GValue containing GArray
* Provide constant `TYPE_BYTE_ARRAY`
* Don't recurse looking for signals and properties
* Clean up generated code:
  * Avoid use of an ignored dummy argument
  * Clean up trailing whitespace
* Drop support for Ruby 1.9.2
* Allow data argument for `GObject::Object#signal_connect`
* Let Ruby threads run during GLib's main loop
* Make all dependencies versioned
* Various refactoring & code cleanup

## 0.7.5 / 2014-06-22

* Use closures as signal handlers, rather than callbacks
* Obtain reference to GVariant on creation
* Make struct arguments work in JRuby
* Various refactoring & code cleanup

## 0.7.4 / 2014-05-03

* Correctly handle closure data arguments originating from C
* Handle callee-allocated simple types for callbacks and functions
* Handle callback out parameters that are zero-terminated arrays
* Handle virtual functions with GError arguments
* Support the GBytes type
* Handle virtual functions returning GObjects
* Avoid overwriting methods with getters for properties with dashes in the name

## 0.7.3 / 2014-03-23

* Restore proper handling of enums in callback arguments
* Simplify Rake configuration
* Various small fixes
* Remove remaining Ruby 1.8 version checks

## 0.7.2 / 2014-01-18

* Officially drop Ruby 1.8 compatibility.
* Store GType of generated types in a constant, removing the need to generate a
  separate `get_gtype` method for each type.

## 0.7.1 / 2014-01-17

* Handle method setup for methods with unsafe names (i.e., `g_iconv()`)
* Add override for GLib::IConv.open

## 0.7.0 / 2014-01-11

* Type handling:
  * Handle c arrays with separate length argument for signals
  * Handle GHashTable values of type `:gint8` and `:guint32`
  * Handle signals with int64, Strv, uint64 arguments
  * Handle arrays of integers cast as pointers
  * Handle fields of callback type
  * Handle nested GHashTable
* Argument handling:
  * Refactor argument builder system
  * Improve handling of user data arguments
  * Handle signal and callback arguments with direction :out
  * Handle aliases of container types by making the element type optional
  * Handle signal and callback return values that need conversion
* User defined types:
  * Pass explicit receiver to initialization block for UserDefinedTypeInfo
  * Allow user defined types that are anonymous Ruby classes
  * Register defined properties in a subclass
  * Support setting virtual function implementations in a subclass
  * Support adding an interface to a subclass
  * Support implementing an interface's virtual functions in a subclass
* Use FFI's DataConvertor system to handle enums and callbacks
* Stop using deprecated GValueArray to construct argument array for `signal_emit`
* Make `ITypeInfo#g_type` return correct value for c arrays
* Make `get_property` and `set_property` less smart, moving conversion into the
  property accessor definitions
* Make `GObject::Value#get_value` handle enums and flags
* Clean up deprecated methods

## 0.6.7 / 2013-09-28

* Uniform handling of callback, signal and method arguments
* Automatically convert array elements to GValue
* Support inline array fields
* Support struct fields
* Improved field setters and getters
* Support many more types of properties
* Support skipped arguments and return values
* Fix refcount for the result of IBaseInfo#container
* Check bounds in GLib::PtrArray#index and GLib::Array#index
* Deprecate several methods
* Lots of refactoring

## 0.6.6 / 2013-08-05

* Handle GArrays of booleans and structs
* Improve handling of gbooleans

## 0.6.5 / 2013-08-03

* Handle inline arrays of structs
* Implement equality operator for container types
* Fix element size calculation for GArray

## 0.6.4 / 2013-06-30

* Represent enum types by modules wrapping `FFI::Enum`
* Support functions on enums
* Handle zero-terminated arrays of types other than int32
* Add override for `GLib::Variant#get_string`
* Handle non-throwing arguments and return values of type GError
* Handle arguments and return values of type GPtrArray
* Handle caller-allocated arguments of type GArray
* Deprecate `GObject::Value#ruby_value`, replacing it with `#get_value`

## 0.6.3 / 2013-06-15

* Make use of enums as element type for GHashTable and other containers
  work

## 0.6.2 / 2013-06-14

* Handle introspectable types with introspectable parent types

## 0.6.1 / 2013-06-09

* Handle SizedArray containing enums

## 0.6.0 / 2013-06-07

* Support Rubinius
* Lots of refactoring

## 0.5.2 / 2013-04-23

* Handle signal details in `GObject.signal_connect` and `.signal_emit`
* Make `GValue#set_value` check object GType compatibility
* Eliminate GObject::Helper module
* Handle more argument types
* Support Ruby 2.0.0

## 0.5.1 / 2013-02-01

* Properly handle zero-terminated arrays of `:filename`
* Loosen dependencies on ffi and minitest

## 0.5.0 / 2013-01-19

* Update ffi dependency
* Add finalizer to release memory for IBaseInfo and descendents
* Remove deprecated methods
* Remove pretty-printing functionality
* Refactor argument handling

## 0.4.3 / 2012-11-02

* Remove gobject-introspection version check
* Make tests pass with gobject-introspection 1.34
* Ongoing refactoring

## 0.4.2 / 2012-09-22

* Make objects and interfaces wrap poiners in the class that matches
  their GType.

## 0.4.1 / 2012-09-18

* Remove workarounds for older versions of gobject-introspection
* Mark certain methods as deprecated. These will be removed in 0.5.0
* Handle :filename type arguments in InPointer
* Refactoring

## 0.4.0 / 2012-08-24

* Move Gtk+ bindings to their own gem (`gir_ffi-gtk`).

## 0.3.2 / 2012-08-24

* Correctly set FFI return type when callbacks that return GObjects have
  incomplete type specification.

## 0.3.1 / 2012-05-13

* Correctly map Interface types in callbacks.

## 0.3.0 / 2012-04-09

* Improve process of defining initializers in derived classes.
* Make interfaces know their GType.
* Make classes created by the Unintrospectable builder know their GType.
* Create property accessors instead of field accessors for GObjects.
* Add Ruby-style getter and setter methods (by Antonio Terceiro).
* Add `#signal_connect` instance method (by Antonio Terceiro).
* Make GirFFI's tests pass with gobject-introspection 0.10.
* Improve unintrospectable type handling.
* Bug fixes and refactorings.
* Start implementing `#define_type`, for creating descendent types that
  the GObject system knows about.

## 0.2.3 / 2011-12-31

* Fix issue #7: methods that take GValues will autoconvert other values.
* Fix method lookup when include'ing a module that is an Interface.
* Various refactorings.

## 0.2.2 / 2011-12-07

* Fix issue #19: Check if a GLib::PtrArray.add method was generated before
  attempting to remove it.
* Fix two issues with pretty printing that made output for GLib have syntax
  errors.

## 0.2.1 / 2011-11-20

* Fix handling of output parameters that are arrays of pointers to structures
  (i.e., of type `Foo***`).

## 0.2.0 / 2011-11-19

* Add support for properties, with `#get_property` and `#set_property`.
* Add support for fields.
  - Create field accessor methods.
  - Get rid of `#[]` and `#[]=`.
* Explicitely load `libgirepository` with ABI version 1.
* Improve implementation of GLib container classes (GList etc.):
  - Real constructors.
  - `#append` and friends are instance methods now.
  - Conversion methods to cast Ruby containers to GLib containers.
* Start implementing pretty printing.
* Various refactorings.

## 0.1.0 / 2011-10-28

* Put bindings for GObjectIntrospection in their own namespace.
* `GirFFI.setup` no longer loads overrides.
* Add `ffi-gtk2` and `ffi-gtk3` files for loading Gtk+ overrides.

## 0.0.14 / 2011-10-28

* Support GObject Introspection version 1.30:
  - Add support for layouts with fixed-length arrays.
  - Handle type names starting with underscores.
  - Call `g_signal_emitv` directly to avoid conflict in introspection info
    with earlier versions of GObject Introspection.

## 0.0.13 / 2011-09-09

* Remove IErrorDomain related code. This functinality was removed from
  GObject Introspection in version 1.29.17

## 0.0.12 / 2011-09-04

* No longer use `_id2ref` to locate objects past as user data pointers.
* Fix failing tests on JRuby.

## 0.0.11 / 2011-08-22

* Change interface to the underlying builder in generated modules and
  classes.
* Handle string, enum, union, flags signal arguments.
* Handle string arguments in `GObject.signal_emit`.
* Handle enum signal arguments.
* Fix finding signals in non-introspectable types.
* Fix method setup in non-introspectable types.
* Refactoring.

## 0.0.10 / 2011-05-18

* Handle GObject interfaces properly.
* Create types only defined by the GType system.
* Support GType array return values.

## 0.0.9 / 2011-05-02

* More complete support for the basic types.
* Improved support for GList, GSList, GStrv, and GValue.
* Add support for GHashTable, GVariant, GByteArray, and GArray.
* Generate constants.
* When setting up a module, set up its dependencies as well.
* Test against the GIMarshallingTests test namespace.
* Use minitest/spec for testing.
* Various bug fixes and internal improvements.

## 0.0.8 / 2011-04-08

* Generate modules with names starting with a lowercase letter (like
  `cairo`).
* Allow specifying the typelib version on setup.
* Rename methods `#methods` and `#type` of the introspection classes to avoid
  clashing with standard Ruby methods.
* Refactoring.

## 0.0.7 / 2011-04-01

* Support gobject-introspection 0.10, drop support for earlier versions.
  - Use Regress, not Everything, for testing.
  - Deal with functions that are no longer introspectable.
* Correctly handle constructors that declare their return type different
  from their class.
* Implement `RubyClosure`, a `GObject::Closure` for handling ruby callbacks.
* Handle GLib's singly and doubly linked lists.
* Handle callback types defined in-place (like `Closure`'s `marshal`).
* Refactoring.

## 0.0.6 / 2011-03-01

* Cast returned GObjects to their actual type.
* Properly cast callback arguments.
* Handle the case where functions formally return interfaces.
* Make sure Gtk::Window has the correct number of references after creation.
* Refactoring and some small fixes.

## 0.0.5 / 2010-12-30

* Don't create instance methods out of functions and vice versa.
* Find signals on interfaces, too.
* Implement tests for most of Everything.
* Correctly handle array + size arguments.
* Handle most other argument types.
* Various internal changes and other fixes.

## 0.0.4 / 2010-12-14

* Lots of changes to the internals.
* Handle out-only arguments.
* Make use of callbacks from other namespaces work.
* Handle virtual methods where the invoker method has a different name.
* Implement usable `signal_connect` and `signal_emit`.
* Sink floating references when creating a GObject.
* Implement Union type.
* Many small bug fixes.

## 0.0.3 / 2010-11-19

* Update to restore Ruby 1.9 support.
* Handle functions with the 'throws' property set.
* Handle classes without specified fields.

## 0.0.2 / 2010-11-14

* Several fixes to method creation.

## 0.0.1 / 2010-10-25

* Initial release.
