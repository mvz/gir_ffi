# Subclassing

Creating a Ruby subclass of one of the GObject classes requires following some rules.

First of all, if you override the initializer, you **must** call `super`
otherwise, the underlying GObject pointer will not be created and stored.

Second, GObject objects often have several constructors. GirFFI creates a
separate initializer for each constructor. This allows customization of the
call to super for each initializer. This means you will have to override each
initializer separately, as needed.

As an example, here is a subclass of `Regress::TestSubObj`, a class from
GObjectIntrospection's test suite, adding an extra argument to some of its
constructors.

```
class MyObj < Regress::TestSubObj
  attr_reader :animal

  def initialize animal
    super()
    @animal = animal
  end

  def initialize_from_file animal, file
    super(file)
    @animal = animal
  end
end

o1 = MyObj.new 'dog'
o1.foo                                          # => 'dog'
o2 = MyObj.constructor
o2.foo                                          # => nil
o3 = MyObj.new_from_file 'cat', 'my_file.txt'
o3.foo                                          # => 'cat'
```
