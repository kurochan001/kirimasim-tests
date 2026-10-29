# Nightly results of kirimasim-tests

The [nightly workflow](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml) of [kirimasim-tests](https://github.com/kurochan001/kirimasim-tests) writes this branch. Each night it runs every test of the suite's main branch with each simulator, adds the results to `history.json` and draws the charts below. Local runs can also be imported and are marked `local`. A test matches when its output and specified checks agree with the expected result, or an illegal design is rejected with the required diagnostic; see the suite's README for what each status means.

Latest run: 2026-10-29 00:48 UTC, suite commit [`248cca8`](https://github.com/kurochan001/kirimasim-tests/commit/248cca894a2607eb6eae0bda3303dc1c7cb130a9), 7744 tests, [workflow run](https://github.com/kurochan001/kirimasim-tests/actions/runs/40786512421).

## Latest results per simulator

Each row and chapter-table column uses that simulator's most recent recorded run. Dates, suite commits and test counts can differ; older results retain their own dates and are not treated as part of the latest run.

| Simulator | Version | Run (UTC) | Suite | Source | Match | Differ | Known differences | Unsupported |
| --- | --- | --- | --- | --- | ---: | ---: | ---: | ---: |
| Icarus Verilog | Icarus Verilog version 14.0 (devel) (s20260301-749-gfd8759f6) | 2026-10-29 00:48 | [`248cca8`](https://github.com/kurochan001/kirimasim-tests/commit/248cca894a2607eb6eae0bda3303dc1c7cb130a9) | nightly | 4607 (61.6%) | 14 | 2855 | 0 |
| Verilator | Verilator 5.053 devel rev v5.052-635-g375685d2 | 2026-10-29 00:48 | [`248cca8`](https://github.com/kurochan001/kirimasim-tests/commit/248cca894a2607eb6eae0bda3303dc1c7cb130a9) | nightly | 4779 (63.9%) | 9 | 2688 | 0 |
| kirimasim | kirimasim 0.0.0 (commit df25891fa77c), built with GNU 13.3.0 | 2026-10-29 00:48 | [`248cca8`](https://github.com/kurochan001/kirimasim-tests/commit/248cca894a2607eb6eae0bda3303dc1c7cb130a9) | nightly | 5070 (67.8%) | 134 | 2 | 2270 |
| Lyra | Lyra (commit 7e2c604b9ab2) | 2026-10-29 00:48 | [`248cca8`](https://github.com/kurochan001/kirimasim-tests/commit/248cca894a2607eb6eae0bda3303dc1c7cb130a9) | nightly | 5498 (73.5%) | 480 | 0 | 1498 |
| Ghost | private build af267bf4f8b1 | 2026-10-29 00:48 | [`248cca8`](https://github.com/kurochan001/kirimasim-tests/commit/248cca894a2607eb6eae0bda3303dc1c7cb130a9) | nightly | 6083 (78.6%) | 1661 | 0 | 0 |

Ghost is an unidentified simulator taking part before its public debut. For now, only its test results step out from behind the curtain. Its name, source and build logs remain private; build IDs are executable hashes.

![Tests that match their expected results](charts/overview.svg?v=20261029T004822)

![Share of the tests that match](charts/rate.svg?v=20261029T004822)

## Changes in the latest run

Tests that match now but did not in the previous run of the same simulator, and tests that matched then but do not now. Tests added to the suite are counted in the table above.

### Icarus Verilog

Newly match (3): `ch21/test_vcd_scope_commands_begin_fork_task`, `ch22/test_22_extra_include_syntax`, `ch7/test_packed_array_member_access`

No longer match (1):

- `ch21/test_readmemh_address_range`: known difference — output differs: line 3 is 'm[0][2]=11', expected 'm[0][2]=ee'

### Verilator

Newly match (1): `ch18/test_uniqueness_constraint_forms`

No longer match (1):

- `ch21/test_readmemh_address_range`: known difference — output differs: line 3 is 'm[0][2]=11', expected 'm[0][2]=ee'

### kirimasim

Newly match (16): `ch11/test_conditional_real_shortreal_branch_promotion`, `ch12/test_syntax_loop_statement_forms`, `ch16/test_ch16_sim_clocking_single`, `ch20/test_array_query_dimension_counts`, `ch20/test_array_query_functions`, `ch20/test_fatal_form_finish_number_and_arguments`, `ch20/test_fatal_form_finish_number_only`, `ch20/test_fatal_form_without_parentheses`, `ch20/test_illegal_timeformat_unit_out_of_range`, `ch20/test_severity_tasks_report_contents`, `ch21/test_readmemh_address_range`, `ch21/test_vcd_scope_commands_begin_fork_task`, `ch22/test_22_extra_include_syntax`, `ch24/test_program_port_reactive_variable_and_net`, `ch7/test_queue_method_prototypes_and_invalid_indices`, `ch9/test_always_comb_longest_static_prefix_and_locals`

### Lyra

Newly match (18): `ch11/test_conditional_predicate_and_integral_branch`, `ch11/test_tagged_union_expression_and_matches_precedence`, `ch12/test_pattern_conditional_predicate`, `ch12/test_pattern_match_known_result`, `ch16/test_ch16_sim_clocking_single`, `ch18/test_uniqueness_constraint_forms`, `ch19/test_cg_bin_syntax_all_forms`, `ch20/test_array_query_dimension_counts`, `ch20/test_array_query_functions`, `ch20/test_fatal_form_finish_number_and_arguments`, `ch20/test_fatal_form_finish_number_only`, `ch20/test_fatal_form_without_parentheses`, `ch21/test_readmemh_address_range`, `ch22/test_22_extra_include_syntax`, `ch25/test_virtual_interface_data_type_forms`, `ch5/test_attribute_prefix_positions`, `ch6/test_void_return_and_tagged_union_void_member`, `ch7/test_union_grammar_forms`

### Ghost

Newly match (142): `ch11/test_conditional_predicate_and_integral_branch`, `ch11/test_tagged_union_expression_and_matches_precedence`, `ch12/test_pattern_match_known_result`, `ch16/test_A_extra_repetitions`, `ch16/test_ch16_sim_checker_history`, `ch16/test_ch16_sim_clocking_single`, `ch16/test_sequence_local_formal_assignment`, `ch17/test_checker_declaration_and_port_forms`, `ch18/test_uniqueness_constraint_forms`, `ch21/test_ch21_extra_readmem_address_range_error`, `ch21/test_display_arguments_without_format`, `ch21/test_evcd_dumpportslimit_all_files`, `ch21/test_evcd_dumpportslimit_stops_named_file`, `ch21/test_fgetc_byte_ff_and_eof`, `ch21/test_fgets_fill_newline_eof`, `ch21/test_format_hierarchical_name_scopes`, `ch21/test_format_string_unpacked_byte_array_order`, `ch21/test_format_unformatted_u_z_word_order`, `ch21/test_fread_word_widths_and_result`, `ch21/test_fscanf_unformatted_u_z`, `ch21/test_fwrite_unformatted_aggregates`, `ch21/test_illegal_display_strength_vector_net`, `ch21/test_illegal_display_unpacked_int_array_no_format`, `ch21/test_illegal_display_unpacked_shortint_array_no_format`, `ch21/test_illegal_display_unpacked_struct_no_format`, `ch21/test_illegal_readmem_address_outside_slice`, `ch21/test_illegal_readmem_higher_range`, `ch21/test_illegal_sscanf_decimal_into_unpacked_array`, `ch21/test_illegal_sscanf_hex_into_unpacked_struct`, `ch21/test_pattern_print_array_and_packed_struct`, `ch21/test_readmem_dynamic_array_not_resized`, `ch21/test_readmem_multidim_packed`, `ch21/test_readmemh_address_range`, `ch21/test_readmemh_directions_and_addresses`, `ch21/test_sformat_assignment_rules`, `ch21/test_sformat_format_expression_forms`, `ch21/test_sformat_only_second_argument_is_format`, `ch21/test_sformat_too_few_arguments_warns`, `ch21/test_sformat_too_many_arguments_warns`, `ch21/test_sscanf_digit_sets_xz`, `ch21/test_sscanf_eof_input_failure`, `ch21/test_sscanf_fields_whitespace_percent`, `ch21/test_sscanf_format_from_variables`, `ch21/test_sscanf_m_hierarchical_path`, `ch21/test_sscanf_sources_and_string_targets`, `ch21/test_sscanf_unknown_bits_return_eof`, `ch21/test_sscanf_v_strength_values`, `ch21/test_swrite_unpacked_byte_array_order`, `ch21/test_ungetc_pushback_and_failed_descriptor`, `ch21/test_value_plusargs_hex_real_empty_width`, `ch21/test_value_plusargs_illegal_characters`, `ch21/test_vcd_checkpoint_and_dump_control_protocol`, `ch21/test_vcd_dumpvars_no_arguments`, `ch21/test_vcd_dumpvars_selection_forms`, `ch21/test_vcd_filename_string_and_depth_zero`, `ch21/test_vcd_four_state_values_without_strength`, `ch21/test_vcd_type_mappings`, `ch21/test_vcd_version_records_dumpfile_call`, `ch21/test_writemem_dynamic_array_no_addresses`, `ch21/test_writemem_overwrite_and_multidim`, `ch21/test_writemem_packed_data`, `ch22/test_22_extra_include_syntax`, `ch36/test_vpi_routines_object_properties`, `ch37/test_vpi_attribute_object`, `ch37/test_vpi_attribute_value_types`, `ch37/test_vpi_class_internal_scopes`, `ch37/test_vpi_constant_select`, `ch37/test_vpi_constraint_expr_contents`, `ch37/test_vpi_constraint_properties`, `ch37/test_vpi_function_decl_type_range`, `ch37/test_vpi_get_value_side_effects`, `ch37/test_vpi_handle_creating_routines`, `ch37/test_vpi_immediate_assertion_parts`, `ch37/test_vpi_io_decl_ref_objs`, `ch37/test_vpi_io_direction_undefined`, `ch37/test_vpi_local_connectivity_ports`, `ch37/test_vpi_loop_branch_children`, `ch37/test_vpi_memory_word_objects`, `ch37/test_vpi_module_process_assign_primitive_relations`, `ch37/test_vpi_net_array_elements_indices`, `ch37/test_vpi_net_bits_constant_select`, `ch37/test_vpi_net_kinds_ranges_sizes`, `ch37/test_vpi_net_properties`, `ch37/test_vpi_nettype_alias_chain_relations`, `ch37/test_vpi_parameters`, `ch37/test_vpi_primitive_kinds_properties`, `ch37/test_vpi_property_types_iterator`, `ch37/test_vpi_put_value_side_effect`, `ch37/test_vpi_reg_array_scope_index`, `ch37/test_vpi_scopes`, `ch37/test_vpi_system_call_decompile`, `ch37/test_vpi_systf_argument_expressions`, `ch37/test_vpi_udp_definitions`, `ch37/test_vpi_union_net_tagged`, `ch37/test_vpi_user_defined_net_kinds`, `ch37/test_vpi_variable_class_member_props`, `ch37/test_vpi_variable_driver_load_kinds`, `ch37/test_vpi_variable_kinds_flags_sizes`, `ch37/test_vpi_wait_delay_event_stmts`, `ch38/test_vpi_array_get_formats` and 42 more

No longer match (3):

- `ch21/test_numeric_edge_cases`: differ — output differs
- `ch25/test_interface_array_modport`: differ — output differs
- `ch32/test_sdf_instance_array_index`: differ — output differs

## By chapter

![Matching tests by chapter](charts/chapters.svg?v=20261029T004822)

## Each simulator over time

![Icarus Verilog: results by status](charts/status-icarus.svg?v=20261029T004822)

![Verilator: results by status](charts/status-verilator.svg?v=20261029T004822)

![kirimasim: results by status](charts/status-kirimasim.svg?v=20261029T004822)

![Lyra: results by status](charts/status-lyra.svg?v=20261029T004822)

![Ghost: results by status](charts/status-ghost.svg?v=20261029T004822)

## Recent runs

Matching tests of each simulator, with the change since its previous run. The version is shown when it changed.

| Run (UTC) | Suite | Tests | Icarus Verilog | Verilator | kirimasim | Lyra | Ghost |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
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
