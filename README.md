# Nightly results of kirimasim-tests

The [nightly workflow](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml) of [kirimasim-tests](https://github.com/kurochan001/kirimasim-tests) writes this branch. Each night it runs every test of the suite's main branch with each simulator, adds the results to `history.json` and draws the charts below. Local runs can also be imported and are marked `local`. A test matches when its output and specified checks agree with the expected result, or an illegal design is rejected with the required diagnostic; see the suite's README for what each status means.

Latest run: 2026-10-31 02:16 UTC, suite commit [`73af6e9`](https://github.com/kurochan001/kirimasim-tests/commit/73af6e954828221c3c7447dd13cd3a271ae5bb55), 9203 tests, [workflow run](https://github.com/kurochan001/kirimasim-tests/actions/runs/41141958886).

## Latest results per simulator

Each row and chapter-table column uses that simulator's most recent recorded run. Dates, suite commits and test counts can differ; older results retain their own dates and are not treated as part of the latest run.

| Simulator | Version | Run (UTC) | Suite | Source | Match | Differ | Known differences | Unsupported |
| --- | --- | --- | --- | --- | ---: | ---: | ---: | ---: |
| Icarus Verilog | Icarus Verilog version 14.0 (devel) (s20260301-786-g5d048885) | 2026-10-31 02:16 | [`73af6e9`](https://github.com/kurochan001/kirimasim-tests/commit/73af6e954828221c3c7447dd13cd3a271ae5bb55) | nightly | 5701 (63.8%) | 15 | 3219 | 0 |
| Verilator | Verilator 5.053 devel rev v5.052-651-g92ac4051 | 2026-10-31 02:16 | [`73af6e9`](https://github.com/kurochan001/kirimasim-tests/commit/73af6e954828221c3c7447dd13cd3a271ae5bb55) | nightly | 5265 (58.9%) | 9 | 3661 | 0 |
| kirimasim | kirimasim 0.0.0 (commit 17b7192b4f05), built with GNU 13.3.0 | 2026-10-31 02:16 | [`73af6e9`](https://github.com/kurochan001/kirimasim-tests/commit/73af6e954828221c3c7447dd13cd3a271ae5bb55) | nightly | 6468 (72.4%) | 121 | 0 | 2346 |
| Lyra | Lyra (commit e13a017966a5) | 2026-10-31 02:16 | [`73af6e9`](https://github.com/kurochan001/kirimasim-tests/commit/73af6e954828221c3c7447dd13cd3a271ae5bb55) | nightly | 6933 (77.6%) | 463 | 0 | 1539 |
| Ghost | private build a20e2aaaee3a | 2026-10-31 02:16 | [`73af6e9`](https://github.com/kurochan001/kirimasim-tests/commit/73af6e954828221c3c7447dd13cd3a271ae5bb55) | nightly | 8036 (89.9%) | 899 | 0 | 0 |

Ghost is an unidentified simulator taking part before its public debut. For now, only its test results step out from behind the curtain. Its name, source and build logs remain private; build IDs are executable hashes.

![Tests that match their expected results](charts/overview.svg?v=20261031T021644)

![Share of the tests that match](charts/rate.svg?v=20261031T021644)

## Changes in the latest run

Tests that match now but did not in the previous run of the same simulator, and tests that matched then but do not now. Tests added to the suite are counted in the table above.

### Icarus Verilog

Newly match (5): `ch13/test_A_extra_tf_dims`, `ch23/test_23_extra_upward_data_stop`, `ch23/test_syntax_parameter_port_list_forms`, `ch26/test_package_empty_item_declaration`, `ch4/test_reactive_region_set_order`

### Verilator

Newly match (9): `ch14/test_syntax_clocking_drive_forms`, `ch18/test_illegal_constraint_foreach_dimensions`, `ch19/test_illegal_cg_function_side_effect`, `ch19/test_illegal_cg_outer_constant`, `ch19/test_illegal_cg_ref_formal_expression`, `ch19/test_illegal_cg_ref_formal_variable`, `ch19/test_illegal_cg_system_function`, `ch23/test_23_extra_upward_data_stop`, `ch8/test_class_scope_base_members_from_derived`

No longer match (3):

- `ch14/test_clocking_default_skew`: known difference — output differs: line 3 is '8: q=1', expected '8: q=0'
- `ch16/test_ch16_sim_prop_inherited_always`: known difference — output differs: line 1 is 'always a fails at: 25', expected 'always a fails at: 25 25 25'
- `ch19/test_19_rest_set_visibility`: known difference — build failed: %Error: /home/runner/work/kirimasim-tests/kirimasim-tests/tests/ch19/test_19_rest_set_visibility.sv:37:35: syntax error, unexpected IDENTIFIER-for-type

### kirimasim

Newly match (16): `ch11/test_expr_operand_categories`, `ch13/test_A_extra_tf_dims`, `ch14/test_clocking_block_event_after_nba_before_reactive`, `ch16/test_ch16_sim_cover_counters`, `ch17/test_illegal_checker_covergroup_constant_actual`, `ch18/test_illegal_constraint_foreach_dimensions`, `ch20/test_illegal_countbits_non_bitstream`, `ch20/test_illegal_dist_exponential_zero_mean`, `ch23/test_23_extra_upward_data_stop`, `ch4/test_reactive_region_set_order`, `gen/ch7/test_gen_cross_array_w129_s_l_da_z_s`, `gen/ch7/test_gen_cross_array_w1_u_l_aa_k_s`, `gen/ch7/test_gen_cross_array_w32_s_l_ad_x_s`, `gen/ch7/test_gen_cross_array_w33_u_b_dd_z_s`, `gen/ch7/test_gen_cross_array_w64_u_b_da_x_s`, `gen/ch7/test_gen_cross_array_w65_s_l_da_k_s`

### Lyra

Newly match (24): `ch13/test_A_extra_tf_dims`, `ch16/test_ch16_sim_cover_counters`, `ch16/test_ch16_sim_declaration_inert`, `ch16/test_ch16_sim_glitch_free`, `ch16/test_ch16_sim_prop_inherited_case`, `ch16/test_ch16_sim_prop_inherited_conditional`, `ch16/test_ch16_sim_reported_interval`, `ch17/test_illegal_checker_covergroup_constant_actual`, `ch18/test_illegal_constraint_foreach_dimensions`, `ch19/test_19_extra_cross_items`, `ch19/test_19_extra_option_comment`, `ch19/test_19_extra_option_cross_num_print_missing`, `ch19/test_19_extra_option_detect_overlap`, `ch19/test_19_extra_option_per_instance`, `ch19/test_19_extra_sample_method`, `ch19/test_19_extra_type_option_comment`, `ch19/test_19_extra_type_option_mutation`, `ch19/test_cg_illegal_value_error`, `ch20/test_illegal_countbits_non_bitstream`, `ch20/test_severity_task_argument_forms`, `ch23/test_23_extra_upward_data_stop`, `ch35/test_35_extra_35_5_1_6_cxx_linkage`, `ch4/test_reactive_region_set_order`, `ch7/test_queue_refs_outdated_by_bounded_push_and_assignment`

No longer match (1):

- `ch27/test_generate_recursive_module`: differ — crashed (signal 11)

### Ghost

Newly match (566): `ch10/test_alias_bidirectional_shared_drivers`, `ch10/test_assignment_delays_with_time_units`, `ch10/test_force_part_select_of_net`, `ch10/test_less_equal_token_by_context`, `ch10/test_unpacked_array_concat_rules`, `ch10/test_unpacked_concat_bounded_queue_overflow`, `ch11/test_A_extra_specparam_range`, `ch11/test_assignment_expression_concat_target_unsigned_sum_width`, `ch11/test_compound_assignment_index_evaluated_once`, `ch11/test_concatenation_pattern_string_operand_and_replication_once`, `ch11/test_conditional_real_shortreal_branch_promotion`, `ch11/test_constant_builtin_method_calls_at_elaboration`, `ch11/test_expr_conditional_ambiguous`, `ch11/test_expr_inside_set_forms`, `ch11/test_expr_tagged_union_access`, `ch11/test_expr_timescale_constants`, `ch11/test_inside_ranges_tolerance_unknown_and_types`, `ch11/test_inside_tolerance_ranges`, `ch11/test_let_binds_in_declaration_scope_local_and_package`, `ch11/test_precedence_distinguishing_values`, `ch11/test_precedence_logical_conditional_implication_levels`, `ch12/test_case_inside_evaluation_order_by_qualifier`, `ch12/test_for_shared_outer_control_variable`, `ch12/test_foreach_index_auto_cast_types`, `ch12/test_statement_item_forms`, `ch13/test_A_extra_tf_dims`, `ch13/test_a2_7_dynamic_override_specifiers`, `ch13/test_call_without_parentheses_subroutine_kinds`, `ch13/test_class_methods_always_automatic`, `ch13/test_constant_function_call_fresh_initial_values`, `ch13/test_default_argument_only_when_omitted`, `ch13/test_function_body_order_and_empty_body`, `ch13/test_function_directions_both_formal_styles`, `ch13/test_function_nonblocking_statements_no_delay`, `ch13/test_function_struct_return_member_or_scope`, `ch13/test_optional_parentheses_every_subroutine_kind`, `ch14/test_clocking_block_event_after_nba_before_reactive`, `ch14/test_clocking_block_per_instance_local_scope`, `ch14/test_clocking_drive_prefix_default_cycles_rhs_target_cycles`, `ch14/test_clocking_future_drive_in_re_nba`, `ch14/test_clocking_input_expression_skew`, `ch14/test_clocking_multiple_blocks`, `ch14/test_clocking_net_outputs_strong_drivers_resolved`, `ch14/test_clocking_output_part_select_skew`, `ch14/test_clocking_signal_hierarchical_slice_concat_inout_var`, `ch14/test_clocking_synchronous_events`, `ch14/test_clocking_zero_skew_drive_in_re_nba`, `ch14/test_cycle_delay_forms_and_zero_drive_delay`, `ch14/test_syntax_clocking_drive_forms`, `ch15/test_event_compare_arguments`, `ch15/test_event_null_waiter_queue`, `ch15/test_mailbox_typeless_try_type_check`, `ch15/test_semaphore_get_try_get_int_count_default_one`, `ch15/test_std_mailbox_default_type_parameter`, `ch15/test_wait_order_first_triggered`, `ch16/test_A_extra_assertion_items`, `ch16/test_ch16_sim_cover_counters`, `ch16/test_ch16_sim_declaration_inert`, `ch16/test_ch16_sim_glitch_free`, `ch16/test_ch16_sim_prop_inherited_always`, `ch16/test_ch16_sim_prop_inherited_case`, `ch16/test_ch16_sim_prop_inherited_conditional`, `ch16/test_ch16_sim_reported_interval`, `ch16/test_concurrent_assert_actions`, `ch16/test_concurrent_assertion_names_and_control`, `ch16/test_concurrent_boolean_truth_array_samples`, `ch16/test_default_disable_iff`, `ch16/test_deferred_assertion_disable_inner_scope`, `ch16/test_global_clock_past_functions_procedural_action`, `ch16/test_illegal_past_automatic_clock`, `ch16/test_illegal_past_automatic_gating`, `ch16/test_illegal_triggered_outside_local_formal`, `ch16/test_immediate_assert_syntax_actions`, `ch16/test_immediate_assertion_default_error`, `ch16/test_immediate_assertion_truth_and_actions`, `ch16/test_nexttime_always_eventually_alignment`, `ch16/test_property_declaration_and_argument_forms`, `ch16/test_property_nested_if_case`, `ch16/test_recursive_property_time_advance`, `ch16/test_sampled_value_functions_with_clocking_event`, `ch16/test_sequence_attached_call_kinds_order_region`, `ch16/test_sequence_default_actuals_and_name_scopes`, `ch16/test_sequence_empty_match_fusion`, `ch16/test_sequence_formal_reference_forms_and_types`, `ch16/test_sequence_repetition_and_concat_precedence`, `ch16/test_sequence_subroutine_call_arguments`, `ch16/test_static_assertions_start_every_tick`, `ch16/test_sva_typed_formal_assignment`, `ch16/test_zero_repetition_no_sample`, `ch17/test_checker_always_comb_latch_ff`, `ch17/test_checker_always_latch`, `ch17/test_checker_always_procedures`, `ch17/test_checker_always_statement_kinds`, `ch17/test_checker_assertion_sampling_as_module`, `ch17/test_checker_body_declaration_kinds`, `ch17/test_checker_concurrent_assertion`, `ch17/test_checker_covergroup`, `ch17/test_checker_generate_instance`, `ch17/test_checker_generate_state`, `ch17/test_checker_in_package` and 466 more

No longer match (5):

- `ch10/test_unpacked_concat_typed_array_and_string_item`: differ — output differs
- `ch17/test_illegal_checker_covergroup_in_procedure`: differ — the design was accepted, but it is illegal
- `ch19/test_cg_cross_select_bins`: differ — output differs
- `ch4/test_reactive_region_set_order`: differ — output differs
- `ch8/test_dynamic_cast`: differ — output differs (exit 2)

## By chapter

![Matching tests by chapter](charts/chapters.svg?v=20261031T021644)

## Each simulator over time

![Icarus Verilog: results by status](charts/status-icarus.svg?v=20261031T021644)

![Verilator: results by status](charts/status-verilator.svg?v=20261031T021644)

![kirimasim: results by status](charts/status-kirimasim.svg?v=20261031T021644)

![Lyra: results by status](charts/status-lyra.svg?v=20261031T021644)

![Ghost: results by status](charts/status-ghost.svg?v=20261031T021644)

## Recent runs

Matching tests of each simulator, with the change since its previous run. The version is shown when it changed.

| Run (UTC) | Suite | Tests | Icarus Verilog | Verilator | kirimasim | Lyra | Ghost |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| [2026-10-31 02:16](https://github.com/kurochan001/kirimasim-tests/actions/runs/41141958886) | [`73af6e9`](https://github.com/kurochan001/kirimasim-tests/commit/73af6e954828221c3c7447dd13cd3a271ae5bb55) | 9203 | 5701 (+199 −0) `14.0 devel 5d04888` | 5265 (+117 −3) `5.053 devel 92ac405` | 6468 (+360 −0) `17b7192b4` | 6933 (+397 −1) `e13a01796` | 8036 (+882 −5) `private build a20e2aaaee3a` |
| [2026-10-30 01:43](https://github.com/kurochan001/kirimasim-tests/actions/runs/40972765631) | [`360ef70`](https://github.com/kurochan001/kirimasim-tests/commit/360ef70c73218de1f44dd83c1cda24f60e242537) | 8779 | 5502 (+898 −3) `14.0 devel 6991445` | 5151 (+372 −0) `5.053 devel 453b02a` | 6108 (+1032 −0) `51cda3143` | 6537 (+1037 −1) `8eff7abdc` | 7159 (+1071 −7) `private build 2d76b598f1c1` |
| [2026-10-29 03:55](https://github.com/kurochan001/kirimasim-tests/actions/runs/40805499579) | [`a594d65`](https://github.com/kurochan001/kirimasim-tests/commit/a594d659b947a7321ce5e252660ea6d376d813b3) | 7744 | 4607 | 4779 `5.053 devel ad83990` | 5076 (+6 −0) `938d60c83` | 5501 (+9 −6) `ed9515d8e` | 6095 (+12 −0) `private build 5c1261cba4df` |
| [2026-10-29 00:48](https://github.com/kurochan001/kirimasim-tests/actions/runs/40786512421) | [`248cca8`](https://github.com/kurochan001/kirimasim-tests/commit/248cca894a2607eb6eae0bda3303dc1c7cb130a9) | 7744 | 4607 (+5 −1) `14.0 devel fd8759f` | 4779 (+3 −1) `5.053 devel 375685d` | 5070 (+17 −0) `df25891fa` | 5498 (+19 −0) | 6083 (+143 −3) `private build af267bf4f8b1` |
| [2026-10-28 09:54](https://github.com/kurochan001/kirimasim-tests/actions/runs/40657143465) | [`b83d0ff`](https://github.com/kurochan001/kirimasim-tests/commit/b83d0ffd666f533b0ce1c77f6cb5377fbbe0b511) | 7740 | 4603 (+4 −0) | 4777 (+14 −0) `5.053 devel 9440ae8` | 5053 (+8 −0) `a24202947` | 5479 (+5 −0) | 5943 (+9 −1) `private build 07c6cb0ee0df` |
| [2026-10-28 00:30](https://github.com/kurochan001/kirimasim-tests/actions/runs/40599008464) | [`41085fe`](https://github.com/kurochan001/kirimasim-tests/commit/41085fe3432bb093bf52c4f33bc4b44fff1a9401) | 7732 | 4599 (+64 −0) `14.0 devel d95f240` | 4763 (+120 −3) `5.053 devel c0b2894` | 5045 (+79 −3) `cfb76b386` | 5474 (+76 −0) | 5935 (+128 −16) `private build bdc4d9a56351` |
| [2026-10-27 16:21](https://github.com/kurochan001/kirimasim-tests/blob/3fe8d730711e1b773d39656dc13732ac644abae9/coverage/results/ghost-local-20261028.json) (local) | [`23b4c54`](https://github.com/kurochan001/kirimasim-tests/commit/23b4c54256d44cdaeabccde13b2a806fecee1927) | 7629 | — | — | — | — | 5823 `private build d59b7c7f8feb` |
| [2026-10-27 00:11](https://github.com/kurochan001/kirimasim-tests/actions/runs/40417919375) | [`1ff9998`](https://github.com/kurochan001/kirimasim-tests/commit/1ff999828c59ca24649bf722f6bfc46b70724520) | 7327 | 4535 (+39 −12) `14.0 devel 0accff4` | 4646 (+96 −4) `5.053 devel be33a0f` | 4969 (+103 −0) `1650064d2` | 5398 (+118 −0) | — |
| [2026-10-26 14:44](https://github.com/kurochan001/kirimasim-tests/actions/runs/40333187203) | [`5fb3c45`](https://github.com/kurochan001/kirimasim-tests/commit/5fb3c45d73e4946d99690389752b82c86eecaa50) | 7144 | 4508 (+152 −0) `14.0 devel 1d601c9` | 4554 (+167 −0) `5.053 devel 5dcc718` | 4866 (+174 −0) `5563871fc` | 5280 (+674 −1) | — |
| [2026-10-25 22:50](https://github.com/kurochan001/kirimasim-tests/actions/runs/40237581816) | [`eadc98d`](https://github.com/kurochan001/kirimasim-tests/commit/eadc98d6c452244167e267a46866808291771198) | 6799 | 4356 (+338 −0) `14.0 devel 49bebc9` | 4387 (+363 −0) `5.053 devel 7fa05ab` | 4692 (+458 −1) `a4f653c1d` | — | — |
| [2026-10-24 22:48](https://github.com/kurochan001/kirimasim-tests/actions/runs/40135271002) | [`c87448b`](https://github.com/kurochan001/kirimasim-tests/commit/c87448ba87b6b6ca136bf526b1ee8710efcb05a3) | 6009 | 4018 | 4024 (+1 −0) `5.053 devel 441c0df` | 4235 `c507631d2` | 4607 | — |
| [2026-10-24 12:44](https://github.com/kurochan001/kirimasim-tests/actions/runs/40084390631) | [`0073c69`](https://github.com/kurochan001/kirimasim-tests/commit/0073c6947bc210d7b928d0d651ef34d5095b5999) | 6009 | 4018 (+1298 −0) `14.0 devel 9cfecc9` | 4023 (+1202 −0) | 4235 (+1449 −0) `c0388da8a` | 4607 `7e2c604b9` | — |
| [2026-10-23 23:03](https://github.com/kurochan001/kirimasim-tests/actions/runs/40033104165) | [`721db37`](https://github.com/kurochan001/kirimasim-tests/commit/721db3743b9db84ecb14fa86a8165dbcff8fdb0d) | 3986 | 2720 (+1 −0) `14.0 devel 1a663cb` | 2821 (+19 −0) `5.053 devel 0041d20` | 2786 (+126 −0) `0d27da4e7` | — | — |
| [2026-10-22 23:07](https://github.com/kurochan001/kirimasim-tests/actions/runs/39865168055) | [`bc1609d`](https://github.com/kurochan001/kirimasim-tests/commit/bc1609dc005548ac6dd7848355b705983d7aacd5) | 3938 | 2719 (+108 −0) `14.0 devel e072b33` | 2802 (+144 −0) `5.053 devel bb916d0` | 2660 (+108 −0) `499198369` | — | — |
| [2026-10-21 22:46](https://github.com/kurochan001/kirimasim-tests/actions/runs/39686633157) | [`4752cea`](https://github.com/kurochan001/kirimasim-tests/commit/4752cea52e9dc0d24ef58240eddee11ef055c673) | 3719 | 2611 (+140 −0) `14.0 devel ce98681` | 2659 (+149 −0) `5.053 devel 019f1ca` | 2552 (+147 −0) `b27968d1f` | — | — |
| [2026-10-21 01:31](https://github.com/kurochan001/kirimasim-tests/actions/runs/39523323680) | [`0cfd00b`](https://github.com/kurochan001/kirimasim-tests/commit/0cfd00b58140ba628bb18a68e439933a07312fa2) | 3403 | 2471 (+36 −0) | 2512 (+35 −0) `5.053 devel 4c98f02` | 2405 (+61 −0) `7b2b17aa1` | — | — |
| [2026-10-21 01:02](https://github.com/kurochan001/kirimasim-tests/actions/runs/39507186309) | [`824f574`](https://github.com/kurochan001/kirimasim-tests/commit/824f5748dd619afaf472f60fd0ce83d0a547d829) | 3332 | 2435 (+857 −0) | 2477 (+549 −0) `5.053 devel 3cc4981` | 2344 (+754 −0) `0680c67d5` | — | — |
| [2026-10-20 07:49](https://github.com/kurochan001/kirimasim-tests/actions/runs/39387575855) | [`6bffc4a`](https://github.com/kurochan001/kirimasim-tests/commit/6bffc4a184134250ca4b934ef2b40af9961bc4d5) | 2327 | 1578 `14.0 devel 7e3d0c6` | — | 1590 `b1be7015e` | — | — |
| [2026-10-20 05:01](https://github.com/kurochan001/kirimasim-tests/actions/runs/39363555028) | [`56508cd`](https://github.com/kurochan001/kirimasim-tests/commit/56508cdce0a414ca1623756c6856dd1f49819977) | 2327 | 1578 (+56 −0) | 1928 (+103 −0) `5.053 devel 0177067` | 1590 (+60 −0) `ff80adcf6` | — | — |
| [2026-10-19 22:42](https://github.com/kurochan001/kirimasim-tests/actions/runs/39329365210) | [`42081bd`](https://github.com/kurochan001/kirimasim-tests/commit/42081bd73c354db73c20b1b17fb076975ae5a16f) | 2176 | 1522 `14.0 devel eed9291` | 1825 `5.053 devel 60f166e` | 1530 `8b598b574` | — | — |

## Files

- `history.json`: one entry per run, with the counts of each simulator by status and by chapter, and the tests whose result changed.
- `latest/<simulator>.json`: the result of every test in the latest run of each simulator, which the next run is compared with.
- `charts/*.svg`: the charts above.
