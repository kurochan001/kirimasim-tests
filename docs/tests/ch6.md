# Clause 6: Data types

[All chapters](README.md). 317 tests, 7 of them generated. This page is written by `tools/suite_catalog.py` from the metadata of the tests; edit the tests, not this page.

| Test | What it checks | Clauses | Expected output recorded with | Notes |
| --- | --- | --- | --- | --- |
| [`test_local_var_edge_cases`](../../tests/ch6/test_local_var_edge_cases.sv) | Local variable edge cases | 6 | Icarus Verilog 13.0 |  |
| [`test_logic_basic`](../../tests/ch6/test_logic_basic.sv) | Logic Basic Tests | 6.3.1 6.11 | Icarus Verilog 13.0 |  |
| [`test_value_logic`](../../tests/ch6/test_value_logic.sv) | Test for logic value operations | 6.3.1 11.4.8 | Icarus Verilog 13.0 | x/z |
| [`test_trireg_retention_decay_and_recharge`](../../tests/ch6/test_trireg_retention_decay_and_recharge.sv) | A trireg retains charge after disconnection decays to unknown and can be recharged | 6.3.2.1 6.6.4.1 6.6.4.2 28.15.2 28.16.2.2 | standard only | x/z |
| [`test_net_declaration_drive_strength`](../../tests/ch6/test_net_declaration_drive_strength.sv) | A net declaration that assigns the net can give the drive strength of that continuous assignment, which then drives the net | 6.3.2.2 10.3.1 10.3.4 21.2.1.4 | Icarus Verilog 13.0 | x/z |
| [`test_net_strength_and_scalared_select`](../../tests/ch6/test_net_strength_and_scalared_select.sv) | Scalared net part selects resolve asymmetric driver strengths independently | 6.3.2.2 6.9.2 | Icarus Verilog 13.0 |  |
| [`test_singular_and_aggregate_value_copy`](../../tests/ch6/test_singular_and_aggregate_value_copy.sv) | Packed singular values and unpacked aggregate values copy independently into subroutines | 6.4 7.7 | Verilator 5.052 |  |
| [`test_illegal_input_port_variable_assigned`](../../tests/ch6/test_illegal_input_port_variable_assigned.sv) | A module cannot assign to its own input port when the port is a variable | 6.5 23.2.2.3 | Verilator 5.052 | illegal design |
| [`test_illegal_mixed_continuous_procedural`](../../tests/ch6/test_illegal_mixed_continuous_procedural.sv) | A variable that a continuous assignment writes cannot also be written by a procedural assignment | 6.5 | Icarus Verilog 13.0 | illegal design |
| [`test_illegal_output_port_variable_also_assigned`](../../tests/ch6/test_illegal_output_port_variable_also_assigned.sv) | A variable connected to an output port of an instance cannot also be assigned elsewhere | 6.5 23.3.3 | Icarus Verilog 13.0 | illegal design |
| [`test_illegal_overlapping_continuous_assigns`](../../tests/ch6/test_illegal_overlapping_continuous_assigns.sv) | Two continuous assignments to overlapping bits of a variable are illegal, even when other bits are written once | 6.5 11.5.3 | Icarus Verilog 13.0 | illegal design |
| [`test_illegal_redeclaration`](../../tests/ch6/test_illegal_redeclaration.sv) | A name already declared in a scope cannot be declared again in the same scope | 6.5 3.13 | Icarus Verilog 13.0 | illegal design |
| [`test_net_logic`](../../tests/ch6/test_net_logic.sv) | Logic type behavior | 6.5 10.3 | Icarus Verilog 13.0 | x/z |
| [`test_wire_logic`](../../tests/ch6/test_wire_logic.sv) | 6.7 - Wire and Logic Tests | 6.5 | Icarus Verilog 13.0 |  |
| [`test_wire_reg`](../../tests/ch6/test_wire_reg.sv) | Test for wire and reg types | 6.5 6.7 6.8 | Icarus Verilog 13.0 |  |
| [`test_net_resolution`](../../tests/ch6/test_net_resolution.sv) | Net Resolution Tests | 6.6.1 6.6.3 | Icarus Verilog 13.0 | x/z |
| [`test_net_tri`](../../tests/ch6/test_net_tri.sv) | Tri net type (tri-state) | 6.6.1 | Icarus Verilog 13.0 | x/z |
| [`test_net_types`](../../tests/ch6/test_net_types.sv) | Net Types Tests | 6.6.1 6.6.3 6.6.6 | Icarus Verilog 13.0 | x/z |
| [`test_net_types_2`](../../tests/ch6/test_net_types_2.sv) | wire, tri and supply nets driven by continuous assignments | 6.6.1 6.6.6 | Icarus Verilog 13.0 | x/z |
| [`test_net_types_3`](../../tests/ch6/test_net_types_3.sv) | Net types: wire, wand, wor, tri, supply0, supply1 | 6.6.1 6.6.3 6.6.6 | Icarus Verilog 13.0 | x/z |
| [`test_net_types_edge_cases`](../../tests/ch6/test_net_types_edge_cases.sv) | Net types edge cases | 6.6.1 6.6.3 6.6.5 | Icarus Verilog 13.0 | x/z |
| [`test_net_wire`](../../tests/ch6/test_net_wire.sv) | Wire net type | 6.6.1 | Icarus Verilog 13.0 |  |
| [`test_tri_edge_cases`](../../tests/ch6/test_tri_edge_cases.sv) | tri, tri0 and tri1 nets with and without drivers | 6.6.1 6.6.5 | Icarus Verilog 13.0 | x/z |
| [`test_wire_edge_cases`](../../tests/ch6/test_wire_edge_cases.sv) | wire, tri, wand and wor nets with one and two drivers | 6.6.1 6.6.3 | Icarus Verilog 13.0 | x/z |
| [`test_illegal_uwire_two_drivers`](../../tests/ch6/test_illegal_uwire_two_drivers.sv) | A uwire net with two drivers is an error | 6.6.2 | Icarus Verilog 13.0 | illegal design |
| [`test_net_uwire`](../../tests/ch6/test_net_uwire.sv) | Uwire net type (unresolved wire - single driver only) | 6.6.2 | Icarus Verilog 13.0 |  |
| [`test_uwire_edge_cases`](../../tests/ch6/test_uwire_edge_cases.sv) | uwire nets with a single continuous assignment | 6.6.2 | Icarus Verilog 13.0 |  |
| [`test_edge_wor_wand`](../../tests/ch6/test_edge_wor_wand.sv) | wor and wand nets resolve two constant drivers | 6.6.3 4.4.2.3 | Icarus Verilog 13.0 | x/z |
| [`test_net_resolution_multi`](../../tests/ch6/test_net_resolution_multi.sv) | Wired nets, tri0/tri1, supply nets, pull sources and strength resolution | 6.6.3 6.6.5 6.6.6 28.10 28.12 | Icarus Verilog 13.0 | x/z |
| [`test_net_triand`](../../tests/ch6/test_net_triand.sv) | Triand net type (tri-state AND) | 6.6.3 | Icarus Verilog 13.0 | x/z |
| [`test_net_trior`](../../tests/ch6/test_net_trior.sv) | Trior net type (tri-state OR) | 6.6.3 | Icarus Verilog 13.0 | x/z |
| [`test_net_types_resolution`](../../tests/ch6/test_net_types_resolution.sv) | Resolution of wor, wand, tri, triand and trior nets with constant drivers | 6.6.3 6.6.4 6.6.2 10.3.2 | Icarus Verilog 13.0 | x/z |
| [`test_net_wand`](../../tests/ch6/test_net_wand.sv) | Wand net type (wired-AND) | 6.6.3 | Icarus Verilog 13.0 | x/z |
| [`test_net_wor`](../../tests/ch6/test_net_wor.sv) | Wor net type (wired-OR) | 6.6.3 | Icarus Verilog 13.0 | x/z |
| [`test_udn_resolution`](../../tests/ch6/test_udn_resolution.sv) | Test: UDN (User-Defined Net) Resolution Functions | 6.6.3 | Icarus Verilog 13.0 | x/z |
| [`test_wand_edge_cases`](../../tests/ch6/test_wand_edge_cases.sv) | wand nets resolving two drivers | 6.6.3 | Icarus Verilog 13.0 | x/z |
| [`test_wor_edge_cases`](../../tests/ch6/test_wor_edge_cases.sv) | wor nets resolving two drivers | 6.6.3 | Icarus Verilog 13.0 | x/z |
| [`test_trireg_holds_charge`](../../tests/ch6/test_trireg_holds_charge.sv) | When its driver turns off, a trireg net keeps the last value with the charge strength of its size, small, medium or large | 6.6.4 6.6.4.1 28.11 21.2.1.4 | standard only | x/z |
| [`test_net_tri0`](../../tests/ch6/test_net_tri0.sv) | Tri0 net type (pulls to 0 when floating) | 6.6.5 | Icarus Verilog 13.0 | x/z |
| [`test_supply_edge_cases`](../../tests/ch6/test_supply_edge_cases.sv) | supply0 and supply1 nets, scalar and vector | 6.6.6 4.7 | Icarus Verilog 13.0 |  |
| [`test_supply_wire`](../../tests/ch6/test_supply_wire.sv) | Test supply wires | 6.6.6 | Icarus Verilog 13.0 |  |
| [`test_nettype_resolution`](../../tests/ch6/test_nettype_resolution.sv) | a net of a user-defined nettype takes the value its resolution function computes from all its drivers, including an output port, again whenever a driver changes; a second nettype name shares the resolution, and force and release override and restore the resolved value | 6.6.7 10.3 10.6.2 23.3.3 | standard only |  |
| [`test_x_value_bitwise`](../../tests/ch6/test_x_value_bitwise.sv) | 4-state logic truth tables | 6.6.7 11.4.8 | Icarus Verilog 13.0 | x/z |
| [`test_illegal_interconnect_assigned`](../../tests/ch6/test_illegal_interconnect_assigned.sv) | An interconnect net cannot be the target of a continuous assignment | 6.6.8 6.7.1 | standard only | illegal design |
| [`test_wire_init`](../../tests/ch6/test_wire_init.sv) | Test wire with initialization | 6.7 10.3.1 | Icarus Verilog 13.0 |  |
| [`test_illegal_interconnect_data_type`](../../tests/ch6/test_illegal_interconnect_data_type.sv) | An interconnect net cannot be declared with a data type | 6.7.1 6.6.8 | standard only | illegal design |
| [`test_illegal_net_type_then_reg`](../../tests/ch6/test_illegal_net_type_then_reg.sv) | A net type keyword cannot be followed directly by the keyword reg in a declaration | 6.7.1 | standard only | illegal design |
| [`test_net_declaration_data_types`](../../tests/ch6/test_net_declaration_data_types.sv) | A net can have any 4-state integral data type, a typedef or a packed structure, a net without one is logic, and undriven nets hold z in every bit | 6.7.1 6.11.1 7.2.1 | Icarus Verilog 13.0 | x/z |
| [`test_trireg_default_value_strength`](../../tests/ch6/test_trireg_default_value_strength.sv) | Before any driver drives them, a trireg net holds x with the charge strength of its size, medium by default, while other nets hold z | 6.7.1 6.3.2.1 21.2.1.4 | standard only | x/z |
| [`test_nettype_alias_resolution_and_empty_drivers`](../../tests/ch6/test_nettype_alias_resolution_and_empty_drivers.sv) | A chain of nettype aliases merges port drivers and undriven resolved nets evaluate their empty driver set | 6.7.2 6.7.3 6.22.6 | standard only |  |
| [`test_nettype_initial_value_resolution`](../../tests/ch6/test_nettype_initial_value_resolution.sv) | A net of a user-defined nettype starts with the default value of its data type, struct member initializers included, logic being x rather than z, and a resolved nettype resolves at time zero even without drivers | 6.7.3 6.7.2 6.6.7 | standard only | x/z |
| [`test_class_static_init_order`](../../tests/ch6/test_class_static_init_order.sv) | The declaration initializers of static class properties and of package variables take effect before any initial procedure starts, so updates made at time 0 build on them instead of being overwritten | 6.8 8.9 26.2 | Verilator 5.052 |  |
| [`test_enum_default_and_invalid_index`](../../tests/ch6/test_enum_default_and_invalid_index.sv) | An enum variable starts at the default of its base type, and so does a read of an enum array with an invalid index | 6.8 6.19 7.4.5 8.7 | standard only | x/z |
| [`test_logic_type`](../../tests/ch6/test_logic_type.sv) | Test logic type | 6.8 | Icarus Verilog 13.0 |  |
| [`test_logic_val`](../../tests/ch6/test_logic_val.sv) | Logic Value Tests | 6.8 | Icarus Verilog 13.0 |  |
| [`test_reg_edge_cases`](../../tests/ch6/test_reg_edge_cases.sv) | reg variables: initial x, x and z values, selects, signed reg | 6.8 6.11 | Icarus Verilog 13.0 | x/z |
| [`test_reg_init`](../../tests/ch6/test_reg_init.sv) | Test register initialization | 6.8 10.5 | Icarus Verilog 13.0 |  |
| [`test_uninitialized_package_and_class_variables`](../../tests/ch6/test_uninitialized_package_and_class_variables.sv) | 4-state variables in a package and class properties without an initializer start as x, and 2-state ones as 0 | 6.8 26.2 8.7 | Icarus Verilog 13.0 | x/z |
| [`test_logic_vector`](../../tests/ch6/test_logic_vector.sv) | Logic Vector Tests | 6.9 | Icarus Verilog 13.0 |  |
| [`test_max_width`](../../tests/ch6/test_max_width.sv) | Arithmetic, bitwise, shift and concatenation on 64- to 512-bit vectors | 6.9.1 11.4.12 | Icarus Verilog 13.0 |  |
| [`test_vector_net_scalared`](../../tests/ch6/test_vector_net_scalared.sv) | A vector net declared scalared allows bit-selects and part-selects, so continuous assignments can drive single bits of it while the others keep the value of the net type | 6.9.2 6.6.5 10.3.2 | Icarus Verilog 13.0 | x/z |
| [`test_implicit_net_declarations`](../../tests/ch6/test_implicit_net_declarations.sv) | An undeclared name on the left of a continuous assignment, in a port connection or in a primitive terminal list becomes an implicit scalar net | 6.10 22.8 | Icarus Verilog 13.0 |  |
| [`test_bit_type`](../../tests/ch6/test_bit_type.sv) | Test bit type | 6.11 | Icarus Verilog 13.0 |  |
| [`test_bit_type_edge_cases`](../../tests/ch6/test_bit_type_edge_cases.sv) | Bit type edge cases | 6.11 11.4.8 11.4.10 11.4.9 | Icarus Verilog 13.0 |  |
| [`test_byte_edge_cases`](../../tests/ch6/test_byte_edge_cases.sv) | Byte edge cases | 6.11 11.4.3 11.4.8 6.24.1 | Icarus Verilog 13.0 |  |
| [`test_byte_ops`](../../tests/ch6/test_byte_ops.sv) | Test byte operations | 6.11 11.6.1 | Icarus Verilog 13.0 |  |
| [`test_cast_bit`](../../tests/ch6/test_cast_bit.sv) | 2-state type casts | 6.11 10.7 | Icarus Verilog 13.0 |  |
| [`test_core_types`](../../tests/ch6/test_core_types.sv) | Test core types | 6.11 6.12 6.16 6.4 | Icarus Verilog 13.0 | x/z |
| [`test_int_types_edge_cases`](../../tests/ch6/test_int_types_edge_cases.sv) | Test: Integer types edge cases | 6.11 5.7.1 | Icarus Verilog 13.0 |  |
| [`test_integer_edge_cases`](../../tests/ch6/test_integer_edge_cases.sv) | Integer edge cases | 6.11 | Icarus Verilog 13.0 | x/z |
| [`test_integer_ops`](../../tests/ch6/test_integer_ops.sv) | Integer Operations Tests | 6.11 | Icarus Verilog 13.0 |  |
| [`test_integer_type`](../../tests/ch6/test_integer_type.sv) | Test integer type | 6.11 | Icarus Verilog 13.0 |  |
| [`test_integer_types`](../../tests/ch6/test_integer_types.sv) | Chapter 6: Data types | 6.11 6.11.1 6.11.2 6.11.3 | Icarus Verilog 13.0 | x/z |
| [`test_longint_type`](../../tests/ch6/test_longint_type.sv) | Test longint type | 6.11 | Icarus Verilog 13.0 |  |
| [`test_net_reg`](../../tests/ch6/test_net_reg.sv) | Reg variable type | 6.11 | Icarus Verilog 13.0 |  |
| [`test_reg_type`](../../tests/ch6/test_reg_type.sv) | Test reg type | 6.11 | Icarus Verilog 13.0 |  |
| [`test_reg_wire_types`](../../tests/ch6/test_reg_wire_types.sv) | Reg and Wire Type Tests | 6.11 6.5 | Icarus Verilog 13.0 |  |
| [`test_shortint_byte`](../../tests/ch6/test_shortint_byte.sv) | Shortint and Byte Types Tests | 6.11 | Icarus Verilog 13.0 |  |
| [`test_shortint_edge_cases`](../../tests/ch6/test_shortint_edge_cases.sv) | shortint initial value, range limits and arithmetic | 6.11 | Icarus Verilog 13.0 |  |
| [`test_shortint_type`](../../tests/ch6/test_shortint_type.sv) | Test shortint type | 6.11 | Icarus Verilog 13.0 |  |
| [`test_signal_types_edge_cases`](../../tests/ch6/test_signal_types_edge_cases.sv) | logic, bit, integer and int variables and assignments between them | 6.11 | Icarus Verilog 13.0 |  |
| [`test_type`](../../tests/ch6/test_type.sv) | Assignments between integral types, real conversion and string conversion methods | 6.11 6.16.9 20.5 | Icarus Verilog 13.0 |  |
| [`test_ieee_compliance_dimensions_twostate`](../../tests/ch6/test_ieee_compliance_dimensions_twostate.sv) | Compliance Test - $dimensions and 2-state conversion | 6.11.2 7.4.1 8 20.7 | Icarus Verilog 13.0 | x/z |
| [`test_longint_edge_cases`](../../tests/ch6/test_longint_edge_cases.sv) | Longint edge cases | 6.11.2 | Icarus Verilog 13.0 |  |
| [`test_integer_atom_defaults_and_widths`](../../tests/ch6/test_integer_atom_defaults_and_widths.sv) | Integer atom types have fixed widths and signed default arithmetic | 6.11.3 6.11 6.8 | Icarus Verilog 13.0 | x/z |
| [`test_illegal_real_bit_select`](../../tests/ch6/test_illegal_real_bit_select.sv) | A bit-select of a real variable is not allowed | 6.12 11.5.1 | Icarus Verilog 13.0 | illegal design |
| [`test_illegal_real_edge_event`](../../tests/ch6/test_illegal_real_edge_event.sv) | An edge event control on a real variable is not allowed | 6.12 9.4.2 | Icarus Verilog 13.0 | illegal design |
| [`test_real_edge_cases`](../../tests/ch6/test_real_edge_cases.sv) | real, shortreal and realtime arithmetic, casts and comparisons | 6.12 6.12.1 | Icarus Verilog 13.0 |  |
| [`test_real_ops`](../../tests/ch6/test_real_ops.sv) | Real Number Operations Tests | 6.12 6.12.1 | Icarus Verilog 13.0 |  |
| [`test_real_ops_edge_cases`](../../tests/ch6/test_real_ops_edge_cases.sv) | real arithmetic, comparison and conversion with $rtoi and $itor | 6.12 20.5 | Icarus Verilog 13.0 |  |
| [`test_real_type`](../../tests/ch6/test_real_type.sv) | Test real/shortreal types | 6.12 | Icarus Verilog 13.0 |  |
| [`test_real_type_edge_cases`](../../tests/ch6/test_real_type_edge_cases.sv) | real arithmetic, comparison and casting | 6.12 | Icarus Verilog 13.0 |  |
| [`test_real_types`](../../tests/ch6/test_real_types.sv) | Chapter 6: Data types | 6.12 6.12.1 | Icarus Verilog 13.0 |  |
| [`test_reals_edge_cases`](../../tests/ch6/test_reals_edge_cases.sv) | real arithmetic and casts between real and int | 6.12 6.12.1 | Icarus Verilog 13.0 |  |
| [`test_realtime_ops`](../../tests/ch6/test_realtime_ops.sv) | Realtime Operations Tests | 6.12 6.12.1 11.4.3 | Icarus Verilog 13.0 |  |
| [`test_realtime_ops_2`](../../tests/ch6/test_realtime_ops_2.sv) | Realtime variable operations | 6.12 | Icarus Verilog 13.0 |  |
| [`test_shortreal_single_precision`](../../tests/ch6/test_shortreal_single_precision.sv) | A shortreal holds a single-precision value, also when written by a nonblocking assignment, as an array element or by a cast | 6.12 6.24.1 20.5 | standard only |  |
| [`test_implicit_conversion`](../../tests/ch6/test_implicit_conversion.sv) | Tests automatic type promotions and conversions | 6.12.1 6.24.1 11.8.1 10.7 | Verilator 5.052 |  |
| [`test_real_arithmetic`](../../tests/ch6/test_real_arithmetic.sv) | Real arithmetic and rounding conversion of real to int | 6.12.1 6.24.1 11.4.3 | Icarus Verilog 13.0 |  |
| [`test_real_conversion_wide_and_unknown`](../../tests/ch6/test_real_conversion_wide_and_unknown.sv) | Conversion to real of vectors wider than 64 bits, of a negative signed vector and of a vector with x and z bits | 6.12.1 | Icarus Verilog 13.0 | x/z |
| [`test_type_casts`](../../tests/ch6/test_type_casts.sv) | Type casting | 6.12.1 6.24.1 | Icarus Verilog 13.0 |  |
| [`test_void_function_and_cast`](../../tests/ch6/test_void_function_and_cast.sv) | A function with the void return type returns no value and is called as a statement, and casting a function call to void discards its result | 6.13 13.4.1 6.24.1 | Icarus Verilog 13.0 |  |
| [`test_void_return_and_discard_side_effect`](../../tests/ch6/test_void_return_and_discard_side_effect.sv) | Void functions can return early and a void cast discards a value without discarding its side effect | 6.13 | Icarus Verilog 13.0 |  |
| [`test_chandle_edge_cases`](../../tests/ch6/test_chandle_edge_cases.sv) | Test: Chandle edge cases | 6.14 | Verilator 5.052 |  |
| [`test_chandle_ops`](../../tests/ch6/test_chandle_ops.sv) | Test chandle null checks and operations | 6.14 | Verilator 5.052 |  |
| [`test_comb_string_compare`](../../tests/ch6/test_comb_string_compare.sv) | Test: String comparison operators and methods | 6.16 | Verilator 5.052 |  |
| [`test_edge_assoc_array_keys`](../../tests/ch6/test_edge_assoc_array_keys.sv) | String keys with "\0" in associative arrays: "\0" is removed from string literals | 6.16 7.8.1 | Verilator 5.052 |  |
| [`test_edge_case_strings`](../../tests/ch6/test_edge_case_strings.sv) | Corner case tests for string operations | 6.16 | Verilator 5.052 |  |
| [`test_expr_string`](../../tests/ch6/test_expr_string.sv) | String expressions test | 6.16 11.4.12 | Verilator 5.052 |  |
| [`test_string_basic`](../../tests/ch6/test_string_basic.sv) | String Basic Tests | 6.16 | Icarus Verilog 13.0 |  |
| [`test_string_cmp`](../../tests/ch6/test_string_cmp.sv) | String Compare Tests | 6.16 | Icarus Verilog 13.0 |  |
| [`test_string_compare`](../../tests/ch6/test_string_compare.sv) | String comparison operators: ==, !=, &lt;, >, &lt;=, >= | 6.16 | Icarus Verilog 13.0 |  |
| [`test_string_corner`](../../tests/ch6/test_string_corner.sv) | Tests string methods, comparisons, and special characters | 6.16 6.16.9 | Verilator 5.052 |  |
| [`test_string_edge`](../../tests/ch6/test_string_edge.sv) | String edge cases | 6.16 6.16.9 6.16.10 6.16.11 6.16.12 | standard only |  |
| [`test_string_edge_cases`](../../tests/ch6/test_string_edge_cases.sv) | String edge cases test | 6.16 | Verilator 5.052 |  |
| [`test_string_edge_cases_2`](../../tests/ch6/test_string_edge_cases_2.sv) | Test: String edge cases | 6.16 | Verilator 5.052 |  |
| [`test_string_functions_comprehensive`](../../tests/ch6/test_string_functions_comprehensive.sv) | String System Functions Comprehensive Test | 6.16 | standard only |  |
| [`test_string_ignores_null_characters`](../../tests/ch6/test_string_ignores_null_characters.sv) | A string variable drops the null characters of a string literal and ignores a null character written to one of its characters | 6.16 | Icarus Verilog 13.0 |  |
| [`test_string_len`](../../tests/ch6/test_string_len.sv) | String Length Tests | 6.16 | Icarus Verilog 13.0 |  |
| [`test_string_methods`](../../tests/ch6/test_string_methods.sv) | String methods | 6.16 6.16.1 6.16.3 6.16.8 | Verilator 5.052 |  |
| [`test_string_methods_2`](../../tests/ch6/test_string_methods_2.sv) | String Methods (§6.16) | 6.16 | Verilator 5.052 |  |
| [`test_string_methods_3`](../../tests/ch6/test_string_methods_3.sv) | String methods len, getc, putc, atoi and atohex | 6.16 | Verilator 5.052 |  |
| [`test_string_methods_4`](../../tests/ch6/test_string_methods_4.sv) | Test string methods: len, substr, getc, putc, toupper, tolower | 6.16 | Verilator 5.052 |  |
| [`test_string_methods_corner`](../../tests/ch6/test_string_methods_corner.sv) | Tests string built-in methods: len, putc, getc, toupper, tolower, compare, substr, etc. | 6.16 | Verilator 5.052 |  |
| [`test_string_methods_edge_cases`](../../tests/ch6/test_string_methods_edge_cases.sv) | Test: String methods edge cases | 6.16 5.9 | Verilator 5.052 |  |
| [`test_string_operations`](../../tests/ch6/test_string_operations.sv) | String Operations Extended Tests | 6.16 | Verilator 5.052 |  |
| [`test_string_ops`](../../tests/ch6/test_string_ops.sv) | Test for string operations | 6.16 11.4.12 | Verilator 5.052 |  |
| [`test_string_ops_2`](../../tests/ch6/test_string_ops_2.sv) | String len, concatenation, toupper, tolower and substr | 6.16 | Verilator 5.052 |  |
| [`test_string_ops_3`](../../tests/ch6/test_string_ops_3.sv) | String operation edge cases | 6.16 5.9 | Verilator 5.052 |  |
| [`test_string_ops_edge_cases`](../../tests/ch6/test_string_ops_edge_cases.sv) | String operations edge cases | 6.16 | standard only |  |
| [`test_sv_string`](../../tests/ch6/test_sv_string.sv) | Test: String: len(), substr(), {concat}, toupper/tolower, atoi, comparisons | 6.16 | Verilator 5.052 |  |
| [`test_value_string`](../../tests/ch6/test_value_string.sv) | Test for string value operations | 6.16 | Verilator 5.052 |  |
| [`test_string_atoreal`](../../tests/ch6/test_string_atoreal.sv) | Test: String atoreal method | 6.16.1 6.16.9 | Icarus Verilog 13.0 |  |
| [`test_string_bintoa`](../../tests/ch6/test_string_bintoa.sv) | Test: String bintoa method | 6.16.1 6.16.10 | Icarus Verilog 13.0 |  |
| [`test_string_itoa`](../../tests/ch6/test_string_itoa.sv) | Test: String itoa method | 6.16.1 6.16.10 | Icarus Verilog 13.0 |  |
| [`test_string_len_2`](../../tests/ch6/test_string_len_2.sv) | String len method | 6.16.1 | Icarus Verilog 13.0 |  |
| [`test_string_octtoa`](../../tests/ch6/test_string_octtoa.sv) | Test: String octtoa method | 6.16.1 6.16.10 | Icarus Verilog 13.0 |  |
| [`test_string_substr`](../../tests/ch6/test_string_substr.sv) | Test: String substr method | 6.16.1 6.16.8 | Icarus Verilog 13.0 |  |
| [`test_string_putc`](../../tests/ch6/test_string_putc.sv) | Test string putc | 6.16.2 | Verilator 5.052 |  |
| [`test_string_putc_2`](../../tests/ch6/test_string_putc_2.sv) | Test: String putc method | 6.16.2 | Verilator 5.052 |  |
| [`test_string_putc_getc`](../../tests/ch6/test_string_putc_getc.sv) | String data type | 6.16.2 6.16.3 | Verilator 5.052 |  |
| [`test_string_getc`](../../tests/ch6/test_string_getc.sv) | Test: String getc method | 6.16.3 | Verilator 5.052 |  |
| [`test_string_getc_2`](../../tests/ch6/test_string_getc_2.sv) | Test string getc | 6.16.3 | Verilator 5.052 |  |
| [`test_string_getc_is_byte`](../../tests/ch6/test_string_getc_is_byte.sv) | str.getc(i) returns a byte, so a concatenation of two calls is 16 bits wide | 6.16.3 11.4.12 | standard only |  |
| [`test_string_manipulation`](../../tests/ch6/test_string_manipulation.sv) | String data type | 6.16.4 6.16.5 6.16.6 6.16.7 6.16.8 | Verilator 5.052 |  |
| [`test_string_toupper`](../../tests/ch6/test_string_toupper.sv) | Test: String toupper method | 6.16.4 | Verilator 5.052 |  |
| [`test_string_toupper_2`](../../tests/ch6/test_string_toupper_2.sv) | Test string toupper | 6.16.4 | Verilator 5.052 |  |
| [`test_string_tolower`](../../tests/ch6/test_string_tolower.sv) | Test: String tolower method | 6.16.5 | Verilator 5.052 |  |
| [`test_string_tolower_2`](../../tests/ch6/test_string_tolower_2.sv) | Test string tolower | 6.16.5 | Verilator 5.052 |  |
| [`test_string_compare_2`](../../tests/ch6/test_string_compare_2.sv) | Test: String compare method | 6.16.6 | Verilator 5.052 |  |
| [`test_string_icompare`](../../tests/ch6/test_string_icompare.sv) | Test: String icompare method (case-insensitive compare) | 6.16.7 | Verilator 5.052 |  |
| [`test_string_methods_extended`](../../tests/ch6/test_string_methods_extended.sv) | Extended String Methods Tests | 6.16.8 6.16.3 6.16.2 6.16.6 | Verilator 5.052 |  |
| [`test_string_substr_2`](../../tests/ch6/test_string_substr_2.sv) | Test string substr | 6.16.8 | Icarus Verilog 13.0 |  |
| [`test_string_substr_out_of_range`](../../tests/ch6/test_string_substr_out_of_range.sv) | substr returns the empty string when its range is not inside the string | 6.16.8 | Icarus Verilog 13.0 |  |
| [`test_string_atobin`](../../tests/ch6/test_string_atobin.sv) | Test: String atobin method | 6.16.9 | Verilator 5.052 |  |
| [`test_string_atobin_2`](../../tests/ch6/test_string_atobin_2.sv) | Test string atobin method | 6.16.9 | Verilator 5.052 |  |
| [`test_string_atohex`](../../tests/ch6/test_string_atohex.sv) | Test: String atohex method | 6.16.9 | Icarus Verilog 13.0 |  |
| [`test_string_atohex_2`](../../tests/ch6/test_string_atohex_2.sv) | Test string atohex method | 6.16.9 | Icarus Verilog 13.0 |  |
| [`test_string_atoi`](../../tests/ch6/test_string_atoi.sv) | Test string atoi method | 6.16.9 | Icarus Verilog 13.0 |  |
| [`test_string_atoi_2`](../../tests/ch6/test_string_atoi_2.sv) | Test: String atoi method | 6.16.9 | Icarus Verilog 13.0 |  |
| [`test_string_atooct`](../../tests/ch6/test_string_atooct.sv) | Test: String atooct method | 6.16.9 | Verilator 5.052 |  |
| [`test_string_atooct_2`](../../tests/ch6/test_string_atooct_2.sv) | Test string atooct method | 6.16.9 | Verilator 5.052 |  |
| [`test_string_conversion`](../../tests/ch6/test_string_conversion.sv) | String data type | 6.16.9 6.16.10 6.16.11 6.16.12 6.16.13 6.16.14 6.16.15 | standard only |  |
| [`test_string_atoreal_2`](../../tests/ch6/test_string_atoreal_2.sv) | Test string atoreal method | 6.16.10 | Icarus Verilog 13.0 |  |
| [`test_string_itoa_2`](../../tests/ch6/test_string_itoa_2.sv) | Test string itoa method | 6.16.11 | Icarus Verilog 13.0 |  |
| [`test_string_hextoa`](../../tests/ch6/test_string_hextoa.sv) | Test: String hextoa method | 6.16.12 | Verilator 5.052 |  |
| [`test_string_binary_octal_round_trip`](../../tests/ch6/test_string_binary_octal_round_trip.sv) | Binary and octal conversion methods replace an existing string and round trip zero and a high positive integer | 6.16.13 6.16.14 | Verilator 5.052 |  |
| [`test_string_realtoa`](../../tests/ch6/test_string_realtoa.sv) | Test: String realtoa method | 6.16.15 6.16.10 | Icarus Verilog 13.0 |  |
| [`test_event_rebinding_retains_old_wait`](../../tests/ch6/test_event_rebinding_retains_old_wait.sv) | Rebinding an event variable does not retarget a process already blocked on its old synchronization object | 6.17 15.5.5.1 | standard only |  |
| [`test_event_variable_alias_null`](../../tests/ch6/test_event_variable_alias_null.sv) | An event variable declared without an initializer gets a new synchronization object, one assigned from another event shares that object, and one assigned null has none | 6.17 15.5.5 15.5.1 | standard only |  |
| [`test_type_def`](../../tests/ch6/test_type_def.sv) | Typedef Tests | 6.18 20.6.2 | Verilator 5.052 |  |
| [`test_typedef`](../../tests/ch6/test_typedef.sv) | typedef of vectors, an enum and a packed struct | 6.18 | Icarus Verilog 13.0 |  |
| [`test_typedef_advanced`](../../tests/ch6/test_typedef_advanced.sv) | Advanced Typedef Tests | 6.18 | Icarus Verilog 13.0 |  |
| [`test_typedef_advanced_2`](../../tests/ch6/test_typedef_advanced_2.sv) | Typedef advanced tests | 6.18 | Verilator 5.052 |  |
| [`test_typedef_basic`](../../tests/ch6/test_typedef_basic.sv) | Typedef Tests | 6.18 | Icarus Verilog 13.0 |  |
| [`test_typedef_corner`](../../tests/ch6/test_typedef_corner.sv) | Tests various typedef declarations and forward typedefs | 6.18 7.2 7.10 | Icarus Verilog 13.0 |  |
| [`test_typedef_edge_cases`](../../tests/ch6/test_typedef_edge_cases.sv) | typedef of vectors, int and a packed struct | 6.18 | Icarus Verilog 13.0 |  |
| [`test_typedef_param`](../../tests/ch6/test_typedef_param.sv) | Test: Parameterized typedef | 6.18 6.20.2 8.25 | Verilator 5.052 |  |
| [`test_typedef_struct_enum`](../../tests/ch6/test_typedef_struct_enum.sv) | Typedef with struct and enum | 6.18 6.19 7.2 | Verilator 5.052 |  |
| [`test_typedef_types_edge_cases`](../../tests/ch6/test_typedef_types_edge_cases.sv) | typedef of vectors, packed arrays and int unsigned, with casts | 6.18 | Icarus Verilog 13.0 |  |
| [`test_cast_enum`](../../tests/ch6/test_cast_enum.sv) | Test: Enum type casting | 6.19 6.19.5 6.24.1 | Icarus Verilog 13.0 |  |
| [`test_enum_basic`](../../tests/ch6/test_enum_basic.sv) | Enum Basic Tests | 6.19 | Icarus Verilog 13.0 |  |
| [`test_enum_basic_edge_cases`](../../tests/ch6/test_enum_basic_edge_cases.sv) | Enum basic edge cases | 6.19 | Icarus Verilog 13.0 |  |
| [`test_enum_casts_and_values`](../../tests/ch6/test_enum_casts_and_values.sv) | Enum casts and numeric values | 6.19 6.19.4 | Icarus Verilog 13.0 |  |
| [`test_enum_edge_cases`](../../tests/ch6/test_enum_edge_cases.sv) | Test: Enum edge cases | 6.19 | Icarus Verilog 13.0 |  |
| [`test_enum_methods_typed`](../../tests/ch6/test_enum_methods_typed.sv) | Enumerated types | 6.19 6.19.5 | Icarus Verilog 13.0 |  |
| [`test_enum_operations`](../../tests/ch6/test_enum_operations.sv) | Enum Operations Tests | 6.19 6.19.4 | Icarus Verilog 13.0 |  |
| [`test_enum_ops`](../../tests/ch6/test_enum_ops.sv) | Test for enum operations | 6.19 6.19.5 | Icarus Verilog 13.0 |  |
| [`test_enum_ops_edge_cases`](../../tests/ch6/test_enum_ops_edge_cases.sv) | Test: Enum operations edge cases | 6.19 | Icarus Verilog 13.0 |  |
| [`test_enum_signed`](../../tests/ch6/test_enum_signed.sv) | Signed enum values and the first, last, num, next and prev methods | 6.19 6.19.5 | Icarus Verilog 13.0 |  |
| [`test_enum_type`](../../tests/ch6/test_enum_type.sv) | Test enum types | 6.19 6.19.4 | Icarus Verilog 13.0 |  |
| [`test_enum_types_edge_cases`](../../tests/ch6/test_enum_types_edge_cases.sv) | Test: Enum types edge cases | 6.19 | Icarus Verilog 13.0 |  |
| [`test_enum_values_methods`](../../tests/ch6/test_enum_values_methods.sv) | Enum values and enum methods | 6.19 | Icarus Verilog 13.0 |  |
| [`test_enums_edge_cases`](../../tests/ch6/test_enums_edge_cases.sv) | Test: Enums edge cases | 6.19 | Icarus Verilog 13.0 |  |
| [`test_illegal_enum_duplicate_value`](../../tests/ch6/test_illegal_enum_duplicate_value.sv) | Two names of an enumeration cannot have the same value, also when one value comes from automatic increment | 6.19 | Icarus Verilog 13.0 | illegal design |
| [`test_illegal_enum_increment_overflow`](../../tests/ch6/test_illegal_enum_increment_overflow.sv) | Automatic increment past the largest value of the base type of an enumeration is an error | 6.19 | Icarus Verilog 13.0 | illegal design |
| [`test_illegal_enum_sized_literal_width`](../../tests/ch6/test_illegal_enum_sized_literal_width.sv) | A sized literal that sets an enum value must have the width of the base type | 6.19 | Icarus Verilog 13.0 | illegal design |
| [`test_illegal_enum_value_out_of_range`](../../tests/ch6/test_illegal_enum_value_out_of_range.sv) | An enum value cannot lie outside the range of the base type | 6.19 | Icarus Verilog 13.0 | illegal design |
| [`test_enum_descending_names_and_wrap`](../../tests/ch6/test_enum_descending_names_and_wrap.sv) | Descending enum name ranges preserve declaration order for first last num and prev | 6.19.1 6.19.2 6.19.5.1 6.19.5.2 6.19.5.4 6.19.5.5 6.19.5.7 | Icarus Verilog 13.0 |  |
| [`test_enum_named_ranges`](../../tests/ch6/test_enum_named_ranges.sv) | In an enumeration, name[N] generates N names numbered from 0 and name[N:M] the names numbered from N to M, counting up or down, each taking consecutive values, starting from an assigned constant if there is one | 6.19.2 6.19.1 6.19.5 | Icarus Verilog 13.0 |  |
| [`test_illegal_enum_from_int`](../../tests/ch6/test_illegal_enum_from_int.sv) | An int value cannot be assigned to an enum variable without a cast | 6.19.3 | Icarus Verilog 13.0 | illegal design |
| [`test_illegal_enum_from_other_enum`](../../tests/ch6/test_illegal_enum_from_other_enum.sv) | A member of one enum type cannot be assigned to a variable of another enum type | 6.19.3 | Icarus Verilog 13.0 | illegal design |
| [`test_enum_comprehensive`](../../tests/ch6/test_enum_comprehensive.sv) | Enum methods first, last, num, name, next and prev, with wrap-around | 6.19.5 | Icarus Verilog 13.0 |  |
| [`test_enum_edge`](../../tests/ch6/test_enum_edge.sv) | Enum edge cases | 6.19.5 6.19.4 | Icarus Verilog 13.0 |  |
| [`test_enum_first_last`](../../tests/ch6/test_enum_first_last.sv) | Test enum first/last | 6.19.5 | Icarus Verilog 13.0 |  |
| [`test_enum_method_edge`](../../tests/ch6/test_enum_method_edge.sv) | Enum methods first, last, num, next, prev and name on contiguous, non-contiguous, single-member and sparse enums | 6.19.5 | Icarus Verilog 13.0 |  |
| [`test_enum_methods`](../../tests/ch6/test_enum_methods.sv) | Test for enum extension methods | 6.19.5 | Icarus Verilog 13.0 |  |
| [`test_enum_methods_2`](../../tests/ch6/test_enum_methods_2.sv) | Enum Methods Tests | 6.19.5 | Icarus Verilog 13.0 |  |
| [`test_enum_methods_name_num`](../../tests/ch6/test_enum_methods_name_num.sv) | Enumerated types | 6.19.5 | Icarus Verilog 13.0 |  |
| [`test_enum_methods_navigation`](../../tests/ch6/test_enum_methods_navigation.sv) | Enumerated types | 6.19.5 | Icarus Verilog 13.0 |  |
| [`test_enum_non_sequential`](../../tests/ch6/test_enum_non_sequential.sv) | Enum methods on an enum whose values are not consecutive | 6.19.5 | Icarus Verilog 13.0 |  |
| [`test_enum_ops_2`](../../tests/ch6/test_enum_ops_2.sv) | Enum next(), prev() and name() | 6.19.5 | Icarus Verilog 13.0 |  |
| [`test_enum_xz_member_methods`](../../tests/ch6/test_enum_xz_member_methods.sv) | Enumeration methods of a 4-state enumeration that has a member with an x bit | 6.19.5 6.19 | Icarus Verilog 13.0 | x/z |
| [`test_enum_first_last_num`](../../tests/ch6/test_enum_first_last_num.sv) | first() and last() return the first and last members of an enumeration in declaration order, whatever their values, and num() the number of members | 6.19.5.1 6.19.5.2 6.19.5.5 6.19.5.7 6.19.5.3 | Icarus Verilog 13.0 |  |
| [`test_enum_next_prev`](../../tests/ch6/test_enum_next_prev.sv) | Test enum next/prev | 6.19.5.3 6.19.5.4 | Icarus Verilog 13.0 |  |
| [`test_enum_name`](../../tests/ch6/test_enum_name.sv) | Test enum name | 6.19.5.6 | Icarus Verilog 13.0 |  |
| [`test_enum_name_2`](../../tests/ch6/test_enum_name_2.sv) | The enum name() method | 6.19.5.6 | Icarus Verilog 13.0 |  |
| [`test_enum_wider_than_64_bits_name`](../../tests/ch6/test_enum_wider_than_64_bits_name.sv) | The name() method of an enum whose base type is wider than 64 bits returns the name of the member | 6.19.5.6 6.19 | standard only |  |
| [`test_constant_edge_cases`](../../tests/ch6/test_constant_edge_cases.sv) | Constant edge cases | 6.20 | Icarus Verilog 13.0 |  |
| [`test_param`](../../tests/ch6/test_param.sv) | Test for parameters | 6.20 | Icarus Verilog 13.0 |  |
| [`test_param_expr`](../../tests/ch6/test_param_expr.sv) | Parameter Expression Tests | 6.20 | Icarus Verilog 13.0 |  |
| [`test_param_local`](../../tests/ch6/test_param_local.sv) | Test parameters and local params | 6.20 | Icarus Verilog 13.0 |  |
| [`test_param_value`](../../tests/ch6/test_param_value.sv) | Parameter Value Tests | 6.20 | Icarus Verilog 13.0 |  |
| [`test_parameter_advanced`](../../tests/ch6/test_parameter_advanced.sv) | Advanced Parameter Tests | 6.20 23.10.2.2 | Icarus Verilog 13.0 |  |
| [`test_parameter_types`](../../tests/ch6/test_parameter_types.sv) | Parameter Types Tests | 6.20 | Icarus Verilog 13.0 |  |
| [`test_param_constant_expr`](../../tests/ch6/test_param_constant_expr.sv) | Parameters and localparams defined by constant expressions | 6.20.1 6.20.4 11.2.1 | Verilator 5.052 |  |
| [`test_generate_expr`](../../tests/ch6/test_generate_expr.sv) | Parameter expressions used in a range and a generate condition | 6.20.2 27.5 | Icarus Verilog 13.0 |  |
| [`test_generate_localparam_in_port_index`](../../tests/ch6/test_generate_localparam_in_port_index.sv) | A localparam of a loop generate block keeps its declared width when it is used in the index of a port connection | 6.20.2 27.4 23.3.3 | Icarus Verilog 13.0 |  |
| [`test_param_basic_edge_cases`](../../tests/ch6/test_param_basic_edge_cases.sv) | Untyped, typed and string parameters used in expressions and a range | 6.20.2 | Icarus Verilog 13.0 |  |
| [`test_param_value_2`](../../tests/ch6/test_param_value_2.sv) | Value parameters | 6.20.2 23.10 | Icarus Verilog 13.0 |  |
| [`test_parameter_edge_cases`](../../tests/ch6/test_parameter_edge_cases.sv) | Parameters, localparams and overridden instance parameters, checked through outputs | 6.20.2 6.20.4 23.10 | Icarus Verilog 13.0 |  |
| [`test_parameter_override_types`](../../tests/ch6/test_parameter_override_types.sv) | Value, string, real and type parameters with defaults and overrides | 6.20.2 6.20.3 23.10 | Icarus Verilog 13.0 |  |
| [`test_parameters_edge_cases`](../../tests/ch6/test_parameters_edge_cases.sv) | Localparams and overridden instance parameters | 6.20.2 6.20.4 23.10 | Icarus Verilog 13.0 |  |
| [`test_untyped_parameter_width_from_override`](../../tests/ch6/test_untyped_parameter_width_from_override.sv) | A parameter with no type or range takes the width of its overriding value | 6.20.2 23.10.2.1 23.10.2.2 | Icarus Verilog 13.0 |  |
| [`test_generate_string_localparam`](../../tests/ch6/test_generate_string_localparam.sv) | Test: Generate block string localparam access | 6.20.4 27.5 | Icarus Verilog 13.0 |  |
| [`test_illegal_localparam_defparam`](../../tests/ch6/test_illegal_localparam_defparam.sv) | A defparam statement cannot change a local parameter | 6.20.4 23.10.1 | Icarus Verilog 13.0 | illegal design |
| [`test_illegal_localparam_instance_override`](../../tests/ch6/test_illegal_localparam_instance_override.sv) | A parameter value assignment of an instance cannot name a local parameter | 6.20.4 23.10.2 | Icarus Verilog 13.0 | illegal design |
| [`test_localparam`](../../tests/ch6/test_localparam.sv) | Test: Localparam with expressions | 6.20.4 6.20.3 20.8.1 | Verilator 5.052 |  |
| [`test_localparam_edge_cases`](../../tests/ch6/test_localparam_edge_cases.sv) | Test: Localparam edge cases | 6.20.4 | Icarus Verilog 13.0 |  |
| [`test_localparam_from_parameters`](../../tests/ch6/test_localparam_from_parameters.sv) | Localparams computed from parameters differ per instance and are read hierarchically | 6.20.4 23.10 23.6 | Icarus Verilog 13.0 |  |
| [`test_localparam_ops_edge_cases`](../../tests/ch6/test_localparam_ops_edge_cases.sv) | Test: Localparam operations edge cases | 6.20.4 | Icarus Verilog 13.0 |  |
| [`test_param_local_2`](../../tests/ch6/test_param_local_2.sv) | Test: Localparam usage | 6.20.4 6.20.1 | Verilator 5.052 |  |
| [`test_illegal_parameter_from_specparam`](../../tests/ch6/test_illegal_parameter_from_specparam.sv) | A parameter cannot be given a value that uses a specify parameter | 6.20.5 | Verilator 5.052 | illegal design |
| [`test_specify_specparam_delays`](../../tests/ch6/test_specify_specparam_delays.sv) | Path delays can be given by specify parameters, declared in the specify block or in the module before use, also as expressions of other specify parameters | 6.20.5 30.3 30.5.1 | Icarus Verilog 13.0 |  |
| [`test_specparam_edge_cases`](../../tests/ch6/test_specparam_edge_cases.sv) | specparam values used in expressions in the module body | 6.20.5 | Icarus Verilog 13.0 |  |
| [`test_const_edge_cases`](../../tests/ch6/test_const_edge_cases.sv) | Const variables edge cases | 6.20.6 6.21 | Icarus Verilog 13.0 | x/z |
| [`test_const_ops_edge_cases`](../../tests/ch6/test_const_ops_edge_cases.sv) | Test: Const operations edge cases | 6.20.6 6.21 | Icarus Verilog 13.0 |  |
| [`test_illegal_const_assigned`](../../tests/ch6/test_illegal_const_assigned.sv) | A const variable cannot be assigned after its declaration | 6.20.6 | Icarus Verilog 13.0 | illegal design |
| [`test_dollar_parameter_unbounded`](../../tests/ch6/test_dollar_parameter_unbounded.sv) | $ can be the value of a parameter, which $isunbounded then reports, also through another parameter, and $ stands for the open end of a value range and the last element of a queue | 6.20.7 20.6.3 11.4.13 7.10.1 | Verilator 5.052 |  |
| [`test_unbounded_queue_tail_after_resize`](../../tests/ch6/test_unbounded_queue_tail_after_resize.sv) | The dollar queue index tracks the new last element after pushes and pops | 6.20.7 | Verilator 5.052 |  |
| [`test_automatic_var`](../../tests/ch6/test_automatic_var.sv) | Test automatic variables | 6.21 13.4.2 | Icarus Verilog 13.0 |  |
| [`test_automatic_variable_in_static_subroutine`](../../tests/ch6/test_automatic_variable_in_static_subroutine.sv) | An automatic variable in a static function or task is initialized again on every call, while a static one keeps its value | 6.21 13.3.1 13.4.2 | Verilator 5.052 |  |
| [`test_illegal_automatic_variable_nonblocking`](../../tests/ch6/test_illegal_automatic_variable_nonblocking.sv) | An automatic variable cannot be written with a nonblocking assignment | 6.21 10.4.2 | Verilator 5.052 | illegal design |
| [`test_illegal_dynamic_array_element_continuous`](../../tests/ch6/test_illegal_dynamic_array_element_continuous.sv) | An element of a dynamic array cannot be driven by a continuous assignment | 6.21 7.5 10.3 | Verilator 5.052 | illegal design |
| [`test_local_scope`](../../tests/ch6/test_local_scope.sv) | Local Scope Tests | 6.21 | Icarus Verilog 13.0 |  |
| [`test_local_scope_edge_cases`](../../tests/ch6/test_local_scope_edge_cases.sv) | Test: Local scope edge cases | 6.21 | Icarus Verilog 13.0 |  |
| [`test_local_static`](../../tests/ch6/test_local_static.sv) | A static variable in a function keeps its value between calls | 6.21 13.4.2 | Icarus Verilog 13.0 |  |
| [`test_local_var_edge_cases_2`](../../tests/ch6/test_local_var_edge_cases_2.sv) | Test: Local variable edge cases | 6.21 | Icarus Verilog 13.0 |  |
| [`test_local_var_scope`](../../tests/ch6/test_local_var_scope.sv) | Block, function and task local variables, static and automatic | 6.21 13.4.2 | Icarus Verilog 13.0 |  |
| [`test_module_automatic_lifetime`](../../tests/ch6/test_module_automatic_lifetime.sv) | In a module declared automatic, variables of its tasks and functions are automatic by default and start again on each call, except those declared static, while module-level variables stay static; in an ordinary module they are static | 6.21 6.8 13.3.1 | Verilator 5.052 |  |
| [`test_scope_resolution_edge_cases`](../../tests/ch6/test_scope_resolution_edge_cases.sv) | Module, block and nested block variables, and a name hidden by an inner block | 6.21 | Icarus Verilog 13.0 |  |
| [`test_static_initializer_runs_once`](../../tests/ch6/test_static_initializer_runs_once.sv) | The initializer of a static variable declared in a procedural block runs once before time 0, not on each entry to the block | 6.21 6.8 | Icarus Verilog 13.0 |  |
| [`test_static_var`](../../tests/ch6/test_static_var.sv) | Static and Automatic Variable Tests | 6.21 13.4.2 | Icarus Verilog 13.0 |  |
| [`test_static_var_edge_cases`](../../tests/ch6/test_static_var_edge_cases.sv) | Module variables keep their values across statements | 6.21 | Icarus Verilog 13.0 |  |
| [`test_static_var_edge_cases_2`](../../tests/ch6/test_static_var_edge_cases_2.sv) | Static variables edge cases | 6.21 13.4.2 | Verilator 5.052 |  |
| [`test_static_variable_of_block_not_yet_run`](../../tests/ch6/test_static_variable_of_block_not_yet_run.sv) | A static variable of a named block exists before the block first runs and can be written through its hierarchical name | 6.21 23.6 9.3.4 | Icarus Verilog 13.0 |  |
| [`test_variables_and_subroutine_calls`](../../tests/ch6/test_variables_and_subroutine_calls.sv) | Module variables, block variables, and function and task calls | 6.21 13.3 13.4 | Icarus Verilog 13.0 |  |
| [`test_illegal_anonymous_struct_not_equivalent`](../../tests/ch6/test_illegal_anonymous_struct_not_equivalent.sv) | Anonymous unpacked structures from different declarations are not equivalent, so one cannot be assigned to the other | 6.22.2 6.22.3 | standard only | illegal design |
| [`test_type_equivalent_arrays`](../../tests/ch6/test_type_equivalent_arrays.sv) | Unpacked arrays whose element types are equivalent, such as packed types of the same size, state and signedness, can be assigned to each other whatever their ranges, element by element from the left | 6.22.2 7.6 7.4.2 | Verilator 5.052 |  |
| [`test_type_assignment_cast_compatible`](../../tests/ch6/test_type_assignment_cast_compatible.sv) | Assignment-compatible types convert implicitly, an enum to an integer and between integral types with truncation or a real with rounding, while an integer becomes an enum only through a cast | 6.22.3 6.22.4 6.24.1 6.12.1 | Icarus Verilog 13.0 |  |
| [`test_enum_explicit_cast_and_failed_dynamic_cast`](../../tests/ch6/test_enum_explicit_cast_and_failed_dynamic_cast.sv) | An explicit enum cast permits an integral value and a failed dynamic cast leaves the destination unchanged | 6.22.4 | Verilator 5.052 |  |
| [`test_illegal_class_handle_to_int`](../../tests/ch6/test_illegal_class_handle_to_int.sv) | A class handle is type incompatible with every other type and cannot be assigned to an int | 6.22.5 | Icarus Verilog 13.0 | illegal design |
| [`test_illegal_handle_to_real_cast`](../../tests/ch6/test_illegal_handle_to_real_cast.sv) | A class handle cannot be converted to a real even by an explicit cast | 6.22.5 | Icarus Verilog 13.0 | illegal design |
| [`test_nettype_rename_matches`](../../tests/ch6/test_nettype_rename_matches.sv) | A nettype declared as a new name for a user-defined nettype matches it, so a net of the new name connects to a port of the original nettype | 6.22.6 6.6.7 23.3.3 | standard only |  |
| [`test_type_operator_matching_types`](../../tests/ch6/test_type_operator_matching_types.sv) | type(a) == type(b) is true for matching types such as byte and bit signed [7:0], in procedural code as in a constant | 6.23 6.22.1 | standard only |  |
| [`test_cast_edge_cases`](../../tests/ch6/test_cast_edge_cases.sv) | Cast edge cases | 6.24 | Icarus Verilog 13.0 |  |
| [`test_cast_ops_edge_cases`](../../tests/ch6/test_cast_ops_edge_cases.sv) | Test: Cast operations edge cases | 6.24 | Icarus Verilog 13.0 |  |
| [`test_type_cast`](../../tests/ch6/test_type_cast.sv) | Test for type casting | 6.24 6.12.1 | Icarus Verilog 13.0 |  |
| [`test_type_cast_advanced`](../../tests/ch6/test_type_cast_advanced.sv) | Advanced Type Casting Tests | 6.24 | Icarus Verilog 13.0 |  |
| [`test_type_cast_int`](../../tests/ch6/test_type_cast_int.sv) | Test for integer type casting | 6.24 | Icarus Verilog 13.0 |  |
| [`test_type_cast_real`](../../tests/ch6/test_type_cast_real.sv) | Test for real type casting | 6.24 | Icarus Verilog 13.0 |  |
| [`test_type_casting_edge_cases`](../../tests/ch6/test_type_casting_edge_cases.sv) | Type casting edge cases | 6.24 | Icarus Verilog 13.0 |  |
| [`test_type_casts_2`](../../tests/ch6/test_type_casts_2.sv) | Test type casts | 6.24 | Icarus Verilog 13.0 |  |
| [`test_unsigned_cast`](../../tests/ch6/test_unsigned_cast.sv) | Test unsigned cast | 6.24 | Icarus Verilog 13.0 |  |
| [`test_cast_byte`](../../tests/ch6/test_cast_byte.sv) | Byte type casts | 6.24.1 6.11 | Icarus Verilog 13.0 |  |
| [`test_cast_const`](../../tests/ch6/test_cast_const.sv) | Const cast operations | 6.24.1 | Icarus Verilog 13.0 |  |
| [`test_cast_corner`](../../tests/ch6/test_cast_corner.sv) | Tests static and dynamic casts, type conversions | 6.24.1 6.24.2 6.12.1 6.19.4 | Verilator 5.052 |  |
| [`test_cast_expr`](../../tests/ch6/test_cast_expr.sv) | Cast Expression Tests | 6.24.1 6.12.1 | Icarus Verilog 13.0 |  |
| [`test_cast_expr_2`](../../tests/ch6/test_cast_expr_2.sv) | Casts between int, real, vector, enum and user-defined types | 6.24.1 6.12.1 | Icarus Verilog 13.0 |  |
| [`test_cast_ext`](../../tests/ch6/test_cast_ext.sv) | Test 1: int to shortint | 6.24.1 6.12.1 11.7 | Icarus Verilog 13.0 |  |
| [`test_cast_logic`](../../tests/ch6/test_cast_logic.sv) | Logic type casts | 6.24.1 | Icarus Verilog 13.0 |  |
| [`test_cast_longint`](../../tests/ch6/test_cast_longint.sv) | Longint type casts | 6.24.1 6.11 | Icarus Verilog 13.0 |  |
| [`test_cast_operations`](../../tests/ch6/test_cast_operations.sv) | Cast Operations Tests | 6.24.1 6.12.1 | Icarus Verilog 13.0 |  |
| [`test_cast_real`](../../tests/ch6/test_cast_real.sv) | Real type casts | 6.24.1 6.12.1 | Icarus Verilog 13.0 |  |
| [`test_cast_real_2`](../../tests/ch6/test_cast_real_2.sv) | Casts of integral and shortreal values to real | 6.24.1 6.12 | Icarus Verilog 13.0 |  |
| [`test_cast_real_basic`](../../tests/ch6/test_cast_real_basic.sv) | Test real cast | 6.24.1 6.12.1 | Icarus Verilog 13.0 |  |
| [`test_cast_shortint`](../../tests/ch6/test_cast_shortint.sv) | Shortint type casts | 6.24.1 6.11 | Icarus Verilog 13.0 |  |
| [`test_cast_signed_2`](../../tests/ch6/test_cast_signed_2.sv) | signed' and unsigned' casts, $signed and $unsigned | 6.24.1 11.7 | Icarus Verilog 13.0 |  |
| [`test_cast_size`](../../tests/ch6/test_cast_size.sv) | Test for size casts | 6.24.1 | Icarus Verilog 13.0 |  |
| [`test_cast_string_literal_to_narrower_type`](../../tests/ch6/test_cast_string_literal_to_narrower_type.sv) | Casting a string literal to a narrower integral type keeps its rightmost characters | 6.24.1 5.9 | Icarus Verilog 13.0 |  |
| [`test_cast_to_enum_truncates`](../../tests/ch6/test_cast_to_enum_truncates.sv) | A cast to an enumerated type converts the value to the width of the base type, also when the result is not a member | 6.24.1 6.19.4 | Verilator 5.052 |  |
| [`test_signed_cast`](../../tests/ch6/test_signed_cast.sv) | Test signed cast | 6.24.1 | Icarus Verilog 13.0 |  |
| [`test_type_casting`](../../tests/ch6/test_type_casting.sv) | Corner Case: Type Casting | 6.24.1 6.12.1 10.7 11.7 | Icarus Verilog 13.0 |  |
| [`test_cast_dynamic_array`](../../tests/ch6/test_cast_dynamic_array.sv) | $cast to array elements | 6.24.2 7.5 7.10 | Verilator 5.052 |  |
| [`test_cast_function`](../../tests/ch6/test_cast_function.sv) | Test for IEEE 1800-2023 §6.24.2: $cast system function | 6.24.2 8.16 | Verilator 5.052 |  |
| [`test_cast_packed_struct_member`](../../tests/ch6/test_cast_packed_struct_member.sv) | , Section 7.2 - $cast with packed struct member access | 6.24.2 7.2.1 | Verilator 5.052 |  |
| [`test_member_access_cast`](../../tests/ch6/test_member_access_cast.sv) | Test $cast with member access expressions | 6.24.2 8.16 | Verilator 5.052 |  |
| [`test_bitstream_array_to_packed_order`](../../tests/ch6/test_bitstream_array_to_packed_order.sv) | Bit stream casts place the first unpacked element at the most significant end | 6.24.3 | standard only |  |
| [`test_parameterized_data_types`](../../tests/ch6/test_parameterized_data_types.sv) | Type definitions in a parameterized virtual class give parameterized data types, specialized by the class parameters where they are used through the class scope operator | 6.25 8.25 8.23 | Verilator 5.052 |  |
| [`test_parameterized_typedef_specializations`](../../tests/ch6/test_parameterized_typedef_specializations.sv) | Class parameter specializations create different typedef widths and expose explicit default parameters | 6.25 8.25.1 | Verilator 5.052 |  |

## Generated by `generators/wide_paths.py`

7 tests; see "Generated tests" in the suite's README.

| Test | What it checks | Clauses | Expected output recorded with | Notes |
| --- | --- | --- | --- | --- |
| [`test_gen_wide_values_w127`](../../tests/gen/ch6/test_gen_wide_values_w127.sv) | Assignments of 127-bit values to wider, narrower and 2-state targets | 6.11.2 10.7 21.2.1.3 | Icarus Verilog 13.0 | x/z |
| [`test_gen_wide_values_w128`](../../tests/gen/ch6/test_gen_wide_values_w128.sv) | Assignments of 128-bit values to wider, narrower and 2-state targets | 6.11.2 10.7 21.2.1.3 | Icarus Verilog 13.0 | x/z |
| [`test_gen_wide_values_w129`](../../tests/gen/ch6/test_gen_wide_values_w129.sv) | Assignments of 129-bit values to wider, narrower and 2-state targets | 6.11.2 10.7 21.2.1.3 | Icarus Verilog 13.0 | x/z |
| [`test_gen_wide_values_w200`](../../tests/gen/ch6/test_gen_wide_values_w200.sv) | Assignments of 200-bit values to wider, narrower and 2-state targets | 6.11.2 10.7 21.2.1.3 | Icarus Verilog 13.0 | x/z |
| [`test_gen_wide_values_w63`](../../tests/gen/ch6/test_gen_wide_values_w63.sv) | Assignments of 63-bit values to wider, narrower and 2-state targets | 6.11.2 10.7 21.2.1.3 | Icarus Verilog 13.0 | x/z |
| [`test_gen_wide_values_w64`](../../tests/gen/ch6/test_gen_wide_values_w64.sv) | Assignments of 64-bit values to wider, narrower and 2-state targets | 6.11.2 10.7 21.2.1.3 | Icarus Verilog 13.0 | x/z |
| [`test_gen_wide_values_w65`](../../tests/gen/ch6/test_gen_wide_values_w65.sv) | Assignments of 65-bit values to wider, narrower and 2-state targets | 6.11.2 10.7 21.2.1.3 | Icarus Verilog 13.0 | x/z |
