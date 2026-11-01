<a id="lyra-と一致しない規格のみのテストの見直し2026-10-25"></a>

# Review of standard-only tests disagreeing with Lyra (2026-10-25)

[English](lyra-disagreement-review-20261025.en.md) / [日本語](lyra-disagreement-review-20261025.md)

[Differences between simulators and the standard](simulator-differences.md) / [How to view Nightly results](nightly-results.en.md) / [Procedure book](requirements-to-tests-method.en.md)

Lyra is used as a comparison simulator in nightly runs, rather than for `:oracle:` (Sections 7.1 and 12 of [Procedure book](requirements-to-tests-method.en.md)). The results were used as a reason to revise the expected values.

The scope is the 194 tests that Lyra (fixed commit `7e2c604b9ab2`) could execute but that did not produce the expected results, out of 1,314 tests whose expected values are based on the standard alone (`:oracle: spec`). Used the scheduled nightly results from 2026-10-25 ([Run 40135271002](https://github.com/kurochan001/kirimasim-tests/actions/runs/40135271002), suite commit `c87448b`). kirimasim results are also shown alongside. However, Lyra and kirimasim share the slang frontend, so their agreement on parsing or elaboration is not independent corroboration.

<a id="まとめ"></a>

## Summary

|Classification|Test count|Results of the review|
| --- | ---: | --- |
|Output disagreements| 65 |Faulty test judgments in 2 tests (listed below; fixed). The other errors were due to the lack of implementation or errors on the Lyra side, and all the expected values were correct in the verified rules.|
|Rejecting standard code (compilation error)| 28 |Most are slang diagnostics. Every case checked had a correct test; slang was too strict.|
|Acceptance of standard-violating code| 86 |No simulator rejects the design at the expected location. The only reason is to verify AI, so it is a priority to review.|
|Internal error crash| 10 |Lyra side problem|
|Illegal code rejected at a different location| 5 |Lyra side problem|

No test found the expected output to be incorrect.

<a id="見つかったテストの不備判定の正規表現が書式に依存している"></a>

## Test defect found: the assessment regex depends on formatting

`:expected_stderr_regex:` in the following 2 tests requires `error` to precede the location (`ファイル:行:`) on the same line. This is the format used by Icarus Verilog (`ERROR: ファイル:行: …`) and Verilator (`%Error: ファイル:行: …`). kirimasim and Lyra are the formats of clang (`ファイル:行: error: …`), with the location coming first. The message format of severity tasks is left to the tool (20.10). The commentary of the test also says that "the text is not compared."

|Test| `:oracle:` |Status|
| --- | --- | --- |
| `ch16/test_deferred_assertion_default_error` | `spec` |kirimasim reports errors only on lines 43 and 44 as expected, but formatting causes a mismatch. The same applies to Lyra|
| `ch16/test_immediate_assertion_default_error` | `spec verilator@5.052` |Same writing. Neither Lyra nor kirimasim implements `$assertcontrol`, so these cases are not yet listed.|

On 2026-10-25, corrected the regular expression to accept either order (either `error[^\n]*ファイル:行:` or `ファイル:行:[^\n]*error`). The required and forbidden lines are not changed. I have also corrected the comments, so that the line numbers do not move.

- Reran 2 tests with Icarus Verilog 13.0 and Verilator 5.052 (seed 1/73), recorded in `coverage/results/regex-refinement-20261025-*.json`.
- `test_immediate_assertion_default_error` matches Verilator 5.052 as described in `:oracle:`. All 2 tests on Icarus 13.0 remain known.
- `test_deferred_assertion_default_error` now agrees on kirimasim.
- The ledger’s 3 rationales citing the regex line, and their input hashes, were refreshed.

<a id="規格で確かめた規則"></a>

## Rules checked against the standard

For the following output mismatches and rejections of standard-compliant code, checked the standard's text and concluded that the tests and expected values are correct.

|Test|Rationale|Judgment|
| --- | --- | --- |
| `ch11/test_conditional_real_shortreal_branch_promotion` | 11.4.11、6.12 |shortreal is single precision, hence 16777216.0. Lyra and kirimasim retain double precision|
| `ch4/test_reactive_region_set_order` | 4.5 |Active regions are processed first, so the module side records first|
| `ch6/test_string_atoreal_scan_rules` | 6.16.10、5.7.2 |We can use the underline of the real constant 10.25|
|4 tests, including `atoi("-12")`| 6.16.9 |atoi does not interpret a sign, so the result is 0. kirimasim behaves as expected|
| `ch19/test_option_member_defaults` | 19.7.1 |Of covergroup type options, only real_interval becomes a coverpoint default|
|`ch11/test_stream_item_order_struct_union_object_assoc` and 1 tests| 11.4.14.1 |Non-bit-stream structures, unions and classes also have rules for ordering their elements. The slang diagnostic that it is not a bit-stream type is too strict.|
| `ch11/test_concatenation_pattern_string_operand_and_replication` | 11.4.12.2 |If there is a string operand, the other is implicitly converted to a string|
|3 interconnect tests| 6.6.8、23.3.3.7.2 |The interconnect is used for terminal connections and net_alias.|

The 12 config-test mismatches occur because Lyra does not implement config; the 28 timing-check mismatches occur because Lyra does not implement timing checks.

<a id="一覧"></a>

## List

<a id="出力の不一致65本"></a>

### Output inconsistency (65 tests)

|Test| kirimasim |Results for Lyra|
| --- | --- | --- |
| `ch11/test_conditional_real_shortreal_branch_promotion` |Mismatch| line 1 is '3.5 1.5 1.0 16777217.0 16777217.0', expected '3.5 1.5 1.0 16777216.0 16777217.0' |
| `ch16/test_deferred_assertion_default_error` |Mismatch| no message matches '(?i)\\A(?![\\s\\S]*test_deferred_assertion_default_error\\.sv:34:)(?=[\\s\\S]*error[^\\n]*… |
| `ch18/test_disable_soft_direct_reference` |Unsupported| line 1 is 'ok=1 x=2 y=7 size=3 n=3', expected 'ok=1 x=2 y=7 size=3 n=5' |
| `ch18/test_rand_mode_array_element` |Unsupported| line 3 is 'modes after a.rand_mode(0)=001', expected 'modes after a.rand_mode(0)=000' |
| `ch18/test_soft_priority_layers` |Unsupported| line 4 is 'container over held object: h1.v=3', expected 'container over held object: h1.v=7' |
| `ch19/test_cg_bins_value_resolution` |Unsupported| line 2 is 'p1=7 p2=3: cp1 0.00, cp2 0.00', expected 'p1=7 p2=3: cp1 50.00, cp2 50.00' |
| `ch19/test_cg_coverpoint_type_resolution` |Unsupported| line 1 is 'v=4: 50.00', expected 'v=4: 25.00' |
| `ch19/test_cg_derived_option_override` |Unsupported| line 2 is 'derived: at_least 1, auto_bin_max 4, cp 0/4', expected 'derived: at_least 1, auto_bin_max 4, cp 1/4… |
| `ch19/test_cg_warned_bin_elements_removed` |Unsupported| line 1 is 'u=2: cs 2/6, ct 0/1', expected 'u=2: cs 0/2, ct 0/1' |
| `ch19/test_cg_zero_denominator_items` |Unsupported| line 2 is 'cz: inst 100.00 (0/0), type 0.00', expected 'cz: inst 100.00 (0/0), type 100.00' |
| `ch19/test_option_member_defaults` |Unsupported| line 17 is '  real_interval 1.00', expected '  real_interval 0.25' |
| `ch20/test_associative_array_query_functions` |Unsupported| line 1 is 'a4: left=0 right=15 low=2 high=9 increment=15 size=2', expected 'a4: left=0 right=15 low=2 high=9 i… |
| `ch23/test_empty_named_connection_ignores_default` |Unsupported| line 1 is "omitted: 0111, .q(): xxxx, .q(4'h3): 0011, ordered and em...", expected "omitted: 0111, .q(): zzzz,… |
| `ch25/test_interface_specify_terminal` |Unsupported| line 1 is 't=12: o=1', expected 't=12: o=0' |
| `ch31/test_timing_check_conditions_timestamps_and_notifiers` |Unsupported| line 1 is 't=16 setup=0 hold=0 z=z', expected 't=16 setup=1 hold=1 z=z' |
| `ch31/test_timing_condition_forms_x_lsb` |Unsupported| line 1 is 'en:', expected 'en: 20' |
| `ch31/test_timing_conditioned_event` |Unsupported| line 1 is 'end: notifier=0', expected '30: notifier=1' |
| `ch31/test_timing_edge_control_specifier` |Unsupported| line 1 is 'edge[01] notifier:', expected 'edge[01] notifier: 40:1' |
| `ch31/test_timing_edge_descriptors_all` |Unsupported| line 1 is 'edge[01]:', expected 'edge[01]: 11' |
| `ch31/test_timing_fullskew_event_based` |Unsupported| line 1 is 'timer-based:', expected 'timer-based: 15 48' |
| `ch31/test_timing_nochange` |Unsupported| line 1 is 'd inside: offsets 0 and 0: 0, offsets 2 and -1: 0', expected 'd inside: offsets 0 and 0: 1, offsets… |
| `ch31/test_timing_nochange_offset_directions` |Unsupported| line 1 is 'd at 25: (0,0) 0 (0,2) 0 (-2,0) 0 (2,0) 0 (0,-2) 0', expected 'd at 25: (0,0) 1 (0,2) 1 (-2,0) 1 (2… |
| `ch31/test_timing_nochange_window_endpoints` |Unsupported| line 1 is 'end: n1=0 n2=0', expected '15: n1=1' |
| `ch31/test_timing_notifier_x_and_z` |Unsupported| line 2 is 'after the first violation: nx known:  no, nz=z', expected 'after the first violation: nx known: yes… |
| `ch31/test_timing_recovery_removal_recrem` |Unsupported| line 1 is '$recovery:', expected '$recovery: 12 90' |
| `ch31/test_timing_recrem_all_arguments` |Unsupported| line 1 is '42: rst_n=0 drst=z clk=1 dclk=z', expected '42: rst_n=0 drst=0 clk=1 dclk=1' |
| `ch31/test_timing_recrem_windows` |Unsupported| line 1 is missing, expected '10: n=1' |
| `ch31/test_timing_setup_hold_notifier` |Unsupported| line 1 is missing, expected '20: setup notifier=1 hold notifier=0' |
| `ch31/test_timing_setuphold` |Unsupported| line 1 is 'limits 3 and 2:', expected 'limits 3 and 2: 20 21 40' |
| `ch31/test_timing_setuphold_all_arguments` |Unsupported| line 1 is '30: clk=0 dclk=z d=1 dd=z', expected '30: clk=0 dclk=0 d=1 dd=1' |
| `ch31/test_timing_setuphold_as_setup_and_hold` |Unsupported| line 1 is '$setuphold:', expected '$setuphold: 20 30 41 60 61' |
| `ch31/test_timing_skew_checks` |Unsupported| line 1 is '$skew:', expected '$skew: 27 34 50' |
| `ch31/test_timing_skew_dormant_and_restart` |Unsupported| line 2 is '$timeskew, no data event:', expected '$timeskew, no data event: 15' |
| `ch31/test_timing_skew_simultaneous_and_expiry` |Unsupported| line 1 is '$skew limit 0:', expected '$skew limit 0: 21' |
| `ch31/test_timing_stability_windows_and_endpoints` |Unsupported| line 2 is 't=26 setup=0 hold=0 removal=0 recovery=0', expected 't=26 setup=1 hold=1 removal=1 recovery=1' |
| `ch31/test_timing_timeskew_flags` |Unsupported| line 1 is 'timer-based:', expected 'timer-based: 25' |
| `ch31/test_timing_timeskew_remain_active` |Unsupported| line 1 is 'without remain_active_flag:', expected 'without remain_active_flag: 50' |
| `ch31/test_timing_vector_hold` |Unsupported| line 1 is 'notifier changes:', expected 'notifier changes: 11:1 13:0' |
| `ch31/test_timing_vector_signal` |Unsupported| line 1 is 'notifier changes:', expected 'notifier changes: 105:1 115:0 125:1' |
| `ch31/test_timing_width_period_notifier` |Unsupported| line 1 is missing, expected '23: width notifier=1 period notifier=0' |
| `ch31/test_timing_width_threshold_limit_edges` |Unsupported| line 1 is '$width limit 5 threshold 2:', expected '$width limit 5 threshold 2: 33 44' |
| `ch31/test_timing_window_endpoints_zero_limits` |Unsupported| line 1 is '$setup limit 3:', expected '$setup limit 3: 30' |
| `ch33/test_config_binding_descends_through_children` |Mismatch| line 2 is 'test_config_binding_descends_through_children.m2.u_leaf: ...', expected 'test_config_binding_descen… |
| `ch33/test_config_cell_parameter` |Mismatch| line 1 is 'u1=1 u2=1', expected 'u1=5 u2=5' |
| `ch33/test_config_defparam_precedence` |Passed| line 1 is 'm.P=5 m.c.Q=6', expected 'm.P=9 m.c.Q=6' |
| `ch33/test_config_design_top` |Passed| line 1 is 'cfg_stray elaborated', expected 'top: test_config_design_top' |
| `ch33/test_config_design_two_tops` |Passed| line 1 is 'cfg2_stray is a top-level module', expected 'test_config_design_two_tops is a top-level module' |
| `ch33/test_config_hierarchical` |Mismatch| line 1 is 'm1 leaf: aa, m2 leaf: aa', expected 'm1 leaf: aa, m2 leaf: bb' |
| `ch33/test_config_instance_deep_path` |Passed| line 1 is 'm1.leaf=aa m2.leaf=aa leaf=aa', expected 'm1.leaf=aa m2.leaf=bb leaf=aa' |
| `ch33/test_config_instance_use` |Passed| line 1 is 'u1=aa u2=aa', expected 'u1=aa u2=bb' |
| `ch33/test_config_library_binding_format` |Passed| line 3 is 'test_config_library_binding_format.u2.show: work.cfg_lib_a', expected 'test_config_library_binding_… |
| `ch33/test_config_parameter_override` |Passed| line 1 is 'WIDTH=16', expected 'WIDTH=32' |
| `ch33/test_config_use_config_suffix` |Mismatch| line 1 is 'm1 leaf: aa, m2 leaf: aa', expected 'm1 leaf: aa, m2 leaf: bb' |
| `ch33/test_config_use_without_library` |Passed| line 1 is 'u1=aa u2=aa u3=cc', expected 'u1=aa u2=bb u3=dd' |
| `ch35/test_dpi_put_user_data_error_result` |Unsupported| line 1 is 'svPutUserData with NULL user data: 0', expected 'svPutUserData with NULL user data: -1' |
| `ch4/test_reactive_region_set_order` |Mismatch| line 3 is 'program: v changed to 1', expected 'module: v changed to 1' |
| `ch6/test_string_ato_integer_scan_rules` |Passed| line 9 is 'atoi("-12")=-12', expected 'atoi("-12")=0' |
| `ch6/test_string_atoreal_scan_rules` |Mismatch| line 2 is 'atoreal("1_0.2_5")=1.000', expected 'atoreal("1_0.2_5")=10.250' |
| `ch6/test_string_conversion` |Passed| line 1 is missing, expected 'PASS: String conversion methods' |
| `ch6/test_string_edge` |Passed| line 1 is "FAIL: atoi('-999') should be 0, got -999", expected 'PASS: String edge cases' |
| `ch6/test_string_functions_comprehensive` |Passed| line 36 is '  FAIL: "-456".atoi() = -456 (expected 0)', expected '  PASS: "-456".atoi() = 0' |
| `ch6/test_string_ops_edge_cases` |Passed| line 16 is 'Test 16 FAIL: atoi of "-100" = -100 (expected 0)', expected 'Test 16 PASS: atoi of "-100" = 0' |
| `ch7/test_assoc_array_unknown_index` |Unsupported| line 1 is "aa[3'bzzz] = a8", expected "aa[3'bzzz] = xx" |
| `ch7/test_assoc_invalid_write_reports_diagnostic` |Unsupported| no message matches '(?i:\\bwarn(?:ing)?\\b\|%Warning-)' |
| `ch7/test_assoc_missing_read_reports_diagnostic` |Unsupported| no message matches '(?i:\\bwarn(?:ing)?\\b\|%Warning-)' |

<a id="規格上正しいコードを拒否28本"></a>

### Rejects standard-compliant code (28 tests)

|Test| kirimasim |Results for Lyra|
| --- | --- | --- |
| `ch11/test_concatenation_pattern_string_operand_and_replication_once` |Mismatch| cannot mix strings and integers in a concatenation (use a cast if this is desired) [-Wstring-int-concat] |
| `ch11/test_stream_item_order_struct_union_object_assoc` |Mismatch| stream expression type 'su_t' is not a bit-stream type |
| `ch11/test_stream_unpack_consumes_left_converts_state_keeps_objects` |Mismatch| stream expression type 'pk_c' is not a bit-stream type |
| `ch16/test_cover_property_restrict` |Unsupported| expected a declaration name |
| `ch16/test_named_sequence_scopes_and_instances` |Mismatch| expected ';' |
| `ch16/test_nexttime_always_eventually_alignment` |Mismatch| assertion expression does not have a unique leading clock |
| `ch16/test_triggered_matched_multiclock` |Mismatch| multiclocked sequence operands cannot be combined with any sequence operators other than ##1 and ##0 |
| `ch16/test_untyped_formal_arguments` |Unsupported| expected assertion item construct port declaration |
| `ch17/test_checker_context_inference` |Unsupported| no inferred clock in this context |
| `ch17/test_checker_package_context` |Unsupported| no inferred clock in this context |
| `ch19/test_cg_inheritance_args_and_cross` |Mismatch| redefinition of 'vf' [-Wredefinition] |
| `ch21/test_evcd_dumpports_files_defaults_and_control_scope` |Mismatch| no implicit conversion from 'logic[472:1]' to 'string'; explicit conversion exists, are you missing a cast? |
| `ch21/test_evcd_dumpportslimit_named_by_variables` |Mismatch| no implicit conversion from 'logic[400:1]' to 'string'; explicit conversion exists, are you missing a cast? |
| `ch23/test_interconnect_primitive_broadcast_input` |Mismatch| cannot reference interconnect net 'connection' outside of a net port connection |
| `ch23/test_interconnect_primitive_terminal` |Mismatch| cannot reference interconnect net 't' outside of a net port connection |
| `ch25/test_interface_abstract_methods_and_broadcast` |Mismatch| cannot access 'value' via modport 'am_bus.caller' |
| `ch32/test_sdf_mtm_spec` |Unsupported| empty argument not allowed |
| `ch32/test_sdf_scale_factors` |Unsupported| empty argument not allowed |
| `ch32/test_sdf_scale_type_members` |Unsupported| empty argument not allowed |
| `ch35/test_dpi_canonical_partsel_get_keeps_bits` |Unsupported| linking the program failed |
| `ch35/test_dpi_dynamic_array_actual` |Unsupported| value of type 'int$[$]' cannot be assigned to type 'int$[]' |
| `ch6/test_interconnect_net_alias` |Unsupported| cannot reference interconnect net 'src' outside of a net port connection |
| `ch6/test_nettype_alias_resolution_and_empty_drivers` |Mismatch| user-defined nettype 'voltage' of the port does not match 'alias_two' of the connection |
| `ch6/test_nettype_rename_matches` |Mismatch| user-defined nettype 'volt_net' of the port does not match 'volt_alias' of the connection |
| `ch6/test_nettype_resolution` |Mismatch| force and release cannot be applied to nets with a user-defined nettype |
| `ch6/test_user_nettype_resolution_forms` |Mismatch| net 'arr' with user-defined nettype cannot be partially driven |
| `ch7/test_assoc_narrow_prev_next_overflow` |Mismatch| argument of type 'bit[7:0]' connects to 'ref' port of inequivalent type 'int' |
| `ch7/test_assoc_traversal_narrow_index` |Mismatch| argument of type 'bit[7:0]' connects to 'ref' port of inequivalent type 'int' |

<a id="規格違反のコードを受理86本優先して見直す対象"></a>

### Accepts standard-violating code (86 tests; priority review targets)

|Test| kirimasim |Results for Lyra|
| --- | --- | --- |
| `ch10/test_illegal_force_mixed_driven_variable` |Mismatch| the design was accepted, but it is illegal |
| `ch10/test_illegal_lhs_assignment_pattern_member_width` |Unsupported| the design was accepted, but it is illegal |
| `ch10/test_illegal_typed_lhs_assignment_pattern_member_width` |Unsupported| the design was accepted, but it is illegal |
| `ch10/test_illegal_user_nettype_assignment_two_delays` |Unsupported| the design was accepted, but it is illegal |
| `ch11/test_illegal_stream_with_on_two_dimensional_array` |Unsupported| the design was accepted, but it is illegal |
| `ch12/test_illegal_for_type_reference_without_var` |Mismatch| the design was accepted, but it is illegal |
| `ch12/test_illegal_pattern_constant_of_real_type` |Unsupported| the design was accepted, but it is illegal |
| `ch13/test_illegal_constant_function_call_in_constant_context` |Mismatch| the design was accepted, but it is illegal |
| `ch14/test_illegal_clocking_output_variable_force` |Unsupported| the design was accepted, but it is illegal |
| `ch14/test_illegal_clocking_output_variable_procedural_assign` |Unsupported| the design was accepted, but it is illegal |
| `ch15/test_illegal_mailbox_peek_unpacked_array` |Unsupported| the design was accepted, but it is illegal |
| `ch15/test_illegal_mailbox_put_unpacked_array` |Unsupported| the design was accepted, but it is illegal |
| `ch15/test_illegal_mailbox_try_get_unpacked_array` |Unsupported| the design was accepted, but it is illegal |
| `ch15/test_illegal_mailbox_try_peek_unpacked_array` |Unsupported| the design was accepted, but it is illegal |
| `ch15/test_illegal_mailbox_try_put_unpacked_array` |Unsupported| the design was accepted, but it is illegal |
| `ch16/test_illegal_assertion_clocking_input_not_1step` |Unsupported| the design was accepted, but it is illegal |
| `ch16/test_illegal_assertion_function_keeps_state` |Unsupported| the design was accepted, but it is illegal |
| `ch16/test_illegal_assertion_function_side_effect` |Unsupported| the design was accepted, but it is illegal |
| `ch16/test_illegal_attached_call_chandle_input` |Unsupported| the design was accepted, but it is illegal |
| `ch16/test_illegal_cycle_delay_mintypmax` |Unsupported| the design was accepted, but it is illegal |
| `ch16/test_illegal_deferred_assertion_const_ref_dynamic_actual` |Mismatch| the design was accepted, but it is illegal |
| `ch16/test_illegal_local_variable_implicit_type` |Unsupported| the design was accepted, but it is illegal |
| `ch16/test_illegal_local_variable_unassigned_compound_assignment` |Unsupported| the design was accepted, but it is illegal |
| `ch16/test_illegal_nonoverlapping_antecedent_no_match` |Unsupported| the design was accepted, but it is illegal |
| `ch16/test_illegal_sequence_event_formal_as_boolean` |Unsupported| the design was accepted, but it is illegal |
| `ch16/test_illegal_sequence_formal_chandle_type` |Unsupported| the design was accepted, but it is illegal |
| `ch16/test_illegal_sequence_formal_goto_operand` |Unsupported| the design was accepted, but it is illegal |
| `ch16/test_illegal_triggered_ending_clock_differs` |Unsupported| the design was accepted, but it is illegal |
| `ch17/test_illegal_checker_covergroup_constant_actual` |Unsupported| the design was accepted, but it is illegal |
| `ch22/test_illegal_begin_keywords_without_end` |Mismatch| the design was accepted, but it is illegal |
| `ch22/test_illegal_include_absolute_path_in_angle_brackets` |Mismatch| the design was accepted, but it is illegal |
| `ch22/test_illegal_line_directive_trailing_comment` |Mismatch| the design was accepted, but it is illegal |
| `ch23/test_illegal_interconnect_left_after_elaboration` |Unsupported| the design was accepted, but it is illegal |
| `ch24/test_illegal_anonymous_program_hierarchical_reference` |Mismatch| the design was accepted, but it is illegal |
| `ch25/test_illegal_generic_interface_port_dot_name` |Mismatch| the design was accepted, but it is illegal |
| `ch25/test_illegal_interface_port_actual_through_generate_block` |Mismatch| the design was accepted, but it is illegal |
| `ch25/test_illegal_interface_port_actual_through_instance_array` |Mismatch| the design was accepted, but it is illegal |
| `ch25/test_illegal_modport_import_default_argument_without_prototype` |Mismatch| the design was accepted, but it is illegal |
| `ch25/test_illegal_modport_import_from_module_without_prototype` |Unsupported| the design was accepted, but it is illegal |
| `ch25/test_illegal_modport_import_named_binding_without_prototype` |Mismatch| the design was accepted, but it is illegal |
| `ch25/test_illegal_modport_prototype_unnamed_named_binding` |Mismatch| the design was accepted, but it is illegal |
| `ch3/test_illegal_unit_prefix_forward_reference` |Mismatch| the design was accepted, but it is illegal |
| `ch30/test_illegal_edge_parallel_path_part_select_destination` |Unsupported| the design was accepted, but it is illegal |
| `ch30/test_illegal_edge_parallel_path_vector_destination` |Unsupported| the design was accepted, but it is illegal |
| `ch30/test_illegal_pulsestyle_ondetect_after_path` |Unsupported| the design was accepted, but it is illegal |
| `ch30/test_illegal_pulsestyle_onevent_after_path` |Unsupported| the design was accepted, but it is illegal |
| `ch30/test_illegal_showcancelled_after_path` |Unsupported| the design was accepted, but it is illegal |
| `ch30/test_illegal_specify_edge_path_part_and_bit_select` |Unsupported| the design was accepted, but it is illegal |
| `ch30/test_illegal_specify_edge_path_same_edge_and_condition` |Unsupported| the design was accepted, but it is illegal |
| `ch30/test_illegal_specify_ifnone_with_unconditional_path` |Unsupported| the design was accepted, but it is illegal |
| `ch31/test_illegal_hold_limit_negative` |Unsupported| the design was accepted, but it is illegal |
| `ch31/test_illegal_recovery_limit_negative` |Unsupported| the design was accepted, but it is illegal |
| `ch31/test_illegal_removal_limit_negative` |Unsupported| the design was accepted, but it is illegal |
| `ch31/test_illegal_setup_limit_negative` |Unsupported| the design was accepted, but it is illegal |
| `ch31/test_illegal_timing_condition_two_signals` |Unsupported| the design was accepted, but it is illegal |
| `ch33/test_illegal_config_constant_function` |Mismatch| the design was accepted, but it is illegal |
| `ch33/test_illegal_config_design_is_config` |Mismatch| the design was accepted, but it is illegal |
| `ch33/test_illegal_config_generate_scope_path` |Mismatch| the design was accepted, but it is illegal |
| `ch33/test_illegal_config_hierarchical_name_in_expression` |Mismatch| the design was accepted, but it is illegal |
| `ch33/test_illegal_config_index_not_literal` |Mismatch| the design was accepted, but it is illegal |
| `ch33/test_illegal_config_instance_array_path` |Mismatch| the design was accepted, but it is illegal |
| `ch33/test_illegal_config_instance_inside_other_config` |Mismatch| the design was accepted, but it is illegal |
| `ch33/test_illegal_config_package_binding` |Mismatch| the design was accepted, but it is illegal |
| `ch5/test_illegal_method_implicit_variable_without_parentheses` |Mismatch| the design was accepted, but it is illegal |
| `ch5/test_illegal_string_hex_escape_z_digit` |Mismatch| the design was accepted, but it is illegal |
| `ch5/test_illegal_string_octal_escape_z_digit` |Mismatch| the design was accepted, but it is illegal |
| `ch6/test_illegal_chandle_event_control` |Unsupported| the design was accepted, but it is illegal |
| `ch6/test_illegal_initial_block_variable_initializer_no_keyword` |Mismatch| the design was accepted, but it is illegal |
| `ch6/test_illegal_net_type_reg_in_port_declaration` |Mismatch| the design was accepted, but it is illegal |
| `ch6/test_illegal_nettype_resolver_resizes_driver_array` |Unsupported| the design was accepted, but it is illegal |
| `ch6/test_illegal_nettype_resolver_side_effect` |Unsupported| the design was accepted, but it is illegal |
| `ch6/test_illegal_nettype_resolver_writes_driver_array` |Unsupported| the design was accepted, but it is illegal |
| `ch6/test_illegal_static_task_variable_initializer_no_keyword` |Mismatch| the design was accepted, but it is illegal |
| `ch6/test_illegal_type_operator_dynamic_array_element` |Mismatch| the design was accepted, but it is illegal |
| `ch6/test_illegal_type_parameter_scope_prefix_in_variable` |Unsupported| the design was accepted, but it is illegal |
| `ch7/test_illegal_dynamic_array_to_dpi_open_output` |Unsupported| the design was accepted, but it is illegal |
| `ch7/test_illegal_integral_index_with_real` |Unsupported| the design was accepted, but it is illegal |
| `ch7/test_illegal_integral_index_with_shortreal` |Unsupported| the design was accepted, but it is illegal |
| `ch7/test_illegal_string_in_untagged_union` |Unsupported| the design was accepted, but it is illegal |
| `ch7/test_illegal_union_holding_struct_member_default` |Mismatch| the design was accepted, but it is illegal |
| `ch7/test_illegal_unique_index_without_with_struct_elements` |Unsupported| the design was accepted, but it is illegal |
| `ch7/test_illegal_unique_without_with_struct_elements` |Unsupported| the design was accepted, but it is illegal |
| `ch7/test_illegal_wildcard_array_find` |Unsupported| the design was accepted, but it is illegal |
| `ch8/test_illegal_interface_method_default_not_constant` |Unsupported| the design was accepted, but it is illegal |
| `ch8/test_illegal_interface_typedef_scope_prefix_in_variable_declaration` |Unsupported| the design was accepted, but it is illegal |
| `ch8/test_illegal_type_parameter_scope_prefix_in_variable_declaration` |Unsupported| the design was accepted, but it is illegal |

<a id="内部エラークラッシュ10本"></a>

### Internal errors/crashes (10 tests)

|Test| kirimasim |Results for Lyra|
| --- | --- | --- |
| `ch11/test_equality_class_interface_chandle_handles` |Unsupported| error: internal error: FoldIntegral: the integral operation wildcard_equal is built over no integral value whe… |
| `ch16/test_recursive_properties` |Unsupported| error: internal error: LowerPropertyExpr: the front end reports a malformed assertion expression rather than h… |
| `ch18/test_unique_array_slice_single` |Unsupported| error: internal error: access path: only an element and a component may be passed by reference (LRM 13.5.2), a… |
| `ch19/test_cg_cross_with_expression` |Unsupported| error: internal error: ProcessLowerer::DeclareProceduralVar: procedural variable symbol already mapped (in uni… |
| `ch19/test_cg_option_levels_readback` |Unsupported| error: internal error: mir verify: '__declare_type' of class 'cg' in unit 'test_cg_option_levels_readback', as… |
| `ch29/test_udp_instance_array_delays` |Passed| crashed (signal 11) |
| `ch29/test_udp_instance_strength_and_array_range` |Unsupported| crashed (signal 11) |
| `ch3/test_name_spaces` |Passed| error: internal error: hir::DesignElementOf: a unit that is instantiated is a design element (in unit 'test_na… |
| `ch35/test_dpi_context_scope_of_declaration` |Unsupported| error: internal error: AST-\>HIR call: the scope declaring this DPI import is not on the current scope stack (i… |
| `ch8/test_super_new_default` |Unsupported| crashed (signal 11) |

<a id="規格違反のコードを別の場所で拒否5本"></a>

### Illegal code rejected at a different location (5 tests)

|Test| kirimasim |Results for Lyra|
| --- | --- | --- |
| `ch16/test_illegal_property_instance_flattened_not_legal` |Mismatch| no error matches 'test_illegal_property_instance_flattened_not_legal\\.sv:30:'; the first is: ../..27:5: error… |
| `ch16/test_illegal_recursive_property_negated` |Mismatch| no error matches 'test_illegal_recursive_property_negated\\.sv:32:'; the first is: ../..29:33: error: recursiv… |
| `ch16/test_illegal_sequence_local_output_unassigned` |Mismatch| no error matches 'test_illegal_sequence_local_output_unassigned\\.sv:(29\|34):'; the first is: ../..28:37: err… |
| `ch25/test_illegal_modport_prototype_argument_count` |Mismatch| no error matches 'test_illegal_modport_prototype_argument_count\\.sv:30:'; the first is: ../..26:16: error: de… |
| `ch25/test_illegal_modport_prototype_type_not_matching` |Mismatch| no error matches 'test_illegal_modport_prototype_type_not_matching\\.sv:31:'; the first is: ../..27:32: error:… |
