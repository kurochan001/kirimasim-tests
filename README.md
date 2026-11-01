# Nightly results of kirimasim-tests

The [nightly workflow](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml) of [kirimasim-tests](https://github.com/kurochan001/kirimasim-tests) writes this branch. Each night it runs every test of the suite's main branch with each simulator, adds the results to `history.json` and draws the charts below. Local runs can also be imported and are marked `local`. A test matches when its output and specified checks agree with the expected result, or an illegal design is rejected with the required diagnostic; see the suite's README for what each status means.

Latest run: 2026-11-01 02:35 UTC, suite commit [`7cf3532`](https://github.com/kurochan001/kirimasim-tests/commit/7cf35321ce1bb18e059facfab4ddead871d94358), 10042 tests, [workflow run](https://github.com/kurochan001/kirimasim-tests/actions/runs/41248878297).

## Latest results per simulator

Each row and chapter-table column uses that simulator's most recent recorded run. Dates, suite commits and test counts can differ; older results retain their own dates and are not treated as part of the latest run.

| Simulator | Version | Run (UTC) | Suite | Source | Match | Differ | Known differences | Unsupported |
| --- | --- | --- | --- | --- | ---: | ---: | ---: | ---: |
| Icarus Verilog | Icarus Verilog version 14.0 (devel) (s20260301-792-gd62a6065) | 2026-11-01 02:35 | [`7cf3532`](https://github.com/kurochan001/kirimasim-tests/commit/7cf35321ce1bb18e059facfab4ddead871d94358) | nightly | 6161 (63.0%) | 16 | 3597 | 0 |
| Verilator | Verilator 5.053 devel rev v5.052-654-gdd8a7d5e | 2026-11-01 02:35 | [`7cf3532`](https://github.com/kurochan001/kirimasim-tests/commit/7cf35321ce1bb18e059facfab4ddead871d94358) | nightly | 5449 (55.7%) | 9 | 4316 | 0 |
| kirimasim | kirimasim 0.0.0 (commit 1feede1ac82d), built with GNU 13.3.0 | 2026-11-01 02:35 | [`7cf3532`](https://github.com/kurochan001/kirimasim-tests/commit/7cf35321ce1bb18e059facfab4ddead871d94358) | nightly | 7424 (76.0%) | 133 | 0 | 2217 |
| Lyra | Lyra (commit bfc12e95d294) | 2026-11-01 02:35 | [`7cf3532`](https://github.com/kurochan001/kirimasim-tests/commit/7cf35321ce1bb18e059facfab4ddead871d94358) | nightly | 7643 (78.2%) | 520 | 0 | 1611 |
| Ghost | private build ab7995cae1ca | 2026-11-01 02:35 | [`7cf3532`](https://github.com/kurochan001/kirimasim-tests/commit/7cf35321ce1bb18e059facfab4ddead871d94358) | nightly | 8908 (91.1%) | 866 | 0 | 0 |

Ghost is an unidentified simulator taking part before its public debut. For now, only its test results step out from behind the curtain. Its name, source and build logs remain private; build IDs are executable hashes.

![Tests that match their expected results](charts/overview.svg?v=20261101T023515)

![Share of the tests that match](charts/rate.svg?v=20261101T023515)

## Changes in the latest run

Tests that match now but did not in the previous run of the same simulator, and tests that matched then but do not now. Tests added to the suite are counted in the table above.

### Icarus Verilog

Newly match (3): `ch23/test_defparam_assignment_lists`, `ch6/test_illegal_parameter_from_specparam`, `ch6/test_illegal_specparam_in_declaration_range`

No longer match (1):

- `ch11/test_A_extra_specparam_range`: differ — compile failed: /home/runner/work/kirimasim-tests/kirimasim-tests/tests/ch11/test_A_extra_specparam_range.sv:30: error: specparam 'sp' cannot be used in a constant expression.

### kirimasim

Newly match (187): `ch10/test_assignment_deep`, `ch11/test_streaming_complex_array`, `ch13/test_a2_7_dynamic_override_specifiers`, `ch13/test_call_without_parentheses_subroutine_kinds`, `ch13/test_class_methods_always_automatic`, `ch13/test_evaluation_context_extended`, `ch13/test_func_call_deep`, `ch13/test_optional_parentheses_every_subroutine_kind`, `ch13/test_recursive_class_task_ref_argument`, `ch13/test_ref_and_inout_object_handle_replacement`, `ch13/test_scope_nesting`, `ch13/test_scopes_task_function_class`, `ch13/test_task_declaration_grammar_and_nesting`, `ch20/test_bits_member_through_null_handle`, `ch21/test_swrite_member_target`, `ch24/test_anonymous_program`, `ch24/test_anonymous_program_empty_item`, `ch26/test_package_and_type_scope_names`, `ch26/test_package_import_in_method_body_and_enclosing_scope`, `ch26/test_scope_resolution_2`, `ch27/test_class_in_generate_block`, `ch3/test_program_contains_permitted_items`, `ch3/test_timeunit_package_class`, `ch6/test_cast_function`, `ch6/test_class_cast_compatibility_dynamic`, `ch6/test_class_static_init_order`, `ch6/test_const_runtime_automatic_and_class_handle`, `ch6/test_forward_typedef_forms_and_repeats`, `ch6/test_singular_values_in_inside_sets`, `ch6/test_type_param_restricted_kinds`, `ch6/test_typedef_param`, `ch6/test_uninitialized_package_and_class_variables`, `ch6/test_variable_declaration_qualifiers`, `ch7/test_dynamic_array_size_edge`, `ch7/test_member_access_3`, `ch7/test_member_ext`, `ch7/test_operator_member`, `ch7/test_struct_and_class_members`, `ch8/test_a1_9_constructor_arguments_and_parameter_class_item`, `ch8/test_abstract_class_basic`, `ch8/test_abstract_class_chain_and_handle_array`, `ch8/test_assign_class`, `ch8/test_base_handle_redeclared_members_and_virtual_dispatch`, `ch8/test_block_scoped_class_handles`, `ch8/test_cast_class`, `ch8/test_class_abstract`, `ch8/test_class_abstract_2`, `ch8/test_class_array_property_nonzero_range`, `ch8/test_class_basic`, `ch8/test_class_basic_2`, `ch8/test_class_basic_edge_cases`, `ch8/test_class_basics`, `ch8/test_class_cast`, `ch8/test_class_cast_edge_cases`, `ch8/test_class_compare`, `ch8/test_class_const_global_and_instance_properties`, `ch8/test_class_const_properties`, `ch8/test_class_construct`, `ch8/test_class_constructor_this_and_super_order`, `ch8/test_class_copy_3`, `ch8/test_class_edge`, `ch8/test_class_enum_property_accessors`, `ch8/test_class_extends`, `ch8/test_class_extends_2`, `ch8/test_class_extern`, `ch8/test_class_factory`, `ch8/test_class_handle_alias_and_polymorphism`, `ch8/test_class_handle_argument_directions`, `ch8/test_class_handle_arrays_lookup`, `ch8/test_class_handle_default_null_and_case_equality`, `ch8/test_class_inherit`, `ch8/test_class_inherit_edge_cases`, `ch8/test_class_inheritance`, `ch8/test_class_inheritance_2`, `ch8/test_class_inheritance_3`, `ch8/test_class_inheritance_corner`, `ch8/test_class_inheritance_virtual_super`, `ch8/test_class_local_and_protected_constructors`, `ch8/test_class_local_protected_access_and_modifier_order`, `ch8/test_class_member_access`, `ch8/test_class_method`, `ch8/test_class_method_2`, `ch8/test_class_method_calls`, `ch8/test_class_method_control_flow`, `ch8/test_class_methods`, `ch8/test_class_methods_2`, `ch8/test_class_new`, `ch8/test_class_null_comparison`, `ch8/test_class_null_handle`, `ch8/test_class_object`, `ch8/test_class_objects_handles_and_polymorphism`, `ch8/test_class_objects_in_array_of_handles`, `ch8/test_class_param`, `ch8/test_class_param_2`, `ch8/test_class_polymorphic_access`, `ch8/test_class_polymorphism`, `ch8/test_class_polymorphism_2`, `ch8/test_class_prop`, `ch8/test_class_property`, `ch8/test_class_property_init_after_base_constructor` and 87 more

### Lyra

No longer match (2):

- `ch13/test_constant_function_ignores_display`: differ — output differs: line 1 is 'next(1) called', expected 'next(10) called'
- `ch16/test_default_disable_iff_nested_module`: differ — error: internal error: Environment: the name 'rst' was lowered but never recorded where it lands, so what identifies its unit did not hold it -- please report this as a bug (in unit 'test_default_disable_iff_nested_module::nested_m__9a03c32fca2bb350')

### Ghost

Newly match (143): `ch10/test_unpacked_concat_typed_array_and_string_item`, `ch12/test_unique_violation_in_function_comb_callers`, `ch12/test_unique_violation_in_function_per_calling_process`, `ch13/test_ref_array_element_outdated_by_resize_or_delete`, `ch13/test_static_task_shared_activation`, `ch13/test_task_storage_per_call_and_per_instance`, `ch14/test_clocking_default_input_skew`, `ch14/test_clocking_scope_names`, `ch14/test_illegal_clocking_output_variable_continuous_assign`, `ch14/test_illegal_clocking_output_variable_force`, `ch14/test_illegal_clocking_output_variable_primitive_output`, `ch14/test_illegal_clocking_output_variable_procedural_assign`, `ch15/test_mailbox_get_peek_task_ref_destination`, `ch16/test_abort_condition_sampling`, `ch16/test_abort_nested_sync_forms`, `ch16/test_assertion_gated_clock_current_value`, `ch16/test_assertion_observed_region_values`, `ch16/test_assertion_sequence_clock_delay`, `ch16/test_ch16_sim_prop_async_abort`, `ch16/test_cover_pass_statements`, `ch16/test_default_clocking_assertion_clocks`, `ch16/test_default_disable_iff_nested_module`, `ch16/test_deferred_assertion_default_error`, `ch16/test_expect_action_control`, `ch16/test_first_match_items_and_boolean_or`, `ch16/test_followed_by_dual_forms`, `ch16/test_followed_by_existential`, `ch16/test_named_property_scopes_formals_instances`, `ch16/test_named_sequence_scopes_and_instances`, `ch16/test_nonvacuous_always_eventually`, `ch16/test_nonvacuous_evaluation_forms`, `ch16/test_nonvacuous_followed_by_nexttime`, `ch16/test_nonvacuous_if_nonoverlap_instance_disable`, `ch16/test_nonvacuous_not_and_abort`, `ch16/test_nonvacuous_property_case`, `ch16/test_nonvacuous_until_forms`, `ch16/test_property_abort_nesting`, `ch16/test_property_mutual_recursion`, `ch16/test_property_strong_unbounded_operators`, `ch16/test_property_until_strong_forms`, `ch16/test_recursive_property_abort_operators`, `ch16/test_sequence_formal_arguments_substitution`, `ch16/test_sequence_operator_and_delay_forms`, `ch16/test_static_deferred_assertion_always_comb`, `ch17/test_checker_free_activity`, `ch17/test_illegal_checker_covergroup_in_procedure`, `ch18/test_constraint_foreach_scope_dimensions`, `ch18/test_constraint_guard_and_table`, `ch18/test_constraint_guard_not_nested`, `ch18/test_constraint_guard_or_table`, `ch18/test_foreach_dynamic_multidim_constraint`, `ch18/test_global_constraints_nested_inactive`, `ch18/test_inline_local_scope_binding`, `ch18/test_rand_packed_enum_member`, `ch18/test_randc_permutation_recomputed`, `ch18/test_random_array_kinds`, `ch18/test_random_array_resize_modes`, `ch18/test_random_array_size_handles`, `ch19/test_cg_block_event_begin_end`, `ch19/test_cg_cross_bin_counts_retain_auto`, `ch19/test_cg_cross_illegal_per_instance`, `ch19/test_cg_cross_select_bins`, `ch19/test_cg_declaration_contexts`, `ch19/test_cg_merge_auto_and_transition_names`, `ch19/test_cg_sampling_instant_and_strobe`, `ch20/test_assertcontrol_action_controls_ongoing`, `ch20/test_assertcontrol_directive_type_ignored_for_expect_and_violations`, `ch20/test_assertcontrol_lock_expect_and_violation_reports`, `ch20/test_assertcontrol_off_kill_on_pending`, `ch20/test_assertcontrol_violation_and_expect_types`, `ch20/test_assertion_default_error_failoff_failon`, `ch21/test_evcd_dumpports_files_defaults_and_control_scope`, `ch21/test_evcd_inout_output_strong_and_unknown_direction`, `ch21/test_evcd_inout_same_value_conflicts`, `ch21/test_evcd_port_states_strengths_and_controls`, `ch23/test_bind_instantiation_kinds`, `ch23/test_bind_scope_and_interface_target`, `ch23/test_dotted_name_resolution_all_rules`, `ch23/test_hierarchy_branches_syntax_and_uses`, `ch23/test_port_collapse_trireg_charge_strength`, `ch23/test_upward_name_resolution_order`, `ch25/test_interface_declaration_all_header_elements`, `ch25/test_interface_named_bundle_ports_share_variable_and_net`, `ch25/test_interface_nested_program_and_interface`, `ch25/test_interface_port_default_ref_and_inout_access`, `ch27/test_generate_block_and_item_forms`, `ch28/test_bidirectional_switch_category`, `ch28/test_pass_switch_direction_and_control_kinds`, `ch28/test_primitive_terminal_lists`, `ch28/test_syntax_primitive_terminal_expressions`, `ch3/test_element_and_block_name_spaces`, `ch3/test_interface_instantiates_interface_program_and_checker`, `ch3/test_interface_ports_of_module_program_and_interface`, `ch35/test_dpi_context_scope_of_declaration`, `ch35/test_dpi_disable_import_task`, `ch35/test_dpi_export_task_disable_status`, `ch35/test_dpi_open_array_layout_and_element_representation`, `ch35/test_dpi_open_array_query_functions`, `ch35/test_dpi_open_array_unsized_ranges_per_call`, `ch35/test_dpi_open_packed_dimension` and 43 more

No longer match (1):

- `ch13/test_call_without_parentheses_subroutine_kinds`: differ — output differs

## By chapter

![Matching tests by chapter](charts/chapters.svg?v=20261101T023515)

## Each simulator over time

![Icarus Verilog: results by status](charts/status-icarus.svg?v=20261101T023515)

![Verilator: results by status](charts/status-verilator.svg?v=20261101T023515)

![kirimasim: results by status](charts/status-kirimasim.svg?v=20261101T023515)

![Lyra: results by status](charts/status-lyra.svg?v=20261101T023515)

![Ghost: results by status](charts/status-ghost.svg?v=20261101T023515)

## Recent runs

Matching tests of each simulator, with the change since its previous run. The version is shown when it changed.

| Run (UTC) | Suite | Tests | Icarus Verilog | Verilator | kirimasim | Lyra | Ghost |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| [2026-11-01 02:35](https://github.com/kurochan001/kirimasim-tests/actions/runs/41248878297) | [`7cf3532`](https://github.com/kurochan001/kirimasim-tests/commit/7cf35321ce1bb18e059facfab4ddead871d94358) | 10042 | 6161 (+461 −1) `14.0 devel d62a606` | 5449 (+184 −0) `5.053 devel dd8a7d5` | 7424 (+956 −0) `1feede1ac` | 7643 (+712 −2) `bfc12e95d` | 8908 (+873 −1) `private build ab7995cae1ca` |
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
