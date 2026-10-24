# Clause 7: Aggregate data types

[All chapters](README.md). 372 tests, 14 of them generated. This page is written by `tools/suite_catalog.py` from the metadata of the tests; edit the tests, not this page.

| Test | What it checks | Clauses | Expected output recorded with | Notes |
| --- | --- | --- | --- | --- |
| [`test_assign_struct`](../../tests/ch7/test_assign_struct.sv) | Test for struct assignment | 7.2 10.9.2 | Verilator 5.052 |  |
| [`test_assignment_forms`](../../tests/ch7/test_assignment_forms.sv) | Assignment forms: blocking, nonblocking, force/release, concatenation and part-select targets | 7.2 7.3 7.4 9.2.2.4 10.4.2 10.6.2 11.4.12 11.5.1 | Icarus Verilog 13.0 |  |
| [`test_ct_struct_class_pairs`](../../tests/ch7/test_ct_struct_class_pairs.sv) | T1: ClassInstance member access and modification | 7.2 7.3 8.4 | Verilator 5.052 |  |
| [`test_edge_struct_member_access`](../../tests/ch7/test_edge_struct_member_access.sv) | Structures | 7.2 7.2.2 | Verilator 5.052 |  |
| [`test_expr_struct`](../../tests/ch7/test_expr_struct.sv) | Struct expressions test | 7.2 7.2.1 10.9.2 | Verilator 5.052 |  |
| [`test_ieee1800_2023_struct_union_corner`](../../tests/ch7/test_ieee1800_2023_struct_union_corner.sv) | Struct/Union Corner Cases | 7.2 7.2.1 7.3 7.3.1 10.9.2 | Verilator 5.052 |  |
| [`test_member_access`](../../tests/ch7/test_member_access.sv) | Test for member access | 7.2 7.4 | Icarus Verilog 13.0 |  |
| [`test_member_access_2`](../../tests/ch7/test_member_access_2.sv) | Class and struct member access patterns | 7.2 8.5 8.13 | Verilator 5.052 |  |
| [`test_member_access_3`](../../tests/ch7/test_member_access_3.sv) | Test: Struct/class member access | 7.2 8.4 8.5 | Verilator 5.052 |  |
| [`test_member_access_advanced`](../../tests/ch7/test_member_access_advanced.sv) | Test for advanced member access patterns | 7.2 7.3 8.5 | Verilator 5.052 |  |
| [`test_member_access_patterns`](../../tests/ch7/test_member_access_patterns.sv) | Member Access Patterns Tests | 7.2 7.4 7.10 6.16 | Icarus Verilog 13.0 |  |
| [`test_member_access_struct_array`](../../tests/ch7/test_member_access_struct_array.sv) | Member access of an unpacked struct and elements of a fixed-size array | 7.2 7.4 | Verilator 5.052 |  |
| [`test_member_ext`](../../tests/ch7/test_member_ext.sv) | Test 1: Packed struct write | 7.2 8.4 | Verilator 5.052 |  |
| [`test_member_struct`](../../tests/ch7/test_member_struct.sv) | Test struct member access corner cases | 7.2 7.2.1 | Verilator 5.052 |  |
| [`test_operator_member`](../../tests/ch7/test_operator_member.sv) | Member access operators test | 7.2 8.5 8.6 | Icarus Verilog 13.0 |  |
| [`test_struct_access`](../../tests/ch7/test_struct_access.sv) | Structures | 7.2 7.2.1 10.9.2 | Verilator 5.052 |  |
| [`test_struct_and_class_members`](../../tests/ch7/test_struct_and_class_members.sv) | Packed struct members, and class properties and methods | 7.2 8.5 8.6 | Icarus Verilog 13.0 |  |
| [`test_struct_assign`](../../tests/ch7/test_struct_assign.sv) | Test: Struct field assignment | 7.2 10.9.2 | Verilator 5.052 |  |
| [`test_struct_basic`](../../tests/ch7/test_struct_basic.sv) | Struct Basic Tests | 7.2 | Verilator 5.052 |  |
| [`test_struct_basic_edge_cases`](../../tests/ch7/test_struct_basic_edge_cases.sv) | Struct basic edge cases | 7.2 10.9.2 11.2.2 | Verilator 5.052 |  |
| [`test_struct_corner`](../../tests/ch7/test_struct_corner.sv) | Tests packed/unpacked structs, nested structs, struct operations | 7.2 7.2.1 7.2.2 10.9.2 | Verilator 5.052 |  |
| [`test_struct_edge`](../../tests/ch7/test_struct_edge.sv) | Test: Struct operation edge cases | 7.2 7.2.1 11.4.5 | Verilator 5.052 |  |
| [`test_struct_literal`](../../tests/ch7/test_struct_literal.sv) | Struct Literal Tests | 7.2 10.9.2 | Verilator 5.052 |  |
| [`test_struct_member`](../../tests/ch7/test_struct_member.sv) | Test struct member access | 7.2 | Verilator 5.052 |  |
| [`test_struct_member_access`](../../tests/ch7/test_struct_member_access.sv) | Test for struct member access | 7.2 7.2.1 7.4 | Verilator 5.052 |  |
| [`test_struct_ops`](../../tests/ch7/test_struct_ops.sv) | Unpacked struct member assignment, copy and assignment pattern | 7.2 10.9.2 | Verilator 5.052 |  |
| [`test_struct_ops_2`](../../tests/ch7/test_struct_ops_2.sv) | Test for struct operations | 7.2 7.2.1 10.9.2 | Verilator 5.052 |  |
| [`test_struct_ops_edge_cases`](../../tests/ch7/test_struct_ops_edge_cases.sv) | Test: Struct operations edge cases | 7.2 7.2.1 | Verilator 5.052 |  |
| [`test_struct_types_edge_cases`](../../tests/ch7/test_struct_types_edge_cases.sv) | Test: Struct types edge cases | 7.2 7.2.1 10.9.2 | Verilator 5.052 |  |
| [`test_struct_union_edge_cases`](../../tests/ch7/test_struct_union_edge_cases.sv) | Struct and union edge cases: packed and unpacked structs, unions and nesting | 7.2 7.2.1 7.3 7.3.1 | Verilator 5.052 |  |
| [`test_structs`](../../tests/ch7/test_structs.sv) | Chapter 7: Aggregate data types | 7.2 7.2.1 | Verilator 5.052 |  |
| [`test_structs_edge_cases`](../../tests/ch7/test_structs_edge_cases.sv) | Test: Structs edge cases | 7.2 7.2.1 10.9.2 | Verilator 5.052 |  |
| [`test_unpacked_struct`](../../tests/ch7/test_unpacked_struct.sv) | Unpacked Struct Tests | 7.2 10.9.2 | Verilator 5.052 |  |
| [`test_cast_struct`](../../tests/ch7/test_cast_struct.sv) | Test for struct casts | 7.2.1 6.24.1 | Icarus Verilog 13.0 |  |
| [`test_illegal_packed_struct_real_member`](../../tests/ch7/test_illegal_packed_struct_real_member.sv) | A packed structure cannot have a real member | 7.2.1 6.12 | Icarus Verilog 13.0 | illegal design |
| [`test_illegal_packed_struct_unpacked_member`](../../tests/ch7/test_illegal_packed_struct_unpacked_member.sv) | A packed structure cannot have a member that is an unpacked array | 7.2.1 | Icarus Verilog 13.0 | illegal design |
| [`test_packed_array_member_access`](../../tests/ch7/test_packed_array_member_access.sv) | Member access of packed structs in an unpacked array | 7.2.1 7.4 | Verilator 5.052 |  |
| [`test_packed_struct`](../../tests/ch7/test_packed_struct.sv) | A packed struct assigned to and from a flat vector | 7.2.1 | Icarus Verilog 13.0 |  |
| [`test_packed_struct_assign`](../../tests/ch7/test_packed_struct_assign.sv) | Packed Structures | 7.2.1 10.9.2 | Icarus Verilog 13.0 |  |
| [`test_packed_struct_deep_select`](../../tests/ch7/test_packed_struct_deep_select.sv) | Test: 4-level deep packed struct member + bit-range/bit-select write-back | 7.2.1 11.5.1 | Icarus Verilog 13.0 |  |
| [`test_packed_struct_edge_cases`](../../tests/ch7/test_packed_struct_edge_cases.sv) | Test: Packed struct edge cases | 7.2.1 10.9.2 | Icarus Verilog 13.0 |  |
| [`test_packed_struct_member_range_sign`](../../tests/ch7/test_packed_struct_member_range_sign.sv) | A member of a packed structure keeps its declared range and signedness when it is selected | 7.2.1 6.9.1 6.24.1 | Icarus Verilog 13.0 |  |
| [`test_packed_structs`](../../tests/ch7/test_packed_structs.sv) | Test packed structures | 7.2.1 | Icarus Verilog 13.0 |  |
| [`test_struct_packed`](../../tests/ch7/test_struct_packed.sv) | Test packed structs | 7.2.1 10.9.2 | Icarus Verilog 13.0 |  |
| [`test_struct_packed_2`](../../tests/ch7/test_struct_packed_2.sv) | Packed struct bit operations | 7.2.1 | Icarus Verilog 13.0 |  |
| [`test_struct_union`](../../tests/ch7/test_struct_union.sv) | Packed Struct (§7.2) | 7.2.1 7.3.1 | Icarus Verilog 13.0 |  |
| [`test_illegal_hard_packed_union_sizes`](../../tests/ch7/test_illegal_hard_packed_union_sizes.sv) | The members of a packed union without soft have to be of the same size | 7.3.1 | Icarus Verilog 13.0 | illegal design |
| [`test_illegal_packed_union_real_member`](../../tests/ch7/test_illegal_packed_union_real_member.sv) | a packed union cannot have a member of a non-integral type such as real | 7.3.1 6.11.1 | Icarus Verilog 13.0 | illegal design |
| [`test_packed_nested_member_write`](../../tests/ch7/test_packed_nested_member_write.sv) | 7.3 Packed Nested Member Write Test | 7.3.1 7.2.1 | Icarus Verilog 13.0 |  |
| [`test_packed_union`](../../tests/ch7/test_packed_union.sv) | Test packed union | 7.3.1 | Icarus Verilog 13.0 |  |
| [`test_packed_union_mixed_two_four_state`](../../tests/ch7/test_packed_union_mixed_two_four_state.sv) | a packed union with a 2-state and a 4-state member is 4-state as a whole; reading the 2-state member turns x and z into 0, and writing it stores known bits | 7.3.1 6.11.2 6.8 | standard only | x/z |
| [`test_packed_union_struct_member`](../../tests/ch7/test_packed_union_struct_member.sv) | Packed union with a struct member: reading and writing through both views | 7.3.1 | Icarus Verilog 13.0 |  |
| [`test_packed_union_whole_vector_sign_select`](../../tests/ch7/test_packed_union_whole_vector_sign_select.sv) | a packed union used as a primary is one vector whose arithmetic follows its signedness (unsigned by default), and its bits can be selected as a [n-1:0] vector | 7.3.1 | Icarus Verilog 13.0 |  |
| [`test_soft_packed_union`](../../tests/ch7/test_soft_packed_union.sv) | The members of a soft packed union can have different sizes; the union is as wide as the largest, and each member lies in its low bits | 7.3.1 7.2.1 | Verilator 5.052 |  |
| [`test_soft_packed_union_nested_layout`](../../tests/ch7/test_soft_packed_union_nested_layout.sv) | the size and right-justified layout of a soft packed union apply again to a soft packed union nested in it, directly and through a packed structure | 7.3.1 7.2.1 | Verilator 5.052 |  |
| [`test_union_basic_edge_cases`](../../tests/ch7/test_union_basic_edge_cases.sv) | Union basic edge cases | 7.3.1 | Icarus Verilog 13.0 |  |
| [`test_union_edge`](../../tests/ch7/test_union_edge.sv) | Test: Union operation edge cases | 7.3.1 | Icarus Verilog 13.0 |  |
| [`test_union_ops`](../../tests/ch7/test_union_ops.sv) | A packed union of a word and a struct of two halves | 7.3.1 | Icarus Verilog 13.0 |  |
| [`test_union_types`](../../tests/ch7/test_union_types.sv) | Test union types | 7.3.1 | Icarus Verilog 13.0 |  |
| [`test_union_types_edge_cases`](../../tests/ch7/test_union_types_edge_cases.sv) | Test: Union types edge cases | 7.3.1 | Icarus Verilog 13.0 |  |
| [`test_tagged_union_dynamic_and_chandle_members`](../../tests/ch7/test_tagged_union_dynamic_and_chandle_members.sv) | an unpacked tagged union can have members of dynamic types (string, queue, dynamic and associative arrays, class handle) and of type chandle, which hold their values | 7.3.2 11.9 | standard only |  |
| [`test_tagged_union_packed`](../../tests/ch7/test_tagged_union_packed.sv) | a packed tagged union has the minimum number of tag bits for its members at the most significant end and each member right-justified, tagged union expressions set the tag and the member together, and the member of the current tag can be read and written with dot notation | 7.3.2 11.9 20.6.2 | standard only |  |
| [`test_tagged_union_packed_tag_width_layout`](../../tests/ch7/test_tagged_union_packed_tag_width_layout.sv) | a packed tagged union is as wide as the fewest tag bits that code its member names plus its widest member, with the tag in the top bits, each member in the low bits, and the same layout inside a nested tagged union | 7.3.2 11.9 20.6.2 | standard only |  |
| [`test_array_access`](../../tests/ch7/test_array_access.sv) | An unpacked array read with a variable index in always_comb | 7.4 9.2.2.2 | Icarus Verilog 13.0 |  |
| [`test_array_assign`](../../tests/ch7/test_array_assign.sv) | Assigning unpacked array elements, including 2-D, 3-D and packed element types | 7.4 | Icarus Verilog 13.0 |  |
| [`test_array_elem`](../../tests/ch7/test_array_elem.sv) | Array Element Access Tests | 7.4 10.9.1 | Icarus Verilog 13.0 |  |
| [`test_array_element_access`](../../tests/ch7/test_array_element_access.sv) | Writing and reading 1-D and 2-D unpacked array elements in loops | 7.4 | Icarus Verilog 13.0 |  |
| [`test_array_element_assign`](../../tests/ch7/test_array_element_assign.sv) | Test for array element assignment | 7.4 | Icarus Verilog 13.0 |  |
| [`test_array_index`](../../tests/ch7/test_array_index.sv) | Array Index Tests | 7.4 | Icarus Verilog 13.0 |  |
| [`test_array_index_basic`](../../tests/ch7/test_array_index_basic.sv) | Test array indexing | 7.4 | Icarus Verilog 13.0 |  |
| [`test_array_indexing`](../../tests/ch7/test_array_indexing.sv) | Test: Array element access [i] | 7.4 7.5 7.8 7.10 11.5.1 | Verilator 5.052 |  |
| [`test_array_init`](../../tests/ch7/test_array_init.sv) | Array Initialization Tests | 7.4 10.9.1 20.7 | Verilator 5.052 |  |
| [`test_array_loops_and_strings`](../../tests/ch7/test_array_loops_and_strings.sv) | Array loops, foreach, string length and concatenation | 7.4 12.7.3 6.16 | Icarus Verilog 13.0 |  |
| [`test_array_select`](../../tests/ch7/test_array_select.sv) | Test array selections | 7.4 11.5.1 | Icarus Verilog 13.0 |  |
| [`test_array_slicing_edge_cases`](../../tests/ch7/test_array_slicing_edge_cases.sv) | Test: Array slicing edge cases | 7.4 11.5.1 | Icarus Verilog 13.0 |  |
| [`test_assign_index`](../../tests/ch7/test_assign_index.sv) | Indexed assignments | 7.4 12.7.3 | Icarus Verilog 13.0 |  |
| [`test_mem`](../../tests/ch7/test_mem.sv) | Various array types | 7.4 7.5 7.8 7.10 | Verilator 5.052 |  |
| [`test_memory_array_ops`](../../tests/ch7/test_memory_array_ops.sv) | Tests various memory and array operations | 7.4 7.5 7.8 7.10 7.12 | Verilator 5.052 |  |
| [`test_memory_edge_cases`](../../tests/ch7/test_memory_edge_cases.sv) | Memory and array edge cases: initialization, bounds, dynamic arrays, queues and associative arrays | 7.4 7.5 7.8 7.10 | Verilator 5.052 |  |
| [`test_unpacked_types_edge_cases`](../../tests/ch7/test_unpacked_types_edge_cases.sv) | Test: Unpacked types edge cases | 7.4 7.4.2 7.2 | Verilator 5.052 |  |
| [`test_value_unpacked`](../../tests/ch7/test_value_unpacked.sv) | Test for unpacked array value operations | 7.4 7.6 11.2.2 | Verilator 5.052 |  |
| [`test_bit_select`](../../tests/ch7/test_bit_select.sv) | Bit-select and part-select | 7.4.1 11.5.1 | Icarus Verilog 13.0 |  |
| [`test_illegal_int_packed_dimension`](../../tests/ch7/test_illegal_int_packed_dimension.sv) | an integer type with a predefined width, here int, cannot be declared with packed array dimensions | 7.4.1 | Icarus Verilog 13.0 | illegal design |
| [`test_illegal_packed_array_of_real`](../../tests/ch7/test_illegal_packed_array_of_real.sv) | A packed array cannot have real elements | 7.4.1 6.12 | Icarus Verilog 13.0 | illegal design |
| [`test_illegal_packed_dimension_single_size`](../../tests/ch7/test_illegal_packed_dimension_single_size.sv) | a packed dimension needs a range with two bounds; a single size such as [8] is allowed only for unpacked dimensions | 7.4.1 7.4.2 | Verilator 5.052 | illegal design |
| [`test_integer_atom_types_match_vector_types`](../../tests/ch7/test_integer_atom_types_match_vector_types.sv) | each integer type with a predefined width n matches the packed vector type with the same state, sign and the single dimension [n-1:0], and no vector type that differs in one of them | 7.4.1 6.22.1 6.23 | standard only |  |
| [`test_mixed_packed`](../../tests/ch7/test_mixed_packed.sv) | Mixed packed/unpacked arrays | 7.4.1 7.4.2 7.4.5 | Icarus Verilog 13.0 |  |
| [`test_multidim_packed_vector`](../../tests/ch7/test_multidim_packed_vector.sv) | Two-dimensional packed vectors driven bit by bit from nested generate loops | 7.4.1 7.4.5 27.4 | Icarus Verilog 13.0 |  |
| [`test_packed_2d`](../../tests/ch7/test_packed_2d.sv) | 2D packed arrays | 7.4.1 | Icarus Verilog 13.0 |  |
| [`test_packed_3d`](../../tests/ch7/test_packed_3d.sv) | 3D packed arrays | 7.4.1 | Icarus Verilog 13.0 |  |
| [`test_packed_48bit_arithmetic_and_integer_selects`](../../tests/ch7/test_packed_48bit_arithmetic_and_integer_selects.sv) | a 48-bit packed vector does integer arithmetic at 48 bits, and the integer types with a predefined width can be selected from as if declared [n-1:0] | 7.4.1 7.4.5 | Icarus Verilog 13.0 |  |
| [`test_packed_arr`](../../tests/ch7/test_packed_arr.sv) | Packed Array Tests | 7.4.1 | Icarus Verilog 13.0 |  |
| [`test_packed_array`](../../tests/ch7/test_packed_array.sv) | Packed Array Tests | 7.4.1 7.2.1 | Icarus Verilog 13.0 |  |
| [`test_packed_array_2`](../../tests/ch7/test_packed_array_2.sv) | A packed array assigned to and from a flat vector | 7.4.1 | Icarus Verilog 13.0 |  |
| [`test_packed_array_access`](../../tests/ch7/test_packed_array_access.sv) | Packed Array Bit/Slice Access Test | 7.4.1 11.5.1 | Icarus Verilog 13.0 |  |
| [`test_packed_array_bitsel_write`](../../tests/ch7/test_packed_array_bitsel_write.sv) | Blocking and nonblocking writes to one bit of an element of a two-dimensional packed array | 7.4.1 7.4.5 11.5.1 10.4.2 | Icarus Verilog 13.0 |  |
| [`test_packed_array_dims`](../../tests/ch7/test_packed_array_dims.sv) | Packed array dimension index access test | 7.4.1 7.3.1 | Icarus Verilog 13.0 |  |
| [`test_packed_array_edge_cases`](../../tests/ch7/test_packed_array_edge_cases.sv) | Test: Packed array edge cases | 7.4.1 | Icarus Verilog 13.0 |  |
| [`test_packed_array_element_width`](../../tests/ch7/test_packed_array_element_width.sv) | Packed array element width test | 7.4.1 | Icarus Verilog 13.0 |  |
| [`test_packed_array_whole_element_part_sign`](../../tests/ch7/test_packed_array_whole_element_part_sign.sv) | a signed packed array is signed as a whole while its elements are unsigned unless their named type is signed, a part-select is unsigned, and signed on an unpacked array applies to its elements | 7.4.1 7.4.6 | Icarus Verilog 13.0 |  |
| [`test_packed_arrays`](../../tests/ch7/test_packed_arrays.sv) | Chapter 7: Aggregate data types | 7.4.1 7.4.2 | Icarus Verilog 13.0 |  |
| [`test_packed_assign`](../../tests/ch7/test_packed_assign.sv) | Test: Packed array/struct assignment | 7.4.1 7.2.1 | Verilator 5.052 |  |
| [`test_packed_basic`](../../tests/ch7/test_packed_basic.sv) | Packed Array Basic Tests | 7.4.1 | Icarus Verilog 13.0 |  |
| [`test_packed_vector_65536_bits`](../../tests/ch7/test_packed_vector_65536_bits.sv) | a packed array of 65536 bits, the least maximum size a tool has to allow, can be declared, selected at both ends and used in arithmetic over its full width | 7.4.1 | Icarus Verilog 13.0 |  |
| [`test_value_packed`](../../tests/ch7/test_value_packed.sv) | Test for packed value operations | 7.4.1 | Icarus Verilog 13.0 |  |
| [`test_widths_edge_cases`](../../tests/ch7/test_widths_edge_cases.sv) | Test: Bit widths edge cases | 7.4.1 10.7 | Icarus Verilog 13.0 |  |
| [`test_memory_array_access`](../../tests/ch7/test_memory_array_access.sv) | Memory (unpacked array) element access and copy | 7.4.2 7.4.4 | Icarus Verilog 13.0 |  |
| [`test_multidim_unpacked`](../../tests/ch7/test_multidim_unpacked.sv) | Unpacked arrays | 7.4.2 7.4.5 | Icarus Verilog 13.0 |  |
| [`test_net_array_elements_and_whole_array_assign`](../../tests/ch7/test_net_array_elements_and_whole_array_assign.sv) | elements of a net array are used as vector nets in continuous assignments, expressions and port connections, and a whole net array is assigned from a variable array and back, element by element from left to right | 7.4.2 7.6 | Verilator 5.052 |  |
| [`test_reg_memory`](../../tests/ch7/test_reg_memory.sv) | Reg array memory operations | 7.4.2 | Icarus Verilog 13.0 |  |
| [`test_unpack_arr`](../../tests/ch7/test_unpack_arr.sv) | Unpacked Array Tests | 7.4.2 | Icarus Verilog 13.0 |  |
| [`test_unpacked_2d`](../../tests/ch7/test_unpacked_2d.sv) | 2D unpacked arrays | 7.4.2 | Icarus Verilog 13.0 |  |
| [`test_unpacked_3d`](../../tests/ch7/test_unpacked_3d.sv) | 3D unpacked arrays | 7.4.2 | Icarus Verilog 13.0 |  |
| [`test_unpacked_array_16777216_elements`](../../tests/ch7/test_unpacked_array_16777216_elements.sv) | an unpacked array of 16777216 elements, the least maximum size a tool has to allow, can be declared and its first and last elements written and read | 7.4.2 | Icarus Verilog 13.0 |  |
| [`test_memory_descending_word_indices`](../../tests/ch7/test_memory_descending_word_indices.sv) | A memory with negative descending indices retains independently addressed packed words | 7.4.3 | Icarus Verilog 13.0 |  |
| [`test_memory_words`](../../tests/ch7/test_memory_words.sv) | A one-dimensional array of logic, bit or reg elements is a memory: each element is a word written and read by its address, and a part of a word can be selected after the address | 7.4.3 7.4.1 7.4.6 | Icarus Verilog 13.0 | x/z |
| [`test_copy_row_of_unpacked_struct_array`](../../tests/ch7/test_copy_row_of_unpacked_struct_array.sv) | A row of a two-dimensional array of unpacked structures is an array that can be read and written as a whole | 7.4.4 7.6 | Verilator 5.052 |  |
| [`test_multidim_typedef_stages_and_shared_declaration`](../../tests/ch7/test_multidim_typedef_stages_and_shared_declaration.sv) | packed and unpacked dimensions built in stages with typedef keep the dimensions of the typedef as the faster-varying ones, and the arrays of one comma-separated declaration share the data type and packed dimensions while their unpacked dimensions differ | 7.4.4 20.7 | Verilator 5.052 |  |
| [`test_array_index_wider_than_64_bits`](../../tests/ch7/test_array_index_wider_than_64_bits.sv) | An index of an unpacked array that is wider than 64 bits selects by its whole value | 7.4.5 11.4.10 | standard only |  |
| [`test_array_invalid_index_read_aggregates`](../../tests/ch7/test_array_invalid_index_read_aggregates.sv) | reading an unpacked array whose elements are queues, dynamic or associative arrays, fixed-size arrays, unpacked structures or unpacked unions with an invalid index gives an empty array, an array of default elements, a structure of default members (or their initial assignments) and the default of the first union member | 7.4.5 | standard only | x/z |
| [`test_array_invalid_index_read_chandle`](../../tests/ch7/test_array_invalid_index_read_chandle.sv) | reading an unpacked array of chandles that C code has set to non-null pointers with an out-of-bounds index or an index with an x bit gives null | 7.4.5 6.14 | standard only | DPI, x/z |
| [`test_array_invalid_index_read_handles_real_string`](../../tests/ch7/test_array_invalid_index_read_handles_real_string.sv) | reading an unpacked array of real, shortreal, string, class, interface class, event or virtual interface elements with an out-of-bounds index or an index with an x bit gives 0.0, an empty string or null | 7.4.5 | standard only | x/z |
| [`test_contassign_packed_element_of_unpacked`](../../tests/ch7/test_contassign_packed_element_of_unpacked.sv) | Continuous assignments to packed elements of an element of an unpacked array | 7.4.5 6.5 10.3.2 | Icarus Verilog 13.0 |  |
| [`test_multi_dim_assign`](../../tests/ch7/test_multi_dim_assign.sv) | Test: Multi-dimensional array assignment | 7.4.5 7.4.2 | Verilator 5.052 |  |
| [`test_mux8_edge_cases`](../../tests/ch7/test_mux8_edge_cases.sv) | 8-to-1 Multiplexer edge cases | 7.4.5 10.3.2 | Icarus Verilog 13.0 |  |
| [`test_packed_parameter_element_select`](../../tests/ch7/test_packed_parameter_element_select.sv) | Elements of a parameter or localparam with packed dimensions are selected by their declared indices, ascending or descending | 7.4.5 6.20.1 7.4.1 | Verilator 5.052 |  |
| [`test_array_nba_part_select_index`](../../tests/ch7/test_array_nba_part_select_index.sv) | A FIFO whose memory is written with a nonblocking assignment indexed by a part-select of the pointer | 7.4.6 10.4.2 11.5.1 | Icarus Verilog 13.0 |  |
| [`test_array_whole_slice_equality_operations`](../../tests/ch7/test_array_whole_slice_equality_operations.sv) | fixed unpacked, packed, dynamic, queue and associative arrays are read and written whole and compared with == and !=, constant-width slices with variable positions are copied and compared, and a slice of a packed array is packed while a slice of an unpacked array is unpacked | 7.4.6 7.4.5 | Verilator 5.052 |  |
| [`test_dyn_array_edge`](../../tests/ch7/test_dyn_array_edge.sv) | Test: Dynamic array edge cases | 7.5 7.5.1 7.5.2 7.5.3 | Verilator 5.052 |  |
| [`test_dyn_array_edge_cases`](../../tests/ch7/test_dyn_array_edge_cases.sv) | Test: Dynamic array edge cases | 7.5 | Icarus Verilog 13.0 |  |
| [`test_dyn_resize`](../../tests/ch7/test_dyn_resize.sv) | Dynamic Array Resize Tests | 7.5 7.5.1 7.5.3 | Verilator 5.052 |  |
| [`test_dynamic_arr_edge_cases`](../../tests/ch7/test_dynamic_arr_edge_cases.sv) | Dynamic array edge cases | 7.5 | Icarus Verilog 13.0 |  |
| [`test_dynamic_array`](../../tests/ch7/test_dynamic_array.sv) | Dynamic Arrays (§7.5) | 7.5 | Icarus Verilog 13.0 |  |
| [`test_dynamic_array_2`](../../tests/ch7/test_dynamic_array_2.sv) | Dynamic array new[], resize with copy, size() and delete() | 7.5 | Icarus Verilog 13.0 |  |
| [`test_dynamic_array_corner`](../../tests/ch7/test_dynamic_array_corner.sv) | Tests dynamic array operations, resizing, and methods | 7.5 7.12 7.5.1 | Verilator 5.052 |  |
| [`test_dynamic_array_edge_cases`](../../tests/ch7/test_dynamic_array_edge_cases.sv) | Test: Dynamic array edge cases | 7.5 7.5.1 7.5.2 7.5.3 | Icarus Verilog 13.0 | x/z |
| [`test_dynamic_array_methods`](../../tests/ch7/test_dynamic_array_methods.sv) | Test for IEEE 1800-2023 §7.5-7.6: Dynamic array methods | 7.5 7.12 7.12.1 7.12.2 7.12.3 | Verilator 5.052 |  |
| [`test_dynamic_array_ops`](../../tests/ch7/test_dynamic_array_ops.sv) | Test for dynamic array operations | 7.5 7.5.1 | Icarus Verilog 13.0 |  |
| [`test_sv_dynamic_array`](../../tests/ch7/test_sv_dynamic_array.sv) | Dynamic arrays: new[], resize with copy, size() and delete() | 7.5 7.5.1 7.5.3 | Icarus Verilog 13.0 |  |
| [`test_value_dynamic`](../../tests/ch7/test_value_dynamic.sv) | Test for dynamic array value operations | 7.5 7.5.1 7.5.3 | Verilator 5.052 |  |
| [`test_dyn_array_basic`](../../tests/ch7/test_dyn_array_basic.sv) | Dynamic Array Basic Tests | 7.5.1 7.5.2 | Icarus Verilog 13.0 |  |
| [`test_dyn_array_method`](../../tests/ch7/test_dyn_array_method.sv) | Dynamic Array Method Tests | 7.5.1 7.5.2 7.5.3 | Icarus Verilog 13.0 |  |
| [`test_dyn_array_new`](../../tests/ch7/test_dyn_array_new.sv) | Test dynamic array new | 7.5.1 | Icarus Verilog 13.0 |  |
| [`test_dyn_array_ops`](../../tests/ch7/test_dyn_array_ops.sv) | Dynamic Array Operations Tests | 7.5.1 7.5.3 | Icarus Verilog 13.0 |  |
| [`test_dynamic_array_edge`](../../tests/ch7/test_dynamic_array_edge.sv) | Dynamic array edge cases | 7.5.1 7.5.2 7.5.3 7.6 | Icarus Verilog 13.0 |  |
| [`test_dynamic_array_new_discards_data_and_references`](../../tests/ch7/test_dynamic_array_new_discards_data_and_references.sv) | resizing or reinitializing a dynamic array with new[] discards its data unless the old array is given as the initializer, and in every case outdates references to its elements | 7.5.1 13.5.2 | standard only |  |
| [`test_dynamic_array_new_forms_order_and_size`](../../tests/ch7/test_dynamic_array_new_forms_order_and_size.sv) | new[] sizes a dynamic array in a declaration or a blocking assignment, evaluates its size before its initializer, makes only an identifier whose leftmost unpacked dimension is dynamic a dynamic array, and size() is an int that equals $size(array, 1) while delete() empties the array | 7.5.1 7.5 7.5.2 7.5.3 20.7 | Verilator 5.052 |  |
| [`test_dynamic_array_queue_size`](../../tests/ch7/test_dynamic_array_queue_size.sv) | Sizes of a dynamic array and a queue after new[], resizing, push_back and delete | 7.5.1 7.5.2 7.5.3 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_dynamic_resize`](../../tests/ch7/test_dynamic_resize.sv) | Dynamic array new, resize, delete operations | 7.5.1 | Icarus Verilog 13.0 |  |
| [`test_edge_dynamic_array_resize`](../../tests/ch7/test_edge_dynamic_array_resize.sv) | Dynamic array resizing with new[] and new[](old), including new[0] | 7.5.1 7.5.2 | Verilator 5.052 |  |
| [`test_dynamic_array_size_edge`](../../tests/ch7/test_dynamic_array_size_edge.sv) | Test dynamic array size() edge cases | 7.5.2 | Verilator 5.052 |  |
| [`test_dyn_array_delete`](../../tests/ch7/test_dyn_array_delete.sv) | Test dynamic array delete | 7.5.3 | Icarus Verilog 13.0 |  |
| [`test_array_assign_2`](../../tests/ch7/test_array_assign_2.sv) | Test array assignments | 7.6 7.5 10.9.1 | Verilator 5.052 |  |
| [`test_array_assign_resize_concat_source_slice_overlap`](../../tests/ch7/test_array_assign_resize_concat_source_slice_overlap.sv) | assigning to a dynamic array or queue resizes it to the number of source elements, the source can be an unpacked array concatenation of slices and items, and an assignment to a slice is one assignment, so an overlapping copy within one array moves the old values | 7.6 10.10 | standard only |  |
| [`test_array_copy`](../../tests/ch7/test_array_copy.sv) | Array Copy Tests | 7.6 7.4 | Verilator 5.052 |  |
| [`test_assign_array`](../../tests/ch7/test_assign_array.sv) | Array assignments | 7.6 10.4.1 | Verilator 5.052 |  |
| [`test_array_args_by_value_ref`](../../tests/ch7/test_array_args_by_value_ref.sv) | Arrays passed by value are copied, also dynamic arrays, queues and associative arrays, while a ref argument is the caller's array | 7.7 7.9.10 13.5.2 13.5.1 | Verilator 5.052 |  |
| [`test_array_argument_fixed_dynamic_queue_compatibility`](../../tests/ch7/test_array_argument_fixed_dynamic_queue_compatibility.sv) | array actual arguments follow the rules of array assignment: a fixed-size formal takes fixed arrays with other ranges and dynamic arrays or queues of the same size, and an unsized dynamic or queue formal takes fixed, dynamic and queue actuals of any size, elements matching from left to right | 7.7 7.6 | standard only |  |
| [`test_2d_assoc_methods`](../../tests/ch7/test_2d_assoc_methods.sv) | Test: 2D associative array methods (.exists, .first, .next, .delete) | 7.8 7.9 | Verilator 5.052 |  |
| [`test_assoc_array`](../../tests/ch7/test_assoc_array.sv) | Associative arrays | 7.8 7.9.1 7.9.2 7.9.3 | Verilator 5.052 |  |
| [`test_assoc_array_2`](../../tests/ch7/test_assoc_array_2.sv) | Associative array with string and int keys: lookup, size, exists, delete | 7.8 7.9 | Verilator 5.052 |  |
| [`test_assoc_array_assign`](../../tests/ch7/test_assoc_array_assign.sv) | Test: Associative array assignment | 7.8 7.8.1 7.8.2 | Verilator 5.052 |  |
| [`test_assoc_array_edge`](../../tests/ch7/test_assoc_array_edge.sv) | Associative array edge cases | 7.8 7.9 7.9.1 | Verilator 5.052 |  |
| [`test_assoc_array_edge_2`](../../tests/ch7/test_assoc_array_edge_2.sv) | Test: Associative array edge cases | 7.8 7.9 | Verilator 5.052 |  |
| [`test_assoc_array_edge_cases`](../../tests/ch7/test_assoc_array_edge_cases.sv) | Associative array edge cases | 7.8 7.9 | Verilator 5.052 |  |
| [`test_assoc_array_edge_cases_2`](../../tests/ch7/test_assoc_array_edge_cases_2.sv) | Test: Associative array edge cases | 7.8 7.9 | Verilator 5.052 |  |
| [`test_assoc_array_edge_cases_3`](../../tests/ch7/test_assoc_array_edge_cases_3.sv) | Test: Associative array edge cases | 7.8 7.9 | Verilator 5.052 |  |
| [`test_assoc_array_extended`](../../tests/ch7/test_assoc_array_extended.sv) | Test associative arrays | 7.8 7.9 | Verilator 5.052 |  |
| [`test_assoc_array_iterate`](../../tests/ch7/test_assoc_array_iterate.sv) | Test for associative array iteration | 7.8 7.9 7.9.4 7.9.5 | Verilator 5.052 |  |
| [`test_assoc_array_methods`](../../tests/ch7/test_assoc_array_methods.sv) | Test for IEEE 1800-2023 §7.8: Associative array methods | 7.8 7.9 7.9.1 7.9.2 7.9.3 7.9.4 7.9.5 7.9.6 7.9.7 | Verilator 5.052 |  |
| [`test_assoc_array_ops`](../../tests/ch7/test_assoc_array_ops.sv) | Associative Array Operations Tests | 7.8 7.9 | Verilator 5.052 |  |
| [`test_assoc_basic`](../../tests/ch7/test_assoc_basic.sv) | Associative Array Basic Tests | 7.8 7.9 | Verilator 5.052 |  |
| [`test_assoc_int_key`](../../tests/ch7/test_assoc_int_key.sv) | Test associative array with int key | 7.8 7.9 | Verilator 5.052 |  |
| [`test_assoc_key`](../../tests/ch7/test_assoc_key.sv) | Associative Array Key Tests | 7.8 | Verilator 5.052 |  |
| [`test_assoc_ops`](../../tests/ch7/test_assoc_ops.sv) | Associative Array Operations Tests | 7.8 7.9 | Verilator 5.052 |  |
| [`test_associative_array`](../../tests/ch7/test_associative_array.sv) | Associative Arrays (§7.8) | 7.8 7.9 | Verilator 5.052 |  |
| [`test_associative_array_corner`](../../tests/ch7/test_associative_array_corner.sv) | Tests associative array operations with various index types | 7.8 7.9 7.8.1 7.8.3 | Verilator 5.052 |  |
| [`test_sv_assoc_array`](../../tests/ch7/test_sv_assoc_array.sv) | Test: Associative array: int map[string], exists(), first(), next(), delete(), num() | 7.8 7.9 | Verilator 5.052 |  |
| [`test_value_assoc`](../../tests/ch7/test_value_assoc.sv) | Test for associative array value operations | 7.8 7.9 | Verilator 5.052 |  |
| [`test_assoc_wildcard_string_literal_bits`](../../tests/ch7/test_assoc_wildcard_string_literal_bits.sv) | String literal wildcard keys alias equally wide packed integral values | 7.8.1 | Verilator 5.052 | exit code |
| [`test_assoc_wildcard_width_and_sign_aliases`](../../tests/ch7/test_assoc_wildcard_width_and_sign_aliases.sv) | Wildcard keys normalize leading zeros and preserve arbitrary-width unsigned values | 7.8.1 7.8 | Verilator 5.052 | exit code |
| [`test_assoc_string_empty_and_reverse_order`](../../tests/ch7/test_assoc_string_empty_and_reverse_order.sv) | String associative keys include the empty string and prev follows reverse lexical order | 7.8.2 7.9.7 7.9.11 | Verilator 5.052 |  |
| [`test_assoc_class_key_order_is_stable`](../../tests/ch7/test_assoc_class_key_order_is_stable.sv) | Class key traversal repeats for a fixed set without prescribing address order | 7.8.3 | Verilator 5.052 | exit code |
| [`test_assoc_class_null_and_alias_keys`](../../tests/ch7/test_assoc_class_null_and_alias_keys.sv) | A class indexed associative array accepts null and aliases identify the same object key | 7.8.3 | Verilator 5.052 |  |
| [`test_assoc_integral_index_cast_context`](../../tests/ch7/test_assoc_integral_index_cast_context.sv) | Typed indices apply cast width and sign context before arithmetic truncation | 7.8.4 | standard only | exit code |
| [`test_assoc_signed_and_unsigned_key_order`](../../tests/ch7/test_assoc_signed_and_unsigned_key_order.sv) | Equal high-bit key patterns have different signed and unsigned traversal orders | 7.8.4 | standard only | exit code |
| [`test_assoc_signed_boundary_order`](../../tests/ch7/test_assoc_signed_boundary_order.sv) | Signed integral associative keys iterate in signed numerical order across zero | 7.8.4 | standard only |  |
| [`test_associative_array_edge_cases`](../../tests/ch7/test_associative_array_edge_cases.sv) | Associative array edge cases | 7.8.4 7.9 | Verilator 5.052 |  |
| [`test_assoc_composite_empty_null_key_order`](../../tests/ch7/test_assoc_composite_empty_null_key_order.sv) | Empty strings and null handles in composite keys are valid with stable order | 7.8.5 | Verilator 5.052 | exit code |
| [`test_assoc_foreach_struct_key`](../../tests/ch7/test_assoc_foreach_struct_key.sv) | Test associative array foreach with struct keys | 7.8.5 12.7.3 | Verilator 5.052 |  |
| [`test_illegal_assoc_real_member_key`](../../tests/ch7/test_illegal_assoc_real_member_key.sv) | An associative index type cannot contain a real member | 7.8.5 | standard only | illegal design |
| [`test_assoc_array_unknown_index`](../../tests/ch7/test_assoc_array_unknown_index.sv) | An index with x or z bits is invalid for an associative array: a read gives the element type's default and a write does nothing | 7.8.6 7.4.5 | standard only | x/z |
| [`test_assoc_default_and_delete_silent`](../../tests/ch7/test_assoc_default_and_delete_silent.sv) | Defaults and deleting missing keys produce no warning and no new entries | 7.8.6 7.9.11 7.9.2 | Verilator 5.052 | exit code |
| [`test_assoc_invalid_write_reports_diagnostic`](../../tests/ch7/test_assoc_invalid_write_reports_diagnostic.sv) | An invalid four-state key write is ignored with a warning | 7.8.6 7.8.4 | standard only | exit code, x/z |
| [`test_assoc_missing_read_reports_diagnostic`](../../tests/ch7/test_assoc_missing_read_reports_diagnostic.sv) | A missing read returns the four-state default with a warning and no allocation | 7.8.6 7.4.5 7.9.11 | standard only | exit code, x/z |
| [`test_assoc_unknown_write_does_not_allocate`](../../tests/ch7/test_assoc_unknown_write_does_not_allocate.sv) | Writing through an unknown associative key neither creates an element nor corrupts a known entry | 7.8.6 7.8.4 | standard only | x/z |
| [`test_assoc_allocate_on_write`](../../tests/ch7/test_assoc_allocate_on_write.sv) | A nonexistent associative array element is allocated when it is assigned or passed by reference, and an increment or member write first allocates it with its default or initial value | 7.8.7 7.9.11 7.9.1 13.5.2 7.8 | standard only |  |
| [`test_assoc_allocate_on_write_types`](../../tests/ch7/test_assoc_allocate_on_write_types.sv) | A write to a nonexistent associative array element allocates it first, with the default or initial value of the element type or with a nested array, for an increment, a member write, a string concatenation and a ref argument | 7.8.7 7.9.1 13.5.2 | Verilator 5.052 |  |
| [`test_assoc_read_modify_defaults_without_ref`](../../tests/ch7/test_assoc_read_modify_defaults_without_ref.sv) | Read-modify-write uses user and type defaults without ref support | 7.8.7 | Verilator 5.052 | exit code |
| [`test_assoc_ref_allocates_before_callee_write`](../../tests/ch7/test_assoc_ref_allocates_before_callee_write.sv) | A missing ref actual is allocated before a callee that never writes | 7.8.7 7.8 13.5.2 | standard only | exit code |
| [`test_assoc_array_methods_basic`](../../tests/ch7/test_assoc_array_methods_basic.sv) | Associative array methods: exists/first/next/delete | 7.9 | Verilator 5.052 |  |
| [`test_assoc_array_ops_2`](../../tests/ch7/test_assoc_array_ops_2.sv) | Test: Associative array exists, first, last, next, prev, delete operations | 7.9 7.9.3 7.9.4 7.9.5 7.9.6 | Verilator 5.052 |  |
| [`test_assoc_method_edge_cases`](../../tests/ch7/test_assoc_method_edge_cases.sv) | Associative array method edge cases | 7.9 | Verilator 5.052 |  |
| [`test_assoc_count_expression_types`](../../tests/ch7/test_assoc_count_expression_types.sv) | Count method types are checked independently of traversal method support | 7.9.1 20.6.1 20.6.2 | Verilator 5.052 | exit code |
| [`test_assoc_method_expression_types`](../../tests/ch7/test_assoc_method_expression_types.sv) | Associative method expression types are int and statuses are exact integers | 7.9.1 7.9.3 7.9.4 7.9.5 7.9.6 7.9.7 20.6.1 20.6.2 | standard only | exit code |
| [`test_assoc_num`](../../tests/ch7/test_assoc_num.sv) | Test: Associative array num method | 7.9.1 | Verilator 5.052 |  |
| [`test_assoc_delete`](../../tests/ch7/test_assoc_delete.sv) | Test associative array delete | 7.9.2 | Verilator 5.052 |  |
| [`test_assoc_delete_2`](../../tests/ch7/test_assoc_delete_2.sv) | Test: Associative array delete method | 7.9.2 | Verilator 5.052 |  |
| [`test_assoc_delete_index_argument_forms`](../../tests/ch7/test_assoc_delete_index_argument_forms.sv) | the associative array method delete is a void function whose optional input argument has the index type of the array, so it takes string, converted integral and class handle keys, and without the argument it removes every entry | 7.9.2 | Verilator 5.052 |  |
| [`test_assoc_exists`](../../tests/ch7/test_assoc_exists.sv) | Test associative array exists | 7.9.3 | Verilator 5.052 |  |
| [`test_assoc_exists_2`](../../tests/ch7/test_assoc_exists_2.sv) | Test: Associative array exists method | 7.9.3 | Verilator 5.052 |  |
| [`test_exists_method`](../../tests/ch7/test_exists_method.sv) | exists() method of associative arrays with int and string keys | 7.9.3 | Verilator 5.052 |  |
| [`test_exists_method_2`](../../tests/ch7/test_exists_method_2.sv) | Test for exists() method implementation | 7.9.3 7.8.1 | Verilator 5.052 |  |
| [`test_assoc_first`](../../tests/ch7/test_assoc_first.sv) | Test associative array first | 7.9.4 | Verilator 5.052 |  |
| [`test_assoc_first_2`](../../tests/ch7/test_assoc_first_2.sv) | Test: Associative array first method | 7.9.4 | Verilator 5.052 |  |
| [`test_assoc_next`](../../tests/ch7/test_assoc_next.sv) | Test associative array next | 7.9.4 7.9.6 | Verilator 5.052 |  |
| [`test_assoc_last`](../../tests/ch7/test_assoc_last.sv) | Test associative array last | 7.9.5 | Verilator 5.052 |  |
| [`test_assoc_last_2`](../../tests/ch7/test_assoc_last_2.sv) | Test: Associative array last method | 7.9.5 | Verilator 5.052 |  |
| [`test_assoc_prev`](../../tests/ch7/test_assoc_prev.sv) | Test associative array prev | 7.9.5 7.9.7 | Verilator 5.052 |  |
| [`test_assoc_array_iter_minimal`](../../tests/ch7/test_assoc_array_iter_minimal.sv) | Associative array minimal: first/next/last/num/size | 7.9.6 7.9.4 7.9.5 | Verilator 5.052 |  |
| [`test_assoc_next_2`](../../tests/ch7/test_assoc_next_2.sv) | Test: Associative array next method | 7.9.6 7.9.4 | Verilator 5.052 |  |
| [`test_assoc_traversal_gaps_and_preserved_keys`](../../tests/ch7/test_assoc_traversal_gaps_and_preserved_keys.sv) | Traversal accepts absent input keys and preserves the argument on failure | 7.9.6 7.9.7 | standard only | exit code |
| [`test_assoc_prev_2`](../../tests/ch7/test_assoc_prev_2.sv) | Test: Associative array prev method | 7.9.7 7.9.5 | Verilator 5.052 |  |
| [`test_assoc_narrow_prev_next_overflow`](../../tests/ch7/test_assoc_narrow_prev_next_overflow.sv) | Next and prev report truncation when a discovered key does not fit their narrow output index | 7.9.8 7.9.6 7.9.7 | standard only |  |
| [`test_assoc_traversal_narrow_index`](../../tests/ch7/test_assoc_traversal_narrow_index.sv) | An associative array traversal method given an index variable too narrow for the key returns -1 and keeps the low bits of the key | 7.9.8 7.9.4 7.9.5 | standard only |  |
| [`test_assoc_assignment_clears_and_detaches`](../../tests/ch7/test_assoc_assignment_clears_and_detaches.sv) | Associative assignment removes old destination keys and passing by value makes an independent local copy | 7.9.9 7.9.10 | Verilator 5.052 |  |
| [`test_assoc_assignment_copies_every_entry`](../../tests/ch7/test_assoc_assignment_copies_every_entry.sv) | Whole assignment clears old entries and copies every scalar value independently | 7.9.9 | Verilator 5.052 | exit code |
| [`test_assoc_array_literal_default`](../../tests/ch7/test_assoc_array_literal_default.sv) | Associative array literals with a default value, and assignment of a whole associative array | 7.9.11 7.9.9 7.9.1 | Verilator 5.052 |  |
| [`test_assign_queue`](../../tests/ch7/test_assign_queue.sv) | Test for queue assignment | 7.10 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_builtin_methods_mixed`](../../tests/ch7/test_builtin_methods_mixed.sv) | Built-in methods of queues, dynamic arrays, associative arrays and strings | 7.10 7.5 7.9 6.16 | Verilator 5.052 |  |
| [`test_comb_queue_ops`](../../tests/ch7/test_comb_queue_ops.sv) | Queue operations | 7.10 | Icarus Verilog 13.0 |  |
| [`test_container_assign_pattern`](../../tests/ch7/test_container_assign_pattern.sv) | Container assignment patterns and type conversion | 7.10 7.10.4 10.9.1 7.5.1 | Icarus Verilog 13.0 |  |
| [`test_queue_assign`](../../tests/ch7/test_queue_assign.sv) | Test: Queue element assignment | 7.10 7.10.2 | Verilator 5.052 |  |
| [`test_queue_basic`](../../tests/ch7/test_queue_basic.sv) | Queue Basic Tests | 7.10 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_basic_edge_cases`](../../tests/ch7/test_queue_basic_edge_cases.sv) | Queue basic edge cases | 7.10 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_dimension_and_array_operations`](../../tests/ch7/test_queue_dimension_and_array_operations.sv) | a queue dimension is [$] or [$:N] with N the highest index allowed, and queues support indexing with $, concatenation, slicing, equality and the other operations of fixed-size unpacked arrays: element writes, whole assignment to and from fixed arrays, foreach, array methods and array queries | 7.10 7.10.1 20.7 | standard only |  |
| [`test_queue_edge`](../../tests/ch7/test_queue_edge.sv) | Test: Queue operation edge cases | 7.10 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_edge_2`](../../tests/ch7/test_queue_edge_2.sv) | Queue edge cases | 7.10 7.10.1 7.10.2 | Verilator 5.052 |  |
| [`test_queue_edge_cases`](../../tests/ch7/test_queue_edge_cases.sv) | Test: Queue edge cases | 7.10 7.10.5 | Icarus Verilog 13.0 |  |
| [`test_queue_edge_cases_2`](../../tests/ch7/test_queue_edge_cases_2.sv) | Queue operations edge cases | 7.10 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_edge_cases_3`](../../tests/ch7/test_queue_edge_cases_3.sv) | Corner Case: Queue Edge Cases | 7.10 | Verilator 5.052 |  |
| [`test_queue_insert`](../../tests/ch7/test_queue_insert.sv) | Test queue insert | 7.10 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_method`](../../tests/ch7/test_queue_method.sv) | Queue Method Tests | 7.10 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_methods`](../../tests/ch7/test_queue_methods.sv) | Test for IEEE 1800-2023 §7.10: Queue methods | 7.10 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_methods_basic`](../../tests/ch7/test_queue_methods_basic.sv) | Test for queue methods | 7.10 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_methods_bounded`](../../tests/ch7/test_queue_methods_bounded.sv) | Queue methods, assignment from a list and a bounded queue | 7.10 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_methods_edge_cases`](../../tests/ch7/test_queue_methods_edge_cases.sv) | Test: Queue edge cases - empty operations, boundary indices | 7.10 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_methods_sequence`](../../tests/ch7/test_queue_methods_sequence.sv) | A sequence of queue method calls | 7.10 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_operations`](../../tests/ch7/test_queue_operations.sv) | Queue Operations Tests | 7.10 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_ops`](../../tests/ch7/test_queue_ops.sv) | Test for queue operations | 7.10 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_ops_adv_edge_cases`](../../tests/ch7/test_queue_ops_adv_edge_cases.sv) | Test: Queue advanced operations edge cases | 7.10 7.10.2 7.10.5 | Verilator 5.052 |  |
| [`test_queue_ops_edge_cases`](../../tests/ch7/test_queue_ops_edge_cases.sv) | Test: Queue operations edge cases | 7.10 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_ordering`](../../tests/ch7/test_queue_ordering.sv) | Test queue ordering methods | 7.10 7.12.2 | Verilator 5.052 |  |
| [`test_queue_push`](../../tests/ch7/test_queue_push.sv) | Queue Push/Pop Tests | 7.10 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_push_pop`](../../tests/ch7/test_queue_push_pop.sv) | Test queue push/pop | 7.10 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_size`](../../tests/ch7/test_queue_size.sv) | Test queue size | 7.10 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_sv_queue`](../../tests/ch7/test_sv_queue.sv) | Queues: push, pop, insert, delete and the $ index | 7.10 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_value_queue_ops`](../../tests/ch7/test_value_queue_ops.sv) | Test for queue value operations | 7.10 7.10.2 | Verilator 5.052 |  |
| [`test_queue_invalid_index_read_defaults`](../../tests/ch7/test_queue_invalid_index_read_defaults.sv) | reading a queue with an index below 0, above $, or with an x or z bit returns the nonexistent-entry value of its element type: 0 for int, x for logic, the empty string for string | 7.10.1 7.4.5 | Icarus Verilog 13.0 | x/z |
| [`test_queue_invalid_index_write_ignored_warning`](../../tests/ch7/test_queue_invalid_index_write_ignored_warning.sv) | a write to a queue with an index below 0, above $+1, or with an x or z bit is ignored with a run-time warning, while a write to [$+1] appends an element | 7.10.1 | Icarus Verilog 13.0 | exit code, x/z |
| [`test_queue_slice_bounds_clip_and_empty`](../../tests/ch7/test_queue_slice_bounds_clip_and_empty.sv) | a queue slice Q[a:b] takes variable bounds, clips a below 0 to 0 and b above $ to $, is empty when a > b or a bound has an x or z bit, and Q[n:n] holds just Q[n] or is empty when n is out of range | 7.10.1 | standard only | x/z |
| [`test_queue_write_at_size_appends`](../../tests/ch7/test_queue_write_at_size_appends.sv) | Writing a queue element at index size() appends it, and writing beyond that does nothing | 7.10.1 7.4.5 | Icarus Verilog 13.0 |  |
| [`test_edge_queue_assoc`](../../tests/ch7/test_edge_queue_assoc.sv) | Queue push/pop and associative array first(), delete() and exists() with string keys | 7.10.2 7.9.4 7.9.2 7.9.3 7.8.2 | Verilator 5.052 |  |
| [`test_member_queue`](../../tests/ch7/test_member_queue.sv) | Queue methods on int, byte and string queues | 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_delete_2`](../../tests/ch7/test_queue_delete_2.sv) | Queue delete at index method | 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_insert_2`](../../tests/ch7/test_queue_insert_2.sv) | Queue insert at index method | 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_insert_delete`](../../tests/ch7/test_queue_insert_delete.sv) | Queue push, pop, insert and delete | 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_methods_2`](../../tests/ch7/test_queue_methods_2.sv) | Queue methods | 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_methods_3`](../../tests/ch7/test_queue_methods_3.sv) | Queue push_back, push_front, pop_front and pop_back | 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_methods_4`](../../tests/ch7/test_queue_methods_4.sv) | Queue push_back, pop_front, pop_back, insert, delete methods | 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_ops_2`](../../tests/ch7/test_queue_ops_2.sv) | Queue push, pop, insert and delete after assignment from a list | 7.10.2 10.10 | Icarus Verilog 13.0 |  |
| [`test_queue_pop_back`](../../tests/ch7/test_queue_pop_back.sv) | Queue pop_back method | 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_pop_front`](../../tests/ch7/test_queue_pop_front.sv) | Queue pop_front method | 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_push_back`](../../tests/ch7/test_queue_push_back.sv) | Queue push_back method | 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_push_front`](../../tests/ch7/test_queue_push_front.sv) | Queue push_front method | 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_push_pop_2`](../../tests/ch7/test_queue_push_pop_2.sv) | Queue push_front, push_back, pop_front and pop_back | 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_size_2`](../../tests/ch7/test_queue_size_2.sv) | Queue size method | 7.10.2 | Icarus Verilog 13.0 |  |
| [`test_queue_size_method`](../../tests/ch7/test_queue_size_method.sv) | size() of a queue is 0 when the queue is empty and follows every push, insert and delete, and the elements of an assignment pattern | 7.10.2.1 7.10.2.3 7.10.2.6 7.10 | Icarus Verilog 13.0 |  |
| [`test_queue_insert_positions`](../../tests/ch7/test_queue_insert_positions.sv) | insert(index, item) puts an item at the first, middle or end position of a queue and shifts the later elements, and an index equal to the size appends, for queues of int and string | 7.10.2.2 7.10.2.1 | Icarus Verilog 13.0 |  |
| [`test_queue_method_edges`](../../tests/ch7/test_queue_method_edges.sv) | Queue methods at their limits: size of an empty queue, insert at the end and ignored inserts at a negative, too large or unknown index, push_front, and pop_front and pop_back that remove an end or, on an empty queue, return the value of a nonexistent element | 7.10.2.2 7.10.2.1 7.10.2.4 7.10.2.5 7.10.2.6 7.4.5 | standard only | x/z |
| [`test_queue_method_prototypes_and_invalid_indices`](../../tests/ch7/test_queue_method_prototypes_and_invalid_indices.sv) | queue methods follow their prototypes: size() returns int, insert() and delete() take an integer index and ignore an index that is negative, too large or has x bits, insert(), push_front() and push_back() convert the item to the element type, and pop_front() and pop_back() return the element type | 7.10.2.2 7.10.2.1 7.10.2.3 7.10.2.4 7.10.2.5 7.10.2.6 7.10.2.7 | Icarus Verilog 13.0 | x/z |
| [`test_queue_delete`](../../tests/ch7/test_queue_delete.sv) | Test queue delete | 7.10.2.3 7.10.4 | Icarus Verilog 13.0 |  |
| [`test_queue_pop_front_order`](../../tests/ch7/test_queue_pop_front_order.sv) | pop_front() removes and returns the first element and shifts the others, for queues of string and int, until the queue is empty | 7.10.2.4 7.10.2.1 | Icarus Verilog 13.0 |  |
| [`test_queue_pop_back_order`](../../tests/ch7/test_queue_pop_back_order.sv) | pop_back() removes and returns the last element and leaves the others in order, for queues of string and int, until the queue is empty | 7.10.2.5 7.10.2.1 | Icarus Verilog 13.0 |  |
| [`test_queue_size_wait_after_pop`](../../tests/ch7/test_queue_size_wait_after_pop.sv) | Queue size changes unblock a wait when a pop makes the queue empty | 7.10.2.7 | Verilator 5.052 |  |
| [`test_queue_ref_survives_unrelated_pop`](../../tests/ch7/test_queue_ref_survives_unrelated_pop.sv) | Popping the last queue element preserves a reference to the first element | 7.10.3 13.5.2 | Verilator 5.052 |  |
| [`test_queue_reference_persistence`](../../tests/ch7/test_queue_reference_persistence.sv) | A reference to a queue element held by a task stays on that element when other methods change the queue, and becomes outdated when the element is deleted or the whole queue is assigned | 7.10.3 13.5.2 7.10.2 | standard only |  |
| [`test_queue_refs_outdated_by_bounded_push_and_assignment`](../../tests/ch7/test_queue_refs_outdated_by_bounded_push_and_assignment.sv) | a queue assignment that gives the same value as push_back outdates every reference to the old elements while push_back keeps them, and push_front on a full bounded queue outdates only the reference to the dropped last element | 7.10.4 7.10.3 13.5.2 | Verilator 5.052 |  |
| [`test_bounded_queue_assign_discards_beyond_bound`](../../tests/ch7/test_bounded_queue_assign_discards_beyond_bound.sv) | assigning a longer queue value to a bounded queue keeps the elements up to the bound and drops, with a warning, those beyond it | 7.10.5 7.10 7.10.4 | standard only | exit code |
| [`test_bounded_queue_methods_discard_beyond_bound`](../../tests/ch7/test_bounded_queue_methods_discard_beyond_bound.sv) | push_back, push_front, insert and a write to [$+1] on a full bounded queue act as on an unbounded queue and then drop, with a warning, the element above the bound | 7.10.5 7.10 | Icarus Verilog 13.0 | exit code |
| [`test_array_method_corner`](../../tests/ch7/test_array_method_corner.sv) | Tests find, sort, sum, min, max, unique methods | 7.12 7.12.1 7.12.2 7.12.3 | Verilator 5.052 |  |
| [`test_array_method_index_argument`](../../tests/ch7/test_array_method_index_argument.sv) | The second argument of an array method names the index method of its iterator, also where an element has a member named index | 7.12 7.12.4 7.12.1 | standard only |  |
| [`test_array_method_iterator_index_names_and_selects`](../../tests/ch7/test_array_method_iterator_index_names_and_selects.sv) | array method calls use item and index as default names, an iterator argument names the element only inside the with expression, an index argument renames the index method, index() returns int or the associative index type, and selects and methods on the result follow the with clause or the call | 7.12 7.12.1 7.12.4 | standard only |  |
| [`test_array_methods_2`](../../tests/ch7/test_array_methods_2.sv) | Test for IEEE 1800-2023 §7.12: Array manipulation methods | 7.12 7.12.1 7.12.2 7.12.3 | Verilator 5.052 |  |
| [`test_array_predicates`](../../tests/ch7/test_array_predicates.sv) | Array Methods Tests | 7.12 7.5 7.10 | Icarus Verilog 13.0 |  |
| [`test_comb_queue_methods_ext`](../../tests/ch7/test_comb_queue_methods_ext.sv) | Test: Extended queue and array method edge cases | 7.12 7.10.2 | Verilator 5.052 |  |
| [`test_comb_queue_with_clause`](../../tests/ch7/test_comb_queue_with_clause.sv) | Test: Queue methods with 'with' clause | 7.12 7.12.1 7.12.2 7.12.3 | Verilator 5.052 |  |
| [`test_ieee1800_2023_array_method_corner`](../../tests/ch7/test_ieee1800_2023_array_method_corner.sv) | Array Manipulation Methods Corner Cases | 7.12 7.12.1 7.12.2 7.12.3 7.10.2 7.9 | Verilator 5.052 |  |
| [`test_illegal_array_method_with_braces`](../../tests/ch7/test_illegal_array_method_with_braces.sv) | the with clause of an array manipulation method encloses its expression in parentheses; braces, as used by randomize() with, are illegal there | 7.12 | Verilator 5.052 | illegal design |
| [`test_illegal_iterator_argument_without_with`](../../tests/ch7/test_illegal_iterator_argument_without_with.sv) | An array method cannot name its iterator without a with clause | 7.12 7.12.3 | standard only | illegal design |
| [`test_member_access_deep`](../../tests/ch7/test_member_access_deep.sv) | array methods, §8.5 class member access | 7.12 8.5 | Verilator 5.052 |  |
| [`test_array_find`](../../tests/ch7/test_array_find.sv) | Array Locator Methods (§7.12.1) | 7.12.1 | Verilator 5.052 |  |
| [`test_array_find_2`](../../tests/ch7/test_array_find_2.sv) | Test: Array find method | 7.12.1 | Verilator 5.052 |  |
| [`test_array_find_first`](../../tests/ch7/test_array_find_first.sv) | Test: Array find_first method | 7.12.1 | Verilator 5.052 |  |
| [`test_array_find_index`](../../tests/ch7/test_array_find_index.sv) | Test: Array find_index method | 7.12.1 | Verilator 5.052 |  |
| [`test_array_find_last`](../../tests/ch7/test_array_find_last.sv) | Test: Array find_last method | 7.12.1 | Verilator 5.052 |  |
| [`test_array_find_methods`](../../tests/ch7/test_array_find_methods.sv) | Array manipulation methods | 7.12.1 | Verilator 5.052 |  |
| [`test_array_locator`](../../tests/ch7/test_array_locator.sv) | Array locator methods | 7.12.1 | Verilator 5.052 |  |
| [`test_array_locator_first_last_by_range_and_min_tie`](../../tests/ch7/test_array_locator_first_last_by_range_and_min_tie.sv) | find_first and find_last pick the match closest to the leftmost or rightmost index, which for a descending range is the highest or lowest index and for an associative array follows first() and last(); min() returns one element even when several tie | 7.12.1 | standard only |  |
| [`test_array_locator_methods`](../../tests/ch7/test_array_locator_methods.sv) | Array Locator Methods | 7.12.1 | Verilator 5.052 |  |
| [`test_array_locator_methods_2`](../../tests/ch7/test_array_locator_methods_2.sv) | Test for array locator methods | 7.12.1 | Verilator 5.052 |  |
| [`test_array_max`](../../tests/ch7/test_array_max.sv) | Test for array max method | 7.12.1 | Verilator 5.052 |  |
| [`test_array_method`](../../tests/ch7/test_array_method.sv) | Array ordering, locator and unique methods on a fixed-size int array | 7.12.1 7.12.2 | Verilator 5.052 |  |
| [`test_array_methods`](../../tests/ch7/test_array_methods.sv) | Array ordering, locator and reduction methods on a fixed-size array | 7.12.1 7.12.2 7.12.3 | Verilator 5.052 |  |
| [`test_array_methods_edge_cases`](../../tests/ch7/test_array_methods_edge_cases.sv) | Array manipulation methods edge cases | 7.12.1 7.12.2 7.12.3 | Verilator 5.052 |  |
| [`test_array_min`](../../tests/ch7/test_array_min.sv) | Test for array min method | 7.12.1 | Verilator 5.052 |  |
| [`test_array_min_max`](../../tests/ch7/test_array_min_max.sv) | Test array min/max methods | 7.12.1 | Verilator 5.052 |  |
| [`test_array_reduction_methods_2`](../../tests/ch7/test_array_reduction_methods_2.sv) | Array manipulation methods | 7.12.1 7.12.3 | Verilator 5.052 |  |
| [`test_array_unique`](../../tests/ch7/test_array_unique.sv) | Array locator method - unique() | 7.12.1 | Verilator 5.052 |  |
| [`test_array_unique_2`](../../tests/ch7/test_array_unique_2.sv) | Test for array unique method | 7.12.1 | Verilator 5.052 |  |
| [`test_array_unique_methods`](../../tests/ch7/test_array_unique_methods.sv) | Array unique methods | 7.12.1 | Verilator 5.052 |  |
| [`test_comb_array_reduce_sort`](../../tests/ch7/test_comb_array_reduce_sort.sv) | Test: Array reduction methods (sum/product/and/or/xor), shuffle, sort, unique | 7.12.1 7.12.2 7.12.3 | Verilator 5.052 |  |
| [`test_comb_dynarray_find`](../../tests/ch7/test_comb_dynarray_find.sv) | Test: DynamicArray find_first/find_last and locator methods | 7.12.1 | Verilator 5.052 |  |
| [`test_comb_dynarray_locator`](../../tests/ch7/test_comb_dynarray_locator.sv) | Test: Dynamic array locator methods | 7.12.1 7.12.3 | Verilator 5.052 |  |
| [`test_member_array`](../../tests/ch7/test_member_array.sv) | Test array method member access (.size, .find, etc.) | 7.12.1 7.12.3 7.5 7.10 | Verilator 5.052 |  |
| [`test_array_ordering`](../../tests/ch7/test_array_ordering.sv) | Test array ordering methods | 7.12.2 | Verilator 5.052 |  |
| [`test_array_ordering_methods`](../../tests/ch7/test_array_ordering_methods.sv) | Array manipulation methods | 7.12.2 | Verilator 5.052 |  |
| [`test_array_ordering_methods_with_and_iterator`](../../tests/ch7/test_array_ordering_methods_with_and_iterator.sv) | sort() and rsort() order a dynamic array, a fixed array and a queue by the element value or by a with expression using item or a named iterator, reverse() reverses, and shuffle() leaves a permutation of the elements | 7.12.2 | standard only |  |
| [`test_array_reverse`](../../tests/ch7/test_array_reverse.sv) | Array ordering method - reverse() | 7.12.2 | Verilator 5.052 |  |
| [`test_array_reverse_2`](../../tests/ch7/test_array_reverse_2.sv) | Test for array reverse method | 7.12.2 | Verilator 5.052 |  |
| [`test_array_rsort`](../../tests/ch7/test_array_rsort.sv) | Array ordering method - rsort() | 7.12.2 | Verilator 5.052 |  |
| [`test_array_shuffle`](../../tests/ch7/test_array_shuffle.sv) | Array ordering method - shuffle() | 7.12.2 | Verilator 5.052 |  |
| [`test_array_shuffle_2`](../../tests/ch7/test_array_shuffle_2.sv) | Test for array shuffle method | 7.12.2 7.12.3 | Verilator 5.052 |  |
| [`test_array_sort`](../../tests/ch7/test_array_sort.sv) | Array ordering method - sort() | 7.12.2 | Verilator 5.052 |  |
| [`test_real_queue_sort_min_max`](../../tests/ch7/test_real_queue_sort_min_max.sv) | sort, rsort, min and max on a queue of reals order the elements by their real values | 7.12.2 7.12.1 | Verilator 5.052 |  |
| [`test_sort_rsort_shuffle_reverse`](../../tests/ch7/test_sort_rsort_shuffle_reverse.sv) | , §7.10: Array manipulation methods | 7.12.2 | Verilator 5.052 |  |
| [`test_struct_array_sort`](../../tests/ch7/test_struct_array_sort.sv) | Corner Case: Struct Array Sorting | 7.12.2 7.2 | Verilator 5.052 |  |
| [`test_array_and`](../../tests/ch7/test_array_and.sv) | Test for array and reduction method | 7.12.3 | Verilator 5.052 |  |
| [`test_array_and_or_xor`](../../tests/ch7/test_array_and_or_xor.sv) | Test: Array and/or/xor methods | 7.12.3 | Verilator 5.052 |  |
| [`test_array_method_sum`](../../tests/ch7/test_array_method_sum.sv) | Test for array method sum/product | 7.12.3 | Verilator 5.052 |  |
| [`test_array_or`](../../tests/ch7/test_array_or.sv) | Test for array or reduction method | 7.12.3 | Verilator 5.052 |  |
| [`test_array_product`](../../tests/ch7/test_array_product.sv) | Test for array product method | 7.12.3 | Verilator 5.052 |  |
| [`test_array_reduce`](../../tests/ch7/test_array_reduce.sv) | Test array reduction methods | 7.12.3 | Verilator 5.052 |  |
| [`test_array_reduction`](../../tests/ch7/test_array_reduction.sv) | Array Reduction Methods (§7.12.3) | 7.12.3 | Verilator 5.052 |  |
| [`test_array_reduction_2`](../../tests/ch7/test_array_reduction_2.sv) | Test array reduction methods | 7.12.3 20.7 | Verilator 5.052 |  |
| [`test_array_reduction_and`](../../tests/ch7/test_array_reduction_and.sv) | Array reduction method - and() | 7.12.3 | Verilator 5.052 |  |
| [`test_array_reduction_and_or_xor_with`](../../tests/ch7/test_array_reduction_and_or_xor_with.sv) | The and(), or() and xor() reduction methods apply their with clause to each element before reducing | 7.12.3 | Verilator 5.052 |  |
| [`test_array_reduction_methods`](../../tests/ch7/test_array_reduction_methods.sv) | 7.12.3 Array Reduction and Locator Methods Test | 7.12.3 7.12.1 7.5.2 | Verilator 5.052 |  |
| [`test_array_reduction_or`](../../tests/ch7/test_array_reduction_or.sv) | Array reduction method - or() | 7.12.3 | Verilator 5.052 |  |
| [`test_array_reduction_product`](../../tests/ch7/test_array_reduction_product.sv) | Array reduction method - product() | 7.12.3 | Verilator 5.052 |  |
| [`test_array_reduction_result_type_and_with_width`](../../tests/ch7/test_array_reduction_result_type_and_with_width.sv) | a reduction method returns a value of the element type without a with clause and of the with expression type with one, so the reduction wraps at the element width even when assigned to a wider variable, and a cast in the with clause widens every operand first | 7.12.3 | standard only |  |
| [`test_array_reduction_with_clause`](../../tests/ch7/test_array_reduction_with_clause.sv) | Array Reduction Methods with with-clause | 7.12.3 7.12.4 | Verilator 5.052 |  |
| [`test_array_reduction_xor`](../../tests/ch7/test_array_reduction_xor.sv) | Array reduction method - xor() | 7.12.3 | Verilator 5.052 |  |
| [`test_array_sum`](../../tests/ch7/test_array_sum.sv) | Test for array sum method | 7.12.3 | Verilator 5.052 |  |
| [`test_array_xor`](../../tests/ch7/test_array_xor.sv) | Test for array xor reduction method | 7.12.3 | Verilator 5.052 |  |
| [`test_illegal_reduction_and_with_real_expression`](../../tests/ch7/test_illegal_reduction_and_with_real_expression.sv) | with a with clause, a reduction method needs its operation to be defined for the type of the with expression, so and() with a real expression is illegal | 7.12.3 | standard only | illegal design |
| [`test_array_map_method`](../../tests/ch7/test_array_map_method.sv) | The map() array method returns an array with the same range or keys whose elements are the with expression for each element, using item or a named iterator and its index, with the self-determined type of the expression | 7.12.5 7.12 | standard only |  |
| [`test_map_result_to_same_array`](../../tests/ch7/test_map_result_to_same_array.sv) | The result of map() can be assigned back to the array it is called on, a dynamic array or a queue | 7.12.5 | Verilator 5.052 |  |

## Generated by `generators/wide_paths.py`

14 tests; see "Generated tests" in the suite's README.

| Test | What it checks | Clauses | Expected output recorded with | Notes |
| --- | --- | --- | --- | --- |
| [`test_gen_wide_select_w127_2state`](../../tests/gen/ch7/test_gen_wide_select_w127_2state.sv) | Part-selects and packed array selects of 127-bit 2-state values | 7.4.1 7.4.5 11.5.1 | Verilator 5.052 |  |
| [`test_gen_wide_select_w127_4state`](../../tests/gen/ch7/test_gen_wide_select_w127_4state.sv) | Part-selects and packed array selects of 127-bit 4-state values | 7.4.1 7.4.5 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_wide_select_w128_2state`](../../tests/gen/ch7/test_gen_wide_select_w128_2state.sv) | Part-selects and packed array selects of 128-bit 2-state values | 7.4.1 7.4.5 11.5.1 | Verilator 5.052 |  |
| [`test_gen_wide_select_w128_4state`](../../tests/gen/ch7/test_gen_wide_select_w128_4state.sv) | Part-selects and packed array selects of 128-bit 4-state values | 7.4.1 7.4.5 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_wide_select_w129_2state`](../../tests/gen/ch7/test_gen_wide_select_w129_2state.sv) | Part-selects and packed array selects of 129-bit 2-state values | 7.4.1 7.4.5 11.5.1 | Verilator 5.052 |  |
| [`test_gen_wide_select_w129_4state`](../../tests/gen/ch7/test_gen_wide_select_w129_4state.sv) | Part-selects and packed array selects of 129-bit 4-state values | 7.4.1 7.4.5 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_wide_select_w200_2state`](../../tests/gen/ch7/test_gen_wide_select_w200_2state.sv) | Part-selects and packed array selects of 200-bit 2-state values | 7.4.1 7.4.5 11.5.1 | Verilator 5.052 |  |
| [`test_gen_wide_select_w200_4state`](../../tests/gen/ch7/test_gen_wide_select_w200_4state.sv) | Part-selects and packed array selects of 200-bit 4-state values | 7.4.1 7.4.5 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_wide_select_w63_2state`](../../tests/gen/ch7/test_gen_wide_select_w63_2state.sv) | Part-selects and packed array selects of 63-bit 2-state values | 7.4.1 7.4.5 11.5.1 | Verilator 5.052 |  |
| [`test_gen_wide_select_w63_4state`](../../tests/gen/ch7/test_gen_wide_select_w63_4state.sv) | Part-selects and packed array selects of 63-bit 4-state values | 7.4.1 7.4.5 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_wide_select_w64_2state`](../../tests/gen/ch7/test_gen_wide_select_w64_2state.sv) | Part-selects and packed array selects of 64-bit 2-state values | 7.4.1 7.4.5 11.5.1 | Verilator 5.052 |  |
| [`test_gen_wide_select_w64_4state`](../../tests/gen/ch7/test_gen_wide_select_w64_4state.sv) | Part-selects and packed array selects of 64-bit 4-state values | 7.4.1 7.4.5 11.5.1 | Icarus Verilog 13.0 | x/z |
| [`test_gen_wide_select_w65_2state`](../../tests/gen/ch7/test_gen_wide_select_w65_2state.sv) | Part-selects and packed array selects of 65-bit 2-state values | 7.4.1 7.4.5 11.5.1 | Verilator 5.052 |  |
| [`test_gen_wide_select_w65_4state`](../../tests/gen/ch7/test_gen_wide_select_w65_4state.sv) | Part-selects and packed array selects of 65-bit 4-state values | 7.4.1 7.4.5 11.5.1 | Icarus Verilog 13.0 | x/z |
