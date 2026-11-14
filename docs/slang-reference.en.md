<a id="slang-reference"></a>

# slang reference

[English](slang-reference.en.md) / [日本語](slang-reference.md)

[Differences between simulators and the standard](simulator-differences.md) / [Nightly results](nightly-results.en.md) / [History](history.md)

`tools/run_slang.py` runs the slang driver on the tests of the suite.
The driver is built from the slang commit that kirimasim pins.
Its verdicts are a reference for diagnosis only. They are not counted anywhere.

<a id="purpose-and-limits"></a>

## Purpose and limits

The reference has two uses:

- To tell whether a kirimasim defect lies in slang or in kirimasim. kirimasim elaborates a design with slang, then adds checks and runs it.
- To find legal tests that slang rejects, as candidates for test errors.

Its limits:

- kirimasim and Lyra both use slang as their front end. So slang never confirms an expectation on its own, and it is not an oracle. It is not in `:oracle:`, the coverage figures, the Nightly workflow, the results branch or the READMEs.
- An illegal test counts as rejected at the line when slang reports an error on the line that `:expected_stderr_regex:` names. The reason is not compared, as with the other runners. For example, slang rejects `ch21/test_illegal_dumpports_duplicate_scope` at line 25 because `m` is used as a value, not because the scope is named twice.
- For a legal test, "clean" means only that slang elaborates it without an error. slang does not simulate.
- slang does not load the C code of `:vpi_c:`. That code registers system tasks such as `$vt_...`, so slang rejects most VPI tests. The tool marks them, and the counts keep them apart.
- The options are those of kirimasim's front end (`src/front/front.cpp`). kirimasim also chooses the first config as the top when no `--top` is given, and it has checks of its own after slang. So slang alone can accept what kirimasim rejects.
- The slang commit follows kirimasim's pin. When kirimasim changes the pin, build the new commit and make a new dated record. The commit of Lyra's slang was not checked.

<a id="build-the-pinned-driver"></a>

## Build the pinned driver

kirimasim builds slang as a library only (`SLANG_INCLUDE_TOOLS=OFF`), so its build has no driver.
The driver is the target `slang_driver` of slang (output `bin/slang`).
Build it from the sources that a kirimasim `dev` build has already fetched. The network is not used.

```sh
K=<kirimasim checkout with build/dev>
D=$K/build/dev/_deps
grep -A3 'FetchContent_Declare(' $K/cmake/Dependencies.cmake | grep GIT_TAG   # the pin
git -C $D/slang-src rev-parse HEAD                                            # must be the same
cmake -S $D/slang-src -B slang-build -G Ninja -DCMAKE_BUILD_TYPE=Release \
  -DSLANG_INCLUDE_TOOLS=ON -DSLANG_INCLUDE_TESTS=OFF -DSLANG_INCLUDE_INSTALL=OFF \
  -DFETCHCONTENT_TRY_FIND_PACKAGE_MODE=NEVER -DFETCHCONTENT_FULLY_DISCONNECTED=ON \
  -DFETCHCONTENT_SOURCE_DIR_FMT=$D/fmt-src -DFETCHCONTENT_SOURCE_DIR_BOOST_REGEX=$D/boost_regex-src \
  -DFETCHCONTENT_SOURCE_DIR_MIMALLOC=$D/mimalloc-src -DFETCHCONTENT_SOURCE_DIR_TOMLPLUSPLUS=$D/tomlplusplus-src
ninja -C slang-build slang_driver
```

On a Mac with 18 cores this takes about 3 seconds to configure and 96 seconds to build.
`slang --version` prints only `slang version 12.1.0+0`, so the commit is given to the tool.

<a id="run-the-tool"></a>

## Run the tool

```sh
python3 tools/run_slang.py --slang slang-build/bin/slang \
  --commit 8ffdcdd8ad237823fbfd72d495082d76e92d4015 -j 12 \
  --json coverage/slang/slang-8ffdcdd8-20261114.json
```

- Without test arguments it runs every test that is not `:type: formal`, as the other runners do.
- slang gets `--std=1800-2023 -Wno-error=index-oob -Wno-error=string-int-concat -Wno-error=string-in-constraint --threads 1 -q`. The sources of `:files:` come before the test, the include directories and `:incdirs:` go as `-I`, `:defines:` as `-D` and `:top_module:` as `--top`. `:args:` is not used. Since 2026-11-11, a test with `:compilation_unit: single` also gets `--single-unit`, as it needs use model a) of 3.12.1; without the option slang takes each file as its own compilation unit.
- An illegal test is `rejected_at_line`, `rejected_elsewhere` or `accepted`, judged by `suite_results.judge_illegal`. A legal test is `clean` or `rejected`, with slang's first error. A test with `:vpi_c:` has `"vpi": true`.
- The record has the slang commit, the suite commit, the date, the options, the hash of the tool and, for each test, the verdict, the first error and the input fingerprint. Files are named relative to the repository.
- Records go to `coverage/slang/`, not `coverage/results/`. The coverage tools read every `coverage/results/*.json` as the results of a simulator, and no tool reads `coverage/slang/`.
- The Nightly workflow does not run the tool. `tools/results_history.py` draws only simulators that have results in the history, and slang has none.
- The whole suite takes about 95 seconds with `-j 12`, including the input fingerprints.

<a id="results-of-2026-11-14"></a>

## Results of 2026-11-14

slang `8ffdcdd8ad237823fbfd72d495082d76e92d4015`, the pin of kirimasim since 2026-11-13 (`d1d8a1782d0a` and `77c27531437c` use it), on suite commit `4ac30898`.
The record is [`coverage/slang/slang-8ffdcdd8-20261114.json`](../coverage/slang/slang-8ffdcdd8-20261114.json).
The driver was built from the sources of a kirimasim `dev` build as [above](#build-the-pinned-driver); `slang --version` prints `slang version 12.1.659+8ffdcdd8a`.
No test timed out or crashed.

| Tests | Verdicts | Count |
| --- | --- | ---: |
| Illegal | rejected at the marked line / elsewhere / accepted | 1,915 / 0 / 147 |
| Legal without `:vpi_c:` | clean / rejected | 9,633 / 56 |
| Legal with `:vpi_c:` | clean / rejected | 148 / 354 |

Compared with the record of 2026-11-09:

- No test whose inputs are unchanged got another verdict.
- Two legal tests that slang rejected are now clean, both because the tests changed: `ch3/test_compilation_unit_shared_across_files` gets `--single-unit` since 2026-11-11, and `ch18/test_inline_local_scope_binding` compares with `local::r.r` since 2026-11-14.
- Of the 283 tests added since, slang accepts 5 illegal ones and rejects 8 legal ones. kirimasim, which uses the same slang, gives the same results on them, as recorded with the tests:
  - accepted illegal designs: `ch11/test_illegal_let_chandle_typed_formal`, `ch15/test_illegal_mailbox_get_unpacked_array`, `ch25/test_illegal_virtual_interface_component_in_always_event_control`, `ch25/test_illegal_virtual_interface_component_in_always_ff`, `ch8/test_illegal_super_parameter_in_packed_dimension`;
  - rejected legal designs: `ch6/test_interconnect_declaration_generic_forms` (an interconnect declared with a type), `ch9/test_always_without_timing_control_never_advances_time` (an always procedure without a timing control taken as a deadlock error), `ch13/test_function_return_type_handle_categories` (a member access through a virtual interface returned by a function), and the two cases `gen/ch24/test_gen_cross_progmod_nested_one_{absolute,upward}_defparam_*` (a nested program with parameters is not instantiated implicitly, so its path does not resolve);
  - the three new VPI tests stop at a system task that their C code registers, like 348 before.
- The removed `ch18/test_illegal_constraint_function_cycle` was one of the 143 accepted illegal tests.
- Of the 147 accepted illegal tests, 11 have an Icarus Verilog 13.0 or Verilator oracle and 136 are spec only. The count of 2026-11-09 (43) is not comparable, since the oracle tokens were reviewed on 2026-11-12.

The triage below is that of 2026-11-09; the new rejections above were not triaged again.

<a id="results-of-2026-11-09"></a>

## Results of 2026-11-09

slang `6fbb158f156436a1cb4d0ce9de5373a416a05d4c`, the pin of kirimasim `2b05349e` (2026-11-08), on suite commit `6f4bc48b`.
The record is [`coverage/slang/slang-6fbb158f-20261109.json`](../coverage/slang/slang-6fbb158f-20261109.json).
No test timed out or crashed.

<a id="illegal-tests"></a>

### Illegal tests

| Verdict | Tests |
| --- | ---: |
| Rejected at the marked line | 1,833 |
| Rejected elsewhere | 0 |
| Accepted | 143 |
| Total | 1,976 |

43 of the 143 accepted tests have an Icarus Verilog 13.0 or Verilator 5.052 oracle, and 100 are spec only.

<a id="legal-tests"></a>

### Legal tests

| Tests | Clean | Rejected | Total |
| --- | ---: | ---: | ---: |
| Without `:vpi_c:` | 9,472 | 53 | 9,525 |
| With `:vpi_c:` | 148 | 351 | 499 |

- 348 of the 351 rejected VPI tests stop at a system task that their C code registers (`$vt_...` 343, `$depth_...` 4, `$Depth$probe_7` 1).
- The other three were not reviewed: `ch37/test_vpi_interconnect_net_type_size` (the interconnect with a packed dimension, as in the triage below), `ch37/test_vpi_io_decl_scope_typespec_ports` (a virtual interface port) and `ch37/test_vpi_variable_driver_load_arrays` (the target of a force).
- The 53 others are triaged [below](#triage-of-legal-tests-that-slang-rejects).

<a id="illegal-tests-and-kirimasim-2b05349e"></a>

### Illegal tests and kirimasim 2b05349e

The 1,976 illegal tests were also run with `tools/run_kirimasim.py` on a `dev` build of kirimasim `2b05349e`.

| slang | kirimasim pass | kirimasim fail | kirimasim unsupported |
| --- | ---: | ---: | ---: |
| Rejected at the marked line | 1,829 | 2 | 2 |
| Accepted | 7 | 48 | 88 |

- Rejected by slang, failed by kirimasim (2): kirimasim exits with code 3 instead of 2, so the defect is after slang. `ch18/test_illegal_unique_tolerance_range` and `ch33/test_illegal_config_cell_library_liblist`.
- Rejected by slang, unsupported by kirimasim (2): kirimasim cannot load the C code of `:vpi_c:`. `ch36/test_36_extra_systf_name_dollar` and `ch36/test_36_extra_timing_check_not_systf`.
- Accepted by slang, passed by kirimasim (7): checks of kirimasim's own. `ch4/test_illegal_final_deferred_action_schedules_event`, `ch8/test_illegal_const_property_assigned_twice`, `ch8/test_illegal_instance_constant_assigned_twice`, `ch16/test_illegal_final_deferred_postponed_call`, `ch20/test_illegal_bits_function_dynamic_return`, `ch20/test_illegal_timeformat_unit_out_of_range` and `ch33/test_illegal_config_parameter_wildcard_import`.
- Accepted by slang and by kirimasim (48): candidates for a check that slang misses and kirimasim inherits. 12 of them have an Icarus or Verilator oracle (marked \*). They are listed below.
- Accepted by slang, unsupported by kirimasim (88, 30 with an oracle): kirimasim does not support a construct yet. Without a check of its own, it will accept these tests once it does.

| Chapter | Accepted by slang and by kirimasim |
| --- | --- |
| ch5 | `test_illegal_method_implicit_variable_without_parentheses`, `test_illegal_string_hex_escape_z_digit`, `test_illegal_string_octal_escape_z_digit` |
| ch6 | `test_illegal_chandle_event_control`, `test_illegal_initial_block_variable_initializer_no_keyword`, `test_illegal_net_type_reg_in_port_declaration`, `test_illegal_static_task_variable_initializer_no_keyword`, `test_illegal_type_operator_dynamic_array_element`\*, `test_illegal_type_parameter_scope_prefix_in_variable` |
| ch7 | `test_illegal_dynamic_new_nonblocking_assignment`\*, `test_illegal_union_holding_struct_member_default` |
| ch8 | `test_illegal_interface_method_default_not_constant`, `test_illegal_interface_typedef_scope_prefix_in_variable_declaration`\*, `test_illegal_type_parameter_scope_prefix_in_variable_declaration` |
| ch10 | `test_illegal_force_mixed_driven_variable` |
| ch11 | `test_illegal_unsized_constant_in_concatenation`\* |
| ch12 | `test_illegal_for_type_reference_without_var`\* |
| ch13 | `test_illegal_constant_function_call_in_constant_context` |
| ch16 | `test_illegal_deferred_assertion_const_ref_dynamic_actual` |
| ch19 | `test_illegal_cg_function_side_effect`, `test_illegal_cg_outer_constant`, `test_illegal_cg_ref_formal_expression`, `test_illegal_cg_ref_formal_variable` |
| ch20 | `test_illegal_isunbounded_variable` |
| ch21 | `test_illegal_display_strength_vector_net` |
| ch22 | `test_illegal_begin_keywords_without_end`, `test_illegal_directive_split_across_lines`\*, `test_illegal_include_absolute_path_in_angle_brackets`\*, `test_illegal_include_line_trailing_code`\*, `test_illegal_line_directive_trailing_comment` |
| ch23 | `test_illegal_defparam_array_sibling_instance`, `test_illegal_no_top_level_module`, `test_illegal_scope_duplicate_in_unselected_generate`\* |
| ch24 | `test_illegal_anonymous_program_hierarchical_reference`, `test_illegal_module_calls_program_task` |
| ch25 | `test_illegal_generic_interface_port_dot_name`, `test_illegal_interface_port_actual_through_generate_block`, `test_illegal_interface_port_actual_through_instance_array`, `test_illegal_modport_import_default_argument_without_prototype`, `test_illegal_modport_import_named_binding_without_prototype`, `test_illegal_modport_prototype_unnamed_named_binding` |
| ch26 | `test_illegal_package_imported_before_compiled`\* |
| ch33 | `test_illegal_config_constant_function`\*, `test_illegal_config_generate_scope_path`\*, `test_illegal_config_hierarchical_name_in_expression`, `test_illegal_config_index_not_literal`, `test_illegal_config_instance_array_path`, `test_illegal_config_package_binding` |

<a id="triage-of-legal-tests-that-slang-rejects"></a>

## Triage of legal tests that slang rejects

The 53 legal tests without `:vpi_c:` that slang rejects were read against IEEE 1800-2023.
An AI (Claude) did the triage; no test was changed.

| Verdict | Tests |
| --- | ---: |
| Test wrong | 1 |
| slang stricter than the standard | 48 |
| Unclear | 4 |

- kirimasim `2b05349e` passes none of the 53. It fails 45 with the same first error as slang, and it does not support the 8 DPI tests, as it cannot load C code.
- The saved results of the pinned simulators pass 12 of them, the 12 whose `:oracle:` lists Icarus Verilog 13.0 or Verilator 5.052. Icarus passes 8 and Verilator 8, and 4 of these pass on both. The last column of the table names them; it counts only saved results whose inputs are current.
- The "slang stricter" rows are candidates for reports to slang. None was filed.
- Note of 2026-11-11: `ch3/test_compilation_unit_shared_across_files` now states its use model with `:compilation_unit: single`, and `tools/run_slang.py` gives slang `--single-unit` for it. The fix that its row names is done, so the test is no longer classed "test wrong". The tables of this section and the record of 2026-11-09 are kept as they were. slang was not run again, so the record still has the test as rejected.

| Tests | Verdict | Clauses | Reason | Pass on pinned |
| --- | --- | --- | --- | --- |
| `ch3/test_compilation_unit_shared_across_files` | test wrong | 3.12.1 | Which files form one compilation unit is tool-specific; a tool shall offer both models, and slang (like kirimasim) takes one unit per file by default. The test claims the one-unit model as a rule. Fix: state in the test that it needs model a) of 3.12.1, and let the runners select it (slang has `--single-unit`), or keep it out of the default runs. | Icarus, Verilator |
| `ch3/test_declaration_across_file_boundary` | slang stricter | 3.12.1 | A declaration that is incomplete at the end of a file continues in the following files. | Icarus |
| `ch5/test_string_literal_cast_justification` | slang stricter | 5.9 | A string literal cast to an unpacked array follows the rules of the assignment (left justified). | none |
| `ch6/test_a2_1_3_interconnect_declaration_identifiers`<br>`ch6/test_interconnect_and_net_port_types` | slang stricter | 6.6.8, 23.3.3.7.1, A.2.1.3 | An interconnect may have a packed dimension, and a port connection merges it into a net of the type of the other net. | none |
| `ch6/test_nettype_alias_resolution_and_empty_drivers`<br>`ch6/test_nettype_declarations_and_user_nets`<br>`ch6/test_nettype_rename_matches` | slang stricter | 6.6.7, 6.22.6 | The second form of a nettype declaration gives another name to an existing nettype, with its resolution function, and a renaming nettype matches the original. | none |
| `ch6/test_nettype_resolution` | slang stricter | 6.6.7, 10.6.2 | A force statement can override the value of a net of a user-defined nettype. slang also rejects an alias with the resolution function, as above. | none |
| `ch6/test_user_nettype_resolution_forms` | slang stricter | 10.3, 6.6.7 | The left side may not select into the data type of the nettype; an element of an array of such nets is a whole net. slang also rejects an alias with the resolution function. | none |
| `ch7/test_assoc_narrow_prev_next_overflow`<br>`ch7/test_assoc_traversal_narrow_index` | slang stricter | 7.9.8 | An index argument of a smaller integral type is allowed: the method returns -1 and truncates. | none |
| `ch11/test_expr_timescale_constants` | slang stricter | 11.2.1, 20.4.1 | The timescale functions of 20.4 with constant arguments are constant system function calls. | none |
| `ch11/test_stream_item_order_struct_union_object_assoc`<br>`ch11/test_stream_unpack_consumes_left_converts_state_keeps_objects` | slang stricter | 11.4.14.1, 11.4.14.3 | A structure is streamed member by member, an untagged union by its first member and an object by its data members; an unpack skips null handles. | none |
| `ch13/test_ref_static_accepted_actuals` | slang stricter | 13.5.2 | A ref static argument may be passed members with static lifetime, such as a member of a module-level structure. | none |
| `ch14/test_default_clocking_nested_module_scope` | slang stricter | 14.12 | The scope of a default clocking includes the nested modules. | none |
| `ch16/test_named_sequence_scopes_and_instances` | slang stricter | 16.8 (Syntax 16-8) | The semicolon after the sequence expression is optional: `sequence_expr [ ; ]`. | none |
| `ch17/test_checker_always_statement_kinds` | unclear | 17.5, 17.7, 12.7.1 | 17.5 allows loop statements, but a variable declared in a for loop has automatic lifetime (12.7.1), and the variables of a checker body shall be static (17.7). Fix if wanted: declare the loop variable in the checker body. | Verilator |
| `ch17/test_checker_covergroup_sample` | slang stricter | 17.6, 17.5 | A covergroup in a checker may be triggered by a procedural call to its `sample()` method, and checker procedures may call subroutines. | Verilator |
| `ch18/test_inline_local_scope_binding` | unclear | 18.7.1 | The last rule, that `local::obj` binds to the scope of the class of `obj`, can name a member of the class (the test) or the handle itself (slang). Fix if wanted: move the `local::r` check to a test of its own, so that the other four checks do not depend on it. | none |
| `ch19/test_19_rest_set_visibility` | slang stricter | 19.5.1.2 | The identifiers declared in the covergroup are not visible in a set expression. | none |
| `ch19/test_cg_inheritance_args_and_cross` | slang stricter | 19.4.1 | A cross of the same name in the derived covergroup replaces the cross of the base. | none |
| `ch20/test_array_query_default_dimension_integer_result`<br>`ch20/test_array_query_invalid_dimension_all_x`<br>`ch20/test_array_query_types_and_invalid` | slang stricter | 20.7 | When the dimension is out of range, the array query functions return `'x`. | Icarus (`test_array_query_invalid_dimension_all_x`) |
| `ch21/test_evcd_dumpports_files_defaults_and_control_scope`<br>`ch21/test_evcd_dumpportslimit_named_by_variables`<br>`ch21/test_fopen_name_and_type_forms`<br>`ch21/test_plusargs_key_from_variable`<br>`ch21/test_vcd_dumpvars_all_filename_start` | slang stricter | 21.3.1, 21.6, 21.7.1.1, 21.7.3.1, 21.7.3.3, 21.7.3.4 | A file name, a file type and a plusarg string may be an integral value that holds characters. | Icarus, Verilator (`test_fopen_name_and_type_forms`)<br>Icarus, Verilator (`test_plusargs_key_from_variable`)<br>Icarus (`test_vcd_dumpvars_all_filename_start`) |
| `ch21/test_fread_unpacked_struct_union` | slang stricter | 21.3.4.4 | `$fread` reads an unpacked structure member by member and an unpacked union by its first member. | none |
| `ch22/test_ifdef_directive_names_not_defined` | unclear | 22.6, Annex B | Directive names count as not defined, but `include` is also a reserved keyword, and the condition is an identifier. Fix if wanted: use a directive name that is not a keyword, such as `undefineall`. | none |
| `ch23/test_23_extra_uwire_dominates`<br>`ch23/test_23_extra_uwire_warn`<br>`ch23/test_port_collapse_trireg_and_uwire_cells`<br>`ch23/test_port_collapse_uwire_external_delay`<br>`ch23/test_port_collapse_uwire_supply`<br>`ch23/test_port_collapse_wand_uwire_warning`<br>`ch23/test_port_collapse_wor_uwire_warning` | slang stricter | 6.6.2, 23.3.3.6, 23.3.3.7 | A uwire may be an inout port or connect to one. The errors are for more than one driver and for a bidirectional pass switch, and a port whose nets are not merged gives a warning. | Verilator (`test_port_collapse_uwire_external_delay`)<br>Icarus, Verilator (`test_port_collapse_uwire_supply`) |
| `ch23/test_defparam_block_task_function_parameters` | slang stricter | 23.10.2, 6.20.1 | A parameter of a named block, task or function can be redefined only by defparam. Only the parameters directly in a design element with a parameter port list become local. | Icarus |
| `ch23/test_interconnect_primitive_broadcast_input`<br>`ch23/test_interconnect_primitive_terminal`<br>`ch23/test_interconnect_terminal_wire_resolution` | slang stricter | 6.6.8, 23.3.3.7.2 | An interconnect expresses net port and terminal connections; at a primitive or UDP terminal it is treated as a scalar wire. | none |
| `ch33/test_duplicate_cell_last_definition_wins` | unclear | 33.3.1.1, 3.13 | The standard disagrees with itself: 33.3.1.1 keeps the last cell with a warning, and 3.13 a) forbids using a module name again. Fix if wanted: keep the specific rule, as the suite does for such conflicts, and add a comment naming 3.13 a). | none |
| `ch35/test_dpi_dynamic_array_actual`<br>`gen/ch35/test_gen_cross_dpi_array_queue_inout_1_positive_descending_resize`<br>`gen/ch35/test_gen_cross_dpi_array_queue_inout_3_positive_ascending_resize`<br>`gen/ch35/test_gen_cross_dpi_array_queue_inout_5_positive_ascending_stable`<br>`gen/ch35/test_gen_cross_dpi_array_queue_input_1_mixed_ascending_stable`<br>`gen/ch35/test_gen_cross_dpi_array_queue_input_3_mixed_descending_stable`<br>`gen/ch35/test_gen_cross_dpi_array_queue_input_5_positive_ascending_resize` | slang stricter | 7.7, 35.6.1.1 | The rules of dynamic array and queue formals also govern DPI open arrays; only an output open array excludes a dynamic array or a queue. slang accepts the same calls of a function written in SystemVerilog. | none |
| `ch35/test_dpi_enum_base_type_representation` | slang stricter | 35.5.5, 35.5.6, H.7.3 | An enumeration is taken as its base type, and its base type decides whether it is a small value for 35.5.5. The list of 35.5.5 does not name enumerations. | Verilator |
