# Clause 8: Classes

[All chapters](README.md). 162 tests. This page is written by `tools/suite_catalog.py` from the metadata of the tests; edit the tests, not this page.

| Test | What it checks | Clauses | Expected output recorded with | Notes |
| --- | --- | --- | --- | --- |
| [`test_class_array_property_nonzero_range`](../../tests/ch8/test_class_array_property_nonzero_range.sv) | A fixed-size array property of a class with a range that does not start at 0 keeps every element | 8.3 7.4.5 20.7 | Verilator 5.052 |  |
| [`test_class_basics`](../../tests/ch8/test_class_basics.sv) | Chapter 8: Classes | 8.3 8.4 8.12 | Icarus Verilog 13.0 |  |
| [`test_block_scoped_class_handles`](../../tests/ch8/test_block_scoped_class_handles.sv) | Class handles declared in begin-end blocks, one hiding a module-level handle | 8.4 23.9 9.3.1 | Icarus Verilog 13.0 |  |
| [`test_class_basic`](../../tests/ch8/test_class_basic.sv) | Test for class basics | 8.4 8.6 | Icarus Verilog 13.0 |  |
| [`test_class_basic_2`](../../tests/ch8/test_class_basic_2.sv) | Class constructor, properties and methods, and independent instances | 8.4 8.7 | Icarus Verilog 13.0 |  |
| [`test_class_basic_edge_cases`](../../tests/ch8/test_class_basic_edge_cases.sv) | Class basic edge cases | 8.4 8.6 8.7 | Icarus Verilog 13.0 |  |
| [`test_class_compare`](../../tests/ch8/test_class_compare.sv) | Test: Class comparison | 8.4 8.5 8.6 | Verilator 5.052 |  |
| [`test_class_component_tree`](../../tests/ch8/test_class_component_tree.sv) | A tree of class objects that build hierarchical names from their parents | 8.4 8.5 7.10 | Verilator 5.052 |  |
| [`test_class_edge`](../../tests/ch8/test_class_edge.sv) | Classes: construction, methods, local members, inheritance | 8.4 8.6 8.13 8.18 | Icarus Verilog 13.0 |  |
| [`test_class_enum_property_accessors`](../../tests/ch8/test_class_enum_property_accessors.sv) | Methods of an object read and write its properties of enumerated types, a 64-bit vector and fixed-size arrays of bytes, and an enumeration with explicit values in any order keeps their signs through a cast to int | 8.4 8.5 8.6 6.19 7.4 | Verilator 5.052 |  |
| [`test_class_handle_arrays_lookup`](../../tests/ch8/test_class_handle_arrays_lookup.sv) | Objects kept in fixed-size arrays of class handles by two containers are shared, not copied, can be found by comparing a string property, and a method of one container changes them for the other | 8.4 8.7 7.4 6.16 | Verilator 5.052 |  |
| [`test_class_null_comparison`](../../tests/ch8/test_class_null_comparison.sv) | Class handles: null by default, compared with null, copied by assignment | 8.4 8.12 | Icarus Verilog 13.0 |  |
| [`test_class_null_handle`](../../tests/ch8/test_class_null_handle.sv) | Test: Null handle detection (check if handle is null before use) | 8.4 | Verilator 5.052 |  |
| [`test_class_object`](../../tests/ch8/test_class_object.sv) | Test class objects | 8.4 8.7 | Icarus Verilog 13.0 |  |
| [`test_class_prop_assign`](../../tests/ch8/test_class_prop_assign.sv) | Test: Class property assignment | 8.4 8.5 8.9 | Verilator 5.052 |  |
| [`test_class_register_block`](../../tests/ch8/test_class_register_block.sv) | A class that models a block of registers, with reads, writes and reset | 8.4 8.5 12.5 | Verilator 5.052 |  |
| [`test_class_simple`](../../tests/ch8/test_class_simple.sv) | Class Simple Tests | 8.4 8.6 | Icarus Verilog 13.0 |  |
| [`test_edge_case_classes`](../../tests/ch8/test_edge_case_classes.sv) | Corner case tests for class operations | 8.4 8.9 8.16 8.20 | Verilator 5.052 |  |
| [`test_edge_class_null_handle`](../../tests/ch8/test_edge_class_null_handle.sv) | Class handles and null | 8.4 8.8 | Icarus Verilog 13.0 |  |
| [`test_member_access_chain`](../../tests/ch8/test_member_access_chain.sv) | Test chained member access | 8.4 7.2.1 | Verilator 5.052 |  |
| [`test_member_access_class`](../../tests/ch8/test_member_access_class.sv) | Test for class member access | 8.4 8.5 8.6 | Verilator 5.052 |  |
| [`test_nested_member_access_2`](../../tests/ch8/test_nested_member_access_2.sv) | Test for nested member access | 8.4 8.5 8.6 | Verilator 5.052 |  |
| [`test_null_check`](../../tests/ch8/test_null_check.sv) | Null Object Handling Tests | 8.4 | Verilator 5.052 |  |
| [`test_null_empty_corner`](../../tests/ch8/test_null_empty_corner.sv) | Tests null handles, empty arrays, and default values | 8.4 7.5 7.10 7.8 6.16 | Verilator 5.052 |  |
| [`test_null_expr`](../../tests/ch8/test_null_expr.sv) | Test null expression | 8.4 | Icarus Verilog 13.0 |  |
| [`test_null_handle`](../../tests/ch8/test_null_handle.sv) | Null class handle operations edge cases | 8.4 8.15 | Verilator 5.052 |  |
| [`test_class_member_access`](../../tests/ch8/test_class_member_access.sv) | Test for IEEE 1800-2023 §8: Class member access | 8.5 8.6 8.13 | Icarus Verilog 13.0 |  |
| [`test_class_prop`](../../tests/ch8/test_class_prop.sv) | Class Property Tests | 8.5 8.7 | Icarus Verilog 13.0 |  |
| [`test_class_property`](../../tests/ch8/test_class_property.sv) | Test class property | 8.5 8.18 | Icarus Verilog 13.0 |  |
| [`test_class_scope`](../../tests/ch8/test_class_scope.sv) | Test class method scope | 8.5 8.9 8.10 8.20 8.23 | Verilator 5.052 |  |
| [`test_nested_member_access`](../../tests/ch8/test_nested_member_access.sv) | Test case: Nested class member access | 8.5 8.4 | Verilator 5.052 |  |
| [`test_class_method`](../../tests/ch8/test_class_method.sv) | Class methods that read and change a property, with a default constructor argument | 8.6 8.7 | Icarus Verilog 13.0 |  |
| [`test_class_method_2`](../../tests/ch8/test_class_method_2.sv) | Class Method Tests | 8.6 | Icarus Verilog 13.0 |  |
| [`test_class_method_calls`](../../tests/ch8/test_class_method_calls.sv) | Class Method Tests | 8.6 | Icarus Verilog 13.0 |  |
| [`test_class_method_control_flow`](../../tests/ch8/test_class_method_control_flow.sv) | Class methods that return from loops, nested if-else and case statements | 8.6 13.4.1 12.8 | Icarus Verilog 13.0 |  |
| [`test_class_methods`](../../tests/ch8/test_class_methods.sv) | Class methods, constructor default arguments and inherited methods | 8.6 8.7 8.13 | Icarus Verilog 13.0 |  |
| [`test_class_methods_2`](../../tests/ch8/test_class_methods_2.sv) | Tests class instantiation, methods, constructors | 8.6 8.7 | Verilator 5.052 |  |
| [`test_method_class`](../../tests/ch8/test_method_class.sv) | Class methods test | 8.6 8.7 13.5.3 | Icarus Verilog 13.0 |  |
| [`test_class_construct`](../../tests/ch8/test_class_construct.sv) | Class Constructor Tests | 8.7 | Icarus Verilog 13.0 |  |
| [`test_class_new`](../../tests/ch8/test_class_new.sv) | Class Constructor Tests | 8.7 13.5.3 | Verilator 5.052 |  |
| [`test_class_new_args`](../../tests/ch8/test_class_new_args.sv) | Test: Class constructor with various argument types | 8.7 13.5.3 | Verilator 5.052 |  |
| [`test_property_initializer_after_super_new`](../../tests/ch8/test_property_initializer_after_super_new.sv) | The initializers of a derived class's properties run after the base class constructor and before the rest of the derived constructor | 8.7 8.17 | Icarus Verilog 13.0 |  |
| [`test_typed_constructor_into_base_handle`](../../tests/ch8/test_typed_constructor_into_base_handle.sv) | A typed constructor builds a derived object directly into a base handle | 8.8 | Verilator 5.052 |  |
| [`test_class_scope_access`](../../tests/ch8/test_class_scope_access.sv) | Static class properties test | 8.9 8.10 8.23 | Verilator 5.052 |  |
| [`test_class_singleton`](../../tests/ch8/test_class_singleton.sv) | Test: Singleton pattern | 8.9 8.10 8.7 | Verilator 5.052 |  |
| [`test_class_static`](../../tests/ch8/test_class_static.sv) | Static class property counting constructed objects, read through a static method | 8.9 8.10 | Verilator 5.052 |  |
| [`test_class_static_2`](../../tests/ch8/test_class_static_2.sv) | Test: static property, static method, shared state across instances | 8.9 8.10 | Verilator 5.052 |  |
| [`test_class_static_corner`](../../tests/ch8/test_class_static_corner.sv) | Tests static properties, methods, and class-level state | 8.9 8.10 8.23 | Verilator 5.052 |  |
| [`test_class_static_members`](../../tests/ch8/test_class_static_members.sv) | Static class properties test | 8.9 8.10 | Icarus Verilog 13.0 |  |
| [`test_foreach_static_members`](../../tests/ch8/test_foreach_static_members.sv) | Tests foreach iteration over static queue, dynamic array, and associative array members | 8.9 8.10 12.7.3 7.10 7.8 | Verilator 5.052 |  |
| [`test_class_factory`](../../tests/ch8/test_class_factory.sv) | Test: Factory pattern | 8.10 8.21 8.20 | Verilator 5.052 |  |
| [`test_class_static_method`](../../tests/ch8/test_class_static_method.sv) | Test: Static class methods | 8.10 8.9 | Verilator 5.052 |  |
| [`test_illegal_static_method_uses_property`](../../tests/ch8/test_illegal_static_method_uses_property.sv) | A static method cannot use a non-static property of its class | 8.10 | Verilator 5.052 | illegal design |
| [`test_method_static`](../../tests/ch8/test_method_static.sv) | Static methods test | 8.10 8.9 | Verilator 5.052 |  |
| [`test_static_method_through_null_handle`](../../tests/ch8/test_static_method_through_null_handle.sv) | A static method and a static property can be used through a class handle that is null | 8.10 8.9 8.4 | Verilator 5.052 |  |
| [`test_class_this`](../../tests/ch8/test_class_this.sv) | Test: this keyword usage | 8.11 8.4 | Verilator 5.052 |  |
| [`test_class_this_super`](../../tests/ch8/test_class_this_super.sv) | this and super keywords | 8.11 8.15 | Verilator 5.052 |  |
| [`test_illegal_type_this_outside_class`](../../tests/ch8/test_illegal_type_this_outside_class.sv) | type(this) cannot be used outside a class | 8.11 6.23 | Verilator 5.052 | illegal design |
| [`test_this_expr`](../../tests/ch8/test_this_expr.sv) | Test this expression | 8.11 | Icarus Verilog 13.0 |  |
| [`test_type_this`](../../tests/ch8/test_type_this.sv) | type(this) is the type of the enclosing class, also in a subclass, where it names the subclass | 8.11 6.23 | standard only |  |
| [`test_assign_class`](../../tests/ch8/test_assign_class.sv) | Test for class assignment | 8.12 8.4 | Icarus Verilog 13.0 |  |
| [`test_class_copy`](../../tests/ch8/test_class_copy.sv) | Class Copy (§8.13) | 8.12 | Verilator 5.052 |  |
| [`test_class_copy_2`](../../tests/ch8/test_class_copy_2.sv) | Test: Class copy method | 8.12 8.7 | Verilator 5.052 |  |
| [`test_class_copy_3`](../../tests/ch8/test_class_copy_3.sv) | A user-written copy method that copies a value and a fixed-size array member | 8.12 8.7 | Verilator 5.052 |  |
| [`test_class_copy_corner`](../../tests/ch8/test_class_copy_corner.sv) | Tests shallow copy, deep copy, and clone patterns | 8.12 8.21 | Verilator 5.052 |  |
| [`test_copy_obj`](../../tests/ch8/test_copy_obj.sv) | Test object copy | 8.12 | Icarus Verilog 13.0 |  |
| [`test_shallow_copy_array_properties`](../../tests/ch8/test_shallow_copy_array_properties.sv) | A shallow copy with new copies the elements of dynamic array, queue and fixed-size array properties | 8.12 7.5 7.10 | Verilator 5.052 |  |
| [`test_class_extends`](../../tests/ch8/test_class_extends.sv) | Test class extends | 8.13 8.20 8.22 | standard only |  |
| [`test_class_extends_2`](../../tests/ch8/test_class_extends_2.sv) | Test: Class inheritance extends | 8.13 8.14 8.20 8.22 | Verilator 5.052 |  |
| [`test_class_inherit`](../../tests/ch8/test_class_inherit.sv) | Test: extends, super.new, method override, parent reference | 8.13 8.15 8.20 | Verilator 5.052 |  |
| [`test_class_inherit_edge_cases`](../../tests/ch8/test_class_inherit_edge_cases.sv) | Test: Class inheritance edge cases | 8.13 8.15 6.8 | Icarus Verilog 13.0 |  |
| [`test_class_inheritance`](../../tests/ch8/test_class_inheritance.sv) | Test class inheritance | 8.13 8.20 8.22 | standard only |  |
| [`test_class_inheritance_2`](../../tests/ch8/test_class_inheritance_2.sv) | Virtual method override seen through a base-class handle | 8.13 8.20 | Verilator 5.052 |  |
| [`test_class_inheritance_3`](../../tests/ch8/test_class_inheritance_3.sv) | Test: Class extends, super calls, virtual methods | 8.13 8.15 8.20 | Verilator 5.052 |  |
| [`test_class_inheritance_corner`](../../tests/ch8/test_class_inheritance_corner.sv) | Tests single and multi-level inheritance, method override, super | 8.13 8.15 8.20 8.21 | Verilator 5.052 |  |
| [`test_class_inheritance_virtual_super`](../../tests/ch8/test_class_inheritance_virtual_super.sv) | Class inheritance, super, and virtual method overriding | 8.13 8.15 8.20 | standard only |  |
| [`test_class_multilevel_inheritance`](../../tests/ch8/test_class_multilevel_inheritance.sv) | Multilevel inheritance; constructors that do not call super.new() explicitly | 8.13 8.17 | Icarus Verilog 13.0 |  |
| [`test_final_class_and_method`](../../tests/ch8/test_final_class_and_method.sv) | A class declared :final can extend another class and be used, and a method declared :final is inherited and called as any other | 8.13 8.20 | Verilator 5.052 |  |
| [`test_illegal_final_class_extended`](../../tests/ch8/test_illegal_final_class_extended.sv) | A class declared :final cannot be extended | 8.13 | Verilator 5.052 | illegal design |
| [`test_lrm_class_inheritance_8`](../../tests/ch8/test_lrm_class_inheritance_8.sv) | Class inheritance and polymorphism edge cases | 8.13 8.15 8.20 8.21 | Verilator 5.052 |  |
| [`test_class_super`](../../tests/ch8/test_class_super.sv) | Test: super keyword usage | 8.15 8.20 8.13 | Icarus Verilog 13.0 |  |
| [`test_illegal_super_new_not_first`](../../tests/ch8/test_illegal_super_new_not_first.sv) | A call of super.new has to be the first statement of a constructor | 8.15 8.17 | Icarus Verilog 13.0 | illegal design |
| [`test_cast_class`](../../tests/ch8/test_cast_class.sv) | Test class casting | 8.16 6.24.2 | Verilator 5.052 |  |
| [`test_cast_complex_patterns`](../../tests/ch8/test_cast_complex_patterns.sv) | $cast with complex nested patterns | 8.16 6.24.2 7.5 | Verilator 5.052 |  |
| [`test_class_cast`](../../tests/ch8/test_class_cast.sv) | Test: Class casting $cast | 8.16 6.24.2 8.20 | Verilator 5.052 |  |
| [`test_class_cast_edge_cases`](../../tests/ch8/test_class_cast_edge_cases.sv) | Test: Class cast edge cases | 8.16 6.24.2 | Verilator 5.052 |  |
| [`test_dynamic_cast`](../../tests/ch8/test_dynamic_cast.sv) | Assignment and casting | 8.16 6.24.2 | Verilator 5.052 |  |
| [`test_system_cast`](../../tests/ch8/test_system_cast.sv) | Test $cast - dynamic type casting | 8.16 6.24.2 | Verilator 5.052 |  |
| [`test_type_check`](../../tests/ch8/test_type_check.sv) | Type Checking Tests | 8.16 6.24.2 | Verilator 5.052 |  |
| [`test_illegal_super_new_default_without_default`](../../tests/ch8/test_illegal_super_new_default_without_default.sv) | super.new(default) needs default in the argument list of the constructor | 8.17 | standard only | illegal design |
| [`test_super_new_default`](../../tests/ch8/test_super_new_default.sv) | default in the argument list of a constructor takes the arguments of the superclass constructor, super.new(default) passes them on, and extends with default gives an implicit constructor the same arguments | 8.17 8.15 | standard only |  |
| [`test_illegal_local_member_outside`](../../tests/ch8/test_illegal_local_member_outside.sv) | A local class property cannot be accessed from outside the class | 8.18 | Icarus Verilog 13.0 | illegal design |
| [`test_class_const_properties`](../../tests/ch8/test_class_const_properties.sv) | Global constant class properties take their value in the declaration, and instance constants are set once in the constructor | 8.19 8.9 | Verilator 5.052 |  |
| [`test_illegal_global_constant_assigned_in_constructor`](../../tests/ch8/test_illegal_global_constant_assigned_in_constructor.sv) | A class constant with an initial value cannot be assigned, not even in the constructor | 8.19 | Icarus Verilog 13.0 | illegal design |
| [`test_illegal_instance_constant_assigned_in_method`](../../tests/ch8/test_illegal_instance_constant_assigned_in_method.sv) | An instance constant of a class can be assigned only in its constructor | 8.19 | Icarus Verilog 13.0 | illegal design |
| [`test_illegal_static_instance_constant`](../../tests/ch8/test_illegal_static_instance_constant.sv) | An instance constant of a class cannot be declared static | 8.19 8.9 | standard only | illegal design |
| [`test_callback_basic`](../../tests/ch8/test_callback_basic.sv) | A user-written callback pattern built from classes and virtual methods | 8.20 8.10 7.10 | Verilator 5.052 |  |
| [`test_callback_chain`](../../tests/ch8/test_callback_chain.sv) | Several user-written callbacks called in order through base-class handles | 8.20 7.10 | Verilator 5.052 |  |
| [`test_callback_enable_disable`](../../tests/ch8/test_callback_enable_disable.sv) | Enabling and disabling a user-written callback object | 8.20 7.10 | Verilator 5.052 |  |
| [`test_class_polymorphic_access`](../../tests/ch8/test_class_polymorphic_access.sv) | Virtual methods called through base-class handles to derived objects | 8.20 8.22 | Verilator 5.052 |  |
| [`test_class_polymorphism`](../../tests/ch8/test_class_polymorphism.sv) | Class Polymorphism (§8.20) | 8.20 | Verilator 5.052 |  |
| [`test_class_polymorphism_2`](../../tests/ch8/test_class_polymorphism_2.sv) | Class Polymorphism Tests | 8.20 8.22 | Verilator 5.052 |  |
| [`test_class_virtual_edge_cases`](../../tests/ch8/test_class_virtual_edge_cases.sv) | Test: Class virtual method edge cases | 8.20 | Verilator 5.052 |  |
| [`test_class_virtual_param`](../../tests/ch8/test_class_virtual_param.sv) | Virtual method override and a parameterized class with a type parameter | 8.20 8.25 | Verilator 5.052 |  |
| [`test_illegal_final_method_overridden`](../../tests/ch8/test_illegal_final_method_overridden.sv) | A method declared :final cannot be overridden in a subclass | 8.20 | Verilator 5.052 | illegal design |
| [`test_illegal_final_pure_virtual`](../../tests/ch8/test_illegal_final_pure_virtual.sv) | A pure virtual method cannot be declared :final | 8.20 8.21 | standard only | illegal design |
| [`test_illegal_method_extends_without_base`](../../tests/ch8/test_illegal_method_extends_without_base.sv) | A method declared :extends has to override a virtual method of a base class | 8.20 | Verilator 5.052 | illegal design |
| [`test_illegal_method_initial_and_extends`](../../tests/ch8/test_illegal_method_initial_and_extends.sv) | A method cannot be declared both :initial and :extends | 8.20 | Verilator 5.052 | illegal design |
| [`test_illegal_method_initial_overrides`](../../tests/ch8/test_illegal_method_initial_overrides.sv) | A method declared :initial cannot override a virtual method | 8.20 | Verilator 5.052 | illegal design |
| [`test_method_initial_extends`](../../tests/ch8/test_method_initial_extends.sv) | A method declared :initial starts a method and does not override one, and a method declared :extends overrides a virtual method and is virtual itself | 8.20 | Verilator 5.052 |  |
| [`test_method_virtual`](../../tests/ch8/test_method_virtual.sv) | Virtual methods test | 8.20 8.15 | Verilator 5.052 |  |
| [`test_virt_method`](../../tests/ch8/test_virt_method.sv) | Test virtual methods | 8.20 8.14 | Verilator 5.052 |  |
| [`test_virtual_method`](../../tests/ch8/test_virtual_method.sv) | Test virtual method | 8.20 | Verilator 5.052 |  |
| [`test_abstract_class_basic`](../../tests/ch8/test_abstract_class_basic.sv) | Abstract class with pure virtual methods implemented by two derived classes | 8.21 8.20 | Verilator 5.052 |  |
| [`test_class_abstract`](../../tests/ch8/test_class_abstract.sv) | Abstract Classes (§8.21) | 8.21 | Verilator 5.052 |  |
| [`test_class_abstract_2`](../../tests/ch8/test_class_abstract_2.sv) | Test: Abstract class usage | 8.21 8.20 8.9 | Verilator 5.052 |  |
| [`test_class_virtual`](../../tests/ch8/test_class_virtual.sv) | Test: Virtual class declaration | 8.21 8.20 | Verilator 5.052 |  |
| [`test_class_virtual_2`](../../tests/ch8/test_class_virtual_2.sv) | Test: virtual class (abstract), virtual method, polymorphism via base handle | 8.21 8.20 | Verilator 5.052 |  |
| [`test_illegal_abstract_class_new`](../../tests/ch8/test_illegal_abstract_class_new.sv) | An object of an abstract (virtual) class cannot be constructed | 8.21 | Icarus Verilog 13.0 | illegal design |
| [`test_nested_class_access`](../../tests/ch8/test_nested_class_access.sv) | A class declared inside another class is used from outside through the scope resolution operator, can use the static and local members of its outer class (non-static ones through a handle), and two outer classes may each have a nested class of the same name | 8.23 8.18 | Verilator 5.052 |  |
| [`test_class_extern`](../../tests/ch8/test_class_extern.sv) | Test: Extern method declaration | 8.24 8.20 | Verilator 5.052 |  |
| [`test_extern_method_scoped_return_type`](../../tests/ch8/test_extern_method_scoped_return_type.sv) | An out of block method can use a class typedef as its return type and omit a prototype default | 8.24 | standard only |  |
| [`test_class_bounded_fifo`](../../tests/ch8/test_class_bounded_fifo.sv) | A parameterized class FIFO with a size limit, try_put and try_get | 8.25 7.10 13.5.2 | Verilator 5.052 |  |
| [`test_class_param`](../../tests/ch8/test_class_param.sv) | Test: Parameterized class | 8.25 | Verilator 5.052 |  |
| [`test_class_param_2`](../../tests/ch8/test_class_param_2.sv) | Test: Parameterized class, instantiation with different types | 8.25 | Verilator 5.052 |  |
| [`test_class_typed_param`](../../tests/ch8/test_class_typed_param.sv) | Test: Type parameter in class | 8.25 8.25.1 | Verilator 5.052 |  |
| [`test_comb_param_class`](../../tests/ch8/test_comb_param_class.sv) | Test: Parameterized class specialization | 8.25 | Verilator 5.052 |  |
| [`test_generic_fifo`](../../tests/ch8/test_generic_fifo.sv) | Parameterized class basic test | 8.25 7.10 | Verilator 5.052 |  |
| [`test_param_class`](../../tests/ch8/test_param_class.sv) | Test parameterized class | 8.25 | Verilator 5.052 |  |
| [`test_param_class_inheritance`](../../tests/ch8/test_param_class_inheritance.sv) | Parameterized Classes | 8.25 8.13 | Verilator 5.052 |  |
| [`test_param_class_multiple_params`](../../tests/ch8/test_param_class_multiple_params.sv) | Parameterized Classes | 8.25 | Verilator 5.052 |  |
| [`test_param_class_nested`](../../tests/ch8/test_param_class_nested.sv) | Parameterized Classes | 8.25 6.18 | Verilator 5.052 |  |
| [`test_parameterized_class_static_per_specialization`](../../tests/ch8/test_parameterized_class_static_per_specialization.sv) | Each specialization of a parameterized class has its own static properties, also when the constructor updates them | 8.25 8.9 | Verilator 5.052 |  |
| [`test_interface_class`](../../tests/ch8/test_interface_class.sv) | Interface class implemented by two classes, called through an interface class handle | 8.26 | Verilator 5.052 |  |
| [`test_interface_class_implements`](../../tests/ch8/test_interface_class_implements.sv) | A class implementing two parameterized interface classes, used through handles of each interface class type | 8.26 8.26.1 8.26.2 | Verilator 5.052 |  |
| [`test_interface_class_methods`](../../tests/ch8/test_interface_class_methods.sv) | Interface class method implementation test | 8.26 | Verilator 5.052 |  |
| [`test_interface_impl`](../../tests/ch8/test_interface_impl.sv) | Test: Interface class implementation | 8.26 8.26.2 | Verilator 5.052 |  |
| [`test_interface_simple_2`](../../tests/ch8/test_interface_simple_2.sv) | Simplified interface class test - IEEE 1800-2023 Ch.8.26 | 8.26 | Verilator 5.052 |  |
| [`test_interface_class_shared_method_implementation`](../../tests/ch8/test_interface_class_shared_method_implementation.sv) | One implementation satisfies matching pure virtual methods from two interface classes | 8.26.1 8.26.6.1 | Verilator 5.052 |  |
| [`test_illegal_interface_class_unqualified_type`](../../tests/ch8/test_illegal_interface_class_unqualified_type.sv) | A class that implements an interface class does not inherit its typedefs, so it cannot use one without the class scope | 8.26.3 | Verilator 5.052 | illegal design |
| [`test_interface_class_type_access`](../../tests/ch8/test_interface_class_type_access.sv) | Parameters and typedefs of an interface class are inherited by an interface class that extends it but not by a class that implements it, which reaches them with the class scope resolution operator | 8.26.3 8.26.2 8.23 | Verilator 5.052 |  |
| [`test_illegal_class_implements_type_parameter`](../../tests/ch8/test_illegal_class_implements_type_parameter.sv) | A class cannot implement a type parameter, even one whose value is an interface class | 8.26.4 | standard only | illegal design |
| [`test_illegal_implements_forward_typedef`](../../tests/ch8/test_illegal_implements_forward_typedef.sv) | A class cannot implement an interface class that is only declared by a forward typedef at that point | 8.26.4 | standard only | illegal design |
| [`test_illegal_interface_class_construction`](../../tests/ch8/test_illegal_interface_class_construction.sv) | An interface class handle cannot construct an interface class object | 8.26.5 | Verilator 5.052 | illegal design |
| [`test_interface_class_cast`](../../tests/ch8/test_interface_class_cast.sv) | $cast between interface class handles and class handles succeeds only when the object implements the destination type | 8.26.5 8.16 8.26 8.20 | standard only |  |
| [`test_interface_class_diamond`](../../tests/ch8/test_interface_class_diamond.sv) | One method implements the methods of the same name that a class gets from several interface classes, also through a diamond of extends | 8.26.6.1 8.26.6.3 8.26.2 | Verilator 5.052 |  |
| [`test_illegal_interface_class_typedef_conflict`](../../tests/ch8/test_illegal_interface_class_typedef_conflict.sv) | An interface class that inherits the same typedef name from two interface classes without declaring the name itself is an error | 8.26.6.2 | standard only | illegal design |
| [`test_interface_class_typedef_conflict_resolved`](../../tests/ch8/test_interface_class_typedef_conflict_resolved.sv) | An interface class that inherits the same typedef name from two interface classes resolves the collision by declaring the name itself | 8.26.6.2 8.26.3 8.26.6 | standard only |  |
| [`test_interface_diamond_inherited_parameter`](../../tests/ch8/test_interface_diamond_inherited_parameter.sv) | The same interface parameter inherited along a diamond is a single declaration | 8.26.6.3 | Verilator 5.052 |  |
| [`test_interface_class_partial_virtual`](../../tests/ch8/test_interface_class_partial_virtual.sv) | A virtual class can implement an interface class partly, declaring the rest pure, and a derived class completes it | 8.26.7 8.21 8.26.8 | Verilator 5.052 |  |
| [`test_interface_partial_default_argument`](../../tests/ch8/test_interface_partial_default_argument.sv) | A partial virtual implementation can complete its remaining method in a subclass while preserving constant defaults | 8.26.7 8.26.8 | Verilator 5.052 |  |
| [`test_illegal_interface_class_constraint`](../../tests/ch8/test_illegal_interface_class_constraint.sv) | An interface class cannot declare a constraint block | 8.26.9 | Verilator 5.052 | illegal design |
| [`test_interface_class_randomize`](../../tests/ch8/test_interface_class_randomize.sv) | randomize() can be called through an interface class handle; interface classes have built-in pre_randomize and post_randomize methods that the class can override, without a name conflict between two interface classes | 8.26.9 18.6.2 18.6.1 | standard only |  |
| [`test_class_typedef`](../../tests/ch8/test_class_typedef.sv) | Test: typedef class forward declaration, mutual references | 8.27 | Verilator 5.052 |  |
| [`test_forward_class_cycle_and_struct_value`](../../tests/ch8/test_forward_class_cycle_and_struct_value.sv) | Forward class declarations permit cyclic handles while a struct assignment copies its value | 8.27 8.28 | Verilator 5.052 |  |
| [`test_class_vs_struct_assignment`](../../tests/ch8/test_class_vs_struct_assignment.sv) | Assigning a class handle shares one object, while assigning a structure copies its value | 8.28 8.12 7.2 | Verilator 5.052 |  |
| [`test_object_strongly_reachable`](../../tests/ch8/test_object_strongly_reachable.sv) | An object stays strongly reachable, so its weak references are not cleared, while a handle in an active scope refers to it or a nonblocking assignment to one of its members is pending | 8.29 8.30.3 | standard only |  |
| [`test_illegal_weak_reference_non_class`](../../tests/ch8/test_illegal_weak_reference_non_class.sv) | The parameter of weak_reference has to be a class type | 8.30.1 | standard only | illegal design |
| [`test_weak_reference_id_alias_after_clear`](../../tests/ch8/test_weak_reference_id_alias_after_clear.sv) | Clearing one weak wrapper leaves another wrapper and the ownerly held object identity unchanged | 8.30.1 8.30.2 8.30.5 8.29 | standard only |  |
| [`test_weak_reference_get_clear`](../../tests/ch8/test_weak_reference_get_clear.sv) | A weak_reference returns its referent from get() until clear() is called on it, after which get() returns null; two weak references to one object are different objects with the same referent | 8.30.3 8.30.2 8.30.4 26.7 | standard only |  |
| [`test_weak_reference_wait_cleared`](../../tests/ch8/test_weak_reference_wait_cleared.sv) | A wait on weak_reference get() becoming null resumes when another process clears the reference | 8.30.3 8.30.4 9.4.3 | standard only |  |
| [`test_weak_reference_get_id`](../../tests/ch8/test_weak_reference_get_id.sv) | The static get_id() of weak_reference returns 0 for null and a nonzero value for an object, the same at every call and through every class type of the handle, and different for different objects | 8.30.5 7.8 | standard only |  |
