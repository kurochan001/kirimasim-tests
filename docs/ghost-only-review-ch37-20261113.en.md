<a id="ghost-only-review-ch37-2026-11-13"></a>

# Review of the tests that only Ghost passes: Clause 37 (2026-11-13)

[English](ghost-only-review-ch37-20261113.en.md) / [日本語](ghost-only-review-ch37-20261113.md)

Some tests match their expected output on Ghost and on no other tool.
Nothing independent has confirmed the expectation of such a test.
This record gives the result of comparing 193 of them, the tests of Clause 37 (the VPI object model), with IEEE 1800-2023.
The verdicts come from the standard alone; no simulator output was used.
No test was changed in this review.

<a id="what-was-reviewed"></a>

## What was reviewed

- In the Nightly of 2026-11-12, 756 tests pass on Ghost alone: 193 in Clause 37, 90 in Clause 16, 44 in Clause 32, 41 in Clause 38, 37 in Clause 39, 35 in Clause 40 and 34 in Clause 31. This record covers the 193 tests of Clause 37.
- Two reviews read all 193 tests without seeing each other's results. Each derived the output from the design and the C code, compared it with the expected output and gave one verdict per test.
- Where the two verdicts differ, and where a verdict depends on the arrows of a diagram, the diagrams of the standard were read. The text that the reviews used does not show the direction and number of the arrows.
- All reviews were made by AI. They are not an independent human review.

<a id="verdicts"></a>

## Verdicts

| Verdict | Tests |
|---|---:|
| The expectation is right | 142 |
| The expectation is wrong | 4 |
| The test is flawed | 26 |
| The test depends on a gap in the standard | 4 |
| The reading is contested | 17 |
| Total | 193 |

The two reviews agreed on "right" for 125 tests.
Of the other 68, 17 were found right after the diagrams were read.

<a id="wrong"></a>

## The four wrong expectations

All four expect the type `vpiBitSelect` for a bit of a net or of a variable. Both reviews agree.

| Test | Clauses | What is wrong |
|---|---|---|
| `ch37/test_vpi_constant_select` | 37.17, 37.58, Annex K | It expects the type `vpiBitSelect` for the bits `v[3]` and `v[i]` of a logic variable. By 37.17 a bit of a variable is a var bit (`vpiVarBit`). In the diagram of 37.58 the parents of a bit select are var select, integer var, time var, parameter and spec param only. |
| `ch37/test_vpi_simple_expr_uses` | 37.16, 37.58, Annex K | It expects `vpiBitSelect` for the bit `v[1]` of a vector net. By 37.16 it is a net bit (`vpiNetBit`). The last expected line changes. |
| `ch37/test_vpi_statement_kinds` | 37.16, 37.58, 37.79 | The left side `w[1]` of the force and the release is a bit of a vector net, a net bit. The two lines that print "bit-select" change. |
| `ch37/test_vpi_systf_argument_expressions` | 37.17, 37.58, Annex K | The bits `r[1]` and `r[0]` of `reg [7:0] r` are var bits (`vpiRegBit`). The two lines that print `vpiBitSelect` change. `test_vpi_type_strings` of the same chapter expects `vpiRegBit` for `r[2]`. |

<a id="flawed"></a>

## The 26 flawed tests

Most of their expected values follow the standard, but the test depends on something the standard leaves open, or its C code or design does not follow the standard.

| Test | Clauses | What is flawed |
|---|---|---|
| `ch37/test_vpi_case_loop_force_stmts` | 37.12, 37.72 | It prints the results of the `vpiStmt` iteration of a block and of the `vpiCaseItem` iteration without sorting. The standard fixes neither order. |
| `ch37/test_vpi_prefix_has_actual` | 37.12, 37.61 | The order of the lines depends on an unsorted `vpiStmt` iteration. The values are right. |
| `ch37/test_vpi_property_sequence_exprs` | 37.56 | It prints the results of the `vpiClockedSeq` iteration without sorting. 37.56 fixes no order. |
| `ch37/test_vpi_class_internal_scopes` | 38.11, 37.41 | It passes two results of `vpi_get_str` to one call. By 38.11 every result is in one buffer. It also takes `vpiClassTypespec` from a method scope, a relation that the diagram of 37.41 does not show. |
| `ch37/test_vpi_interconnect_net_typespec` | 38.11 | It passes several results of `vpi_get_str` to one `vpi_printf`. The expectation for the object model follows 37.24. |
| `ch37/test_vpi_io_direction_undefined` | 38.11, 37.13 | It passes two results of `vpi_get_str` to one call. Whether "undefined" in detail 3 of 37.13 means `vpiUndefined` (-1) can also be read both ways. |
| `ch37/test_vpi_local_connectivity_ports` | 38.11, 37.16 | It passes two results of `vpi_get_str` to one call. The sets follow detail 17 of 37.16. |
| `ch37/test_vpi_frame_automatics_thread` | 37.43, 37.44, 38.11 | It expects the `vpiOrigin` of a thread to be the statement being executed, but 37.44 does not define its meaning. It expects a parent frame for an initial block that is not a scope. It uses two results of `vpi_get_str` at once. |
| `ch37/test_vpi_relationships_and_tags` | 38.15 | It prints a string obtained from `vpi_get_value` after further calls of `vpi_get_value`. By 38.15 the string buffer is overwritten with each call. |
| `ch37/test_vpi_class_obj_id` | 38.6, 38.7, 37.32 | `vpiObjId` is a 64-bit property, but it is read with `vpi_get`. It prints the name of a class typespec that is a specialization, which is tool-dependent (detail 4 of 37.32). |
| `ch37/test_vpi_class_definitions` | 37.32 | It expects the name `shape` for the class typespec reached from extends. The standard does not fix this name (minor). |
| `ch37/test_vpi_cont_assign_rhs_and_load` | 37.47 | It expects the `vpiBit` iteration of a scalar continuous assignment to return one bit. The standard defines bits for a vector assignment only. It reads `vpiSize` of a cont assign bit, which the diagram does not list. |
| `ch37/test_vpi_control_statement_child_relations` | 37.73, 37.50 | It reaches the property of an expect statement with `vpiProperty`. The relation of 37.73 has no tag, so the access is `vpiPropertySpec`. |
| `ch37/test_vpi_handle_release_independence` | 38.36.1 | It registers `cbValueChange` without a time structure. 38.36.1 requires the time type to be set. |
| `ch37/test_vpi_frames_threads_alloc` | 38.36.1 | It registers `cbCreateObj` and `cbEndOfObject` without a value structure (minor). The expected values follow the standard. |
| `ch37/test_vpi_net_array_members_parents` | 37.16 | It reads `vpiPackedArrayMember` on array nets, logic nets and an integer net and expects 0. Detail 2 of 37.16 defines it only for the elements inside a packed array. |
| `ch37/test_vpi_ref_obj_actual_port_insts` | 37.14, 37.10 | It applies `vpiParent` to a port to get its instance. In 37.14 `vpiParent` leads from a port bit to its port. It iterates `vpiTask` from the module, where 37.10 gives task func. |
| `ch37/test_vpi_scope_lifetimes` | 37.32, 37.10 | It takes `vpiClassTypespec` from a class defn with `vpi_handle`. By detail 10 of 37.32 it is an iteration. It looks up packages by a name without `::`. |
| `ch37/test_vpi_interface_modport_links` | 37.8 | It takes `vpiTask` from an interface tf decl with `vpi_handle`. The diagram of 37.8 is one-to-many, which needs `vpi_iterate`. |
| `ch37/test_vpi_interface_program` | 37.8, 37.13 | It also takes `vpiTask` and `vpiFunction` with `vpi_handle`. Whether the imports and exports of a modport are io decls is not settled by 37.13 either. |
| `ch37/test_vpi_system_call_decompile` | 37.42, 37.59 | It compares the `vpiDecompile` strings down to the spelling of constants. The standard requires a functionally equivalent string and does not fix how a constant is written. |
| `ch37/test_vpi_variable_driver_load_arrays` | 10.6.2, 37.21 | It forces a bit-select of a variable, which 10.6.2 forbids. The array lines rest on a "should" in detail 2 of 37.21. |
| `ch37/test_vpi_property_instance_links` | 16.16 | The assertion `a2` has no clock, and there is neither a default clocking nor an inferred clock. By rule f of 16.16 the design is illegal. |
| `ch37/test_vpi_module_relations` | Annex E | It uses `` `default_decay_time``. Annex E is informative, and its directives are not part of the standard. |
| `ch37/test_vpi_root_lookup_restrictions` | 37.10, 26.7 | It expects 2 objects from the `vpiInstance` iteration from NULL. The standard does not say whether the built-in package `std` is among them. |
| `ch37/test_vpi_let_decl_body` | 37.57, 37.58 | It expects a `vpiName` for the references to formals inside the let body. The standard does not say what object such a reference is. |

C code that uses two or more results of `vpi_get_str` in one call exists in other tests of Clause 37 too.
A rough search found 29 C files of Clause 37. They will be checked in the next review.

<a id="standard-gap"></a>

## The four tests that depend on a gap in the standard

The diagram and detail 10 of 37.10 and detail 6 of 37.85 show the iteration to the nettype declarations with the tag `vpiNetTypedef`.
The header of Annex M has no such constant. It has `vpiNettypeDecl` and `vpiNetTypedefAlias`.
These four tests iterate with `vpiNettypeDecl` instead, an iteration that the standard does not define.
Once a declaration is reached, the expected values follow 37.23.

- `ch37/test_vpi_nettype_declarations`
- `ch37/test_vpi_nettype_alias_chain_relations`
- `ch37/test_vpi_nettype_relations`
- `ch37/test_vpi_generate_nettype_typedef`

<a id="contested"></a>

## The 17 contested tests

The text of the standard allows two readings, and the expectation follows one of them.

| Test | Clauses | What is contested |
|---|---|---|
| `ch37/test_vpi_atomic_task_call_label` | 37.60, 37.42 | Detail 1 of 37.60 makes the `vpiName` of a statement its label. The diagram of 37.42 gives a tf call a `vpiName` for the called name. |
| `ch37/test_vpi_cont_assign_bits_delays` | 37.3.4, 37.16 | The text of 37.3.4 gives nets `vpiDelay`. The diagram of 37.16 has no `vpiDelay` relation. |
| `ch37/test_vpi_module_paths` | 37.39, Annex K | Whether `vpiModPathHasIfNone` is true for the path declared with ifnone or for the conditional path that has an ifnone default is not settled. |
| `ch37/test_vpi_prefix_allocation` | 37.61, 37.3.7 | Detail 2 of 37.61 gives the scheme of the prefix; 37.3.7 makes a part of a class object dynamic. The comment of the test records the conflict. |
| `ch37/test_vpi_size_change_callback` | 37.17 | Whether the string still has its old value inside the size-change callback is not settled by detail 14 of 37.17. |
| `ch37/test_vpi_unbounded_const_ranges` | 37.52, A.2.10 | The last line depends on whether the leading clock belongs to the property spec or forms a clocked property. |
| `ch37/test_vpi_property_operator_kinds` | 37.52, A.2.10 | For the same reason the two lines of `p_clk` and `p_clk2` change. |
| `ch37/test_vpi_attribute_value_types` | 5.12, 38.15 | `vpiObjTypeVal` of an attribute with a string literal can be a vector or a string. |
| `ch37/test_vpi_interconnect_array_ranges` | 23.3.3.7.1, 6.6.8 | Whether an interconnect array that is connected nowhere is legal can be read both ways. |
| `ch37/test_vpi_iterator_objects` | 37.2.2, 38.38, 38.40 | The result of the release depends on whether an iterator is still valid after it returned its last object. |
| `ch37/test_vpi_named_event_relations` | 37.27 | 37.27 does not say that the full name of an element of a named event array carries its indices. Nets and variables have such a rule. |
| `ch37/test_vpi_named_events` | 37.27 | For the same reason the `vpiName` `lane[1]` of an element is not settled. |
| `ch37/test_vpi_net_driver_objects` | 37.16, 37.47 | Whether the driver of a net bit is the cont assign bit or the whole continuous assignment is not settled. |
| `ch37/test_vpi_nettype_net_parts` | 37.16 | Whether an array element of a nettype net is `vpiNettypeNet` or `vpiNettypeNetSelect` is not settled by detail 11. |
| `ch37/test_vpi_select_objects_event_arrays` | 37.17, 37.19 | Whether an element of an array variable is a var select or a variable of its type differs between details 7, 18 and 26 of 37.17. |
| `ch37/test_vpi_statement_control_kinds` | 37.60, 9.3.5 | Three lines depend on whether a labelled statement stays a statement or becomes a named block. |
| `ch37/test_vpi_tf_call_kinds_relations` | 37.42, 15.4 | One line depends on whether the methods of mailbox are built-in or declared methods of a class of package `std`. |

<a id="figures"></a>

## What the diagrams settled

For these tests one of the reviews gave no verdict or called the test flawed. The diagram shows the relation, so the expectation is right.

| Test (without `ch37/test_vpi_`) | Clauses | What the diagram shows |
|---|---|---|
| module_instance_relations, program_relations | 37.6, 37.9 | A double arrow leads from the instance array to the interface and to the program, so `vpiInterface` and `vpiProgram` iterate them. |
| gen_scope_data_items, gen_scope_instance_items | 37.85 | An arrow leads back from each item to the gen scope. |
| scope_item_back_relations, process_kinds_relations | 37.12, 37.63 | Arrows lead back from each item and from a statement to the scope, and from a statement to its process. |
| typespec_instance_ranges, typespec_kinds_more | 37.25 | There is a double arrow from the instance to the typespec and an arrow back from the enum const to the enum typespec. |
| constraint_expr_contents | 37.34 | An arrow leads back from the dist item to the distribution. |
| tchk_relations_path_delays | 37.40 | An arrow leads back from the tchk term to the tchk. |
| thread_parent_children_frame | 37.44 | Thread and frame are one-to-one, and a double arrow leads from the circle to the thread. |
| clocking_decl_relations, clocking_edges_prefix | 37.48 | An arrow leads back from each declaration to the clocking block, and `vpiOutputSkew` of an io decl leads to an expr. |
| virtual_interface_init_parent | 37.30 | An arrow leads back from the param assign to the interface typespec. |
| constraint_properties | 37.31 | A double arrow leads from the circle to the class defn, so it is iterated from NULL. |
| union_net_tagged, struct_union_net_flags | 37.26 | tagged and soft are inside the frame that encloses struct net and union net. |

<a id="next"></a>

## What happens next

- The four wrong tests and the 26 flawed tests will be corrected when Ghost's results are saved again. A correction now would stop Ghost's saved passes from counting.
- The four tests of the gap in the standard and the 17 contested tests wait for a decision.
- A few tests cite a wrong clause number (for example 37.75 for continuous assignments and 37.80 for primitives; the right ones are 37.47 and 37.35). They will be corrected with the changes above.
- The coverage figures are unchanged.
