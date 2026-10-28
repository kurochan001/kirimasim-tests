# Nightly results of kirimasim-tests

The [nightly workflow](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml) of [kirimasim-tests](https://github.com/kurochan001/kirimasim-tests) writes this branch. Each night it runs every test of the suite's main branch with each simulator, adds the results to `history.json` and draws the charts below. Local runs can also be imported and are marked `local`. A test matches when its output and specified checks agree with the expected result, or an illegal design is rejected with the required diagnostic; see the suite's README for what each status means.

Latest run: 2026-10-28 00:30 UTC, suite commit [`41085fe`](https://github.com/kurochan001/kirimasim-tests/commit/41085fe3432bb093bf52c4f33bc4b44fff1a9401), 7732 tests, [workflow run](https://github.com/kurochan001/kirimasim-tests/actions/runs/40599008464).

## Latest results per simulator

Each row and chapter-table column uses that simulator's most recent recorded run. Dates, suite commits and test counts can differ; older results retain their own dates and are not treated as part of the latest run.

| Simulator | Version | Run (UTC) | Suite | Source | Match | Differ | Known differences | Unsupported |
| --- | --- | --- | --- | --- | ---: | ---: | ---: | ---: |
| Icarus Verilog | Icarus Verilog version 14.0 (devel) (s20260301-739-gd95f2401) | 2026-10-28 00:30 | [`41085fe`](https://github.com/kurochan001/kirimasim-tests/commit/41085fe3432bb093bf52c4f33bc4b44fff1a9401) | nightly | 4599 (59.5%) | 14 | 3119 | 0 |
| Verilator | Verilator 5.053 devel rev v5.052-621-gc0b28949 | 2026-10-28 00:30 | [`41085fe`](https://github.com/kurochan001/kirimasim-tests/commit/41085fe3432bb093bf52c4f33bc4b44fff1a9401) | nightly | 4763 (61.6%) | 9 | 2960 | 0 |
| kirimasim | kirimasim 0.0.0 (commit cfb76b386b5a), built with GNU 13.3.0 | 2026-10-28 00:30 | [`41085fe`](https://github.com/kurochan001/kirimasim-tests/commit/41085fe3432bb093bf52c4f33bc4b44fff1a9401) | nightly | 5045 (65.2%) | 465 | 0 | 2222 |
| Lyra | Lyra (commit 7e2c604b9ab2) | 2026-10-28 00:30 | [`41085fe`](https://github.com/kurochan001/kirimasim-tests/commit/41085fe3432bb093bf52c4f33bc4b44fff1a9401) | nightly | 5474 (70.8%) | 780 | 0 | 1478 |
| Ghost | private build bdc4d9a56351 | 2026-10-28 00:30 | [`41085fe`](https://github.com/kurochan001/kirimasim-tests/commit/41085fe3432bb093bf52c4f33bc4b44fff1a9401) | nightly | 5935 (76.8%) | 1797 | 0 | 0 |

Ghost is an unidentified simulator taking part before its public debut. For now, only its test results step out from behind the curtain. Its name, source and build logs remain private; build IDs are executable hashes.

![Tests that match their expected results](charts/overview.svg?v=20261028T003011)

![Share of the tests that match](charts/rate.svg?v=20261028T003011)

## Changes in the latest run

Tests that match now but did not in the previous run of the same simulator, and tests that matched then but do not now. Tests added to the suite are counted in the table above.

### Verilator

Newly match (15): `ch12/test_foreach_index_shadows_outer`, `ch20/test_typename_predefined_width_distinct`, `ch26/test_package_variable_wakes_processes`, `ch31/test_timing_zero_limits_never_violate`, `ch6/test_string_atoi`, `ch6/test_string_conversion`, `ch6/test_string_edge`, `ch6/test_string_functions_comprehensive`, `ch6/test_string_ops_edge_cases`, `ch6/test_type_matching_rules_by_type_compare`, `ch6/test_type_operator_matching_types`, `ch6/test_type_reference_declare_cast_compare`, `ch7/test_integer_atom_types_match_vector_types`, `ch9/test_event_nested_struct_member`, `ch9/test_event_or_mixed_comma_forms`

No longer match (3):

- `ch7/test_dynamic_array_and_queue_operations`: differ — output differs: line 6 is '%Warning: Bounded queue [$:3] overflow, attempted size 5 ...', expected 'qb_size=4 first=1 last=4'
- `ch7/test_queue_edge_2`: differ — output differs: line 1 is '%Warning: Bounded queue [$:10] overflow, attempted size 1...', expected 'PASS: Queue edge cases'
- `ch7/test_queue_refs_outdated_by_bounded_push_and_assignment`: differ — output differs: line 1 is '%Warning: Bounded queue [$:2] overflow, attempted size 4 ...', expected 't=1: p = 1 2 3 4 m = 1 2 3 4 equal=1 b = 5 10 20'

### kirimasim

Newly match (13): `ch10/test_nba_intra_assignment_event_control`, `ch12/test_comb_foreach_3d_break`, `ch23/test_empty_named_connection_ignores_default`, `ch23/test_port_connection_blank_omitted_empty`, `ch23/test_wildcard_port_connection_defaults`, `ch3/test_illegal_unit_prefix_forward_reference`, `ch3/test_illegal_unit_scope_forward_reference`, `ch5/test_illegal_decimal_literal_digit_and_x`, `ch5/test_literal_xz_digit_widths_and_padding`, `ch5/test_number_grammar_every_base_digit_and_real_form`, `ch6/test_string_atoreal_scan_rules`, `ch9/test_intra_assignment_repeat_nonblocking`, `ch9/test_syntax_intra_assignment_timing_forms`

No longer match (3):

- `ch11/test_real_operand_result_types`: differ — output differs (exit 2): error: $bits argument type 'real' is not a bit-stream type and so has no well-defined size in bits
- `ch11/test_shortreal_result_and_condition_types`: differ — output differs (exit 2): error: $bits argument type 'shortreal' is not a bit-stream type and so has no well-defined size in bits
- `ch6/test_string_ato_integer_scan_rules`: differ — output differs: line 3 is 'atoi("_7_")=0', expected 'atoi("_7_")=7'

### Lyra

Newly match (6): `ch6/test_string_atoi`, `ch6/test_string_atoi_2`, `ch6/test_string_conversion`, `ch6/test_string_edge`, `ch6/test_string_functions_comprehensive`, `ch6/test_string_ops_edge_cases`

### Ghost

Newly match (55): `ch11/test_let_declared_in_each_kind_of_scope`, `ch11/test_let_parameterized`, `ch13/test_recursive_class_task_ref_argument`, `ch17/test_checker_assume_stability`, `ch17/test_checker_assume_violation`, `ch18/test_illegal_rand_mode_non_random`, `ch18/test_randsequence_return_values`, `ch18/test_thread_stability_fork`, `ch21/test_display_format`, `ch21/test_display_format_edge_cases`, `ch21/test_format_advanced`, `ch21/test_format_precision`, `ch21/test_format_specifiers_edge`, `ch21/test_sscanf_real_conversions`, `ch21/test_write_fmt`, `ch21/test_write_format`, `ch22/test_file_line_across_include`, `ch22/test_illegal_begin_keywords_spans_include_boundary`, `ch23/test_interconnect_primitive_broadcast_input`, `ch23/test_interconnect_primitive_terminal`, `ch23/test_interconnect_terminal_wire_resolution`, `ch23/test_port_collapse_internal_supply`, `ch23/test_port_collapse_wired_opposite_supply`, `ch25/test_illegal_modport_prototype_type_not_matching`, `ch25/test_interface_port_parameter_per_instance`, `ch26/test_package_edge_cases_2`, `ch27/test_class_in_generate_block`, `ch3/test_checker_assertion_with_auxiliary_model`, `ch35/test_dpi_export_task_result`, `ch36/test_vpi_systf_calltf_writes_arguments`, `ch36/test_vpi_systf_compiletf_arguments`, `ch36/test_vpi_systf_phases_and_object_identity`, `ch36/test_vpi_systf_registration_fields`, `ch36/test_vpi_systf_shared_routine_user_data`, `ch36/test_vpi_systf_task_arguments`, `ch37/test_vpi_interface_program`, `ch37/test_vpi_module_hierarchy`, `ch38/test_vpi_get_time_scaled`, `ch38/test_vpi_get_value_array`, `ch38/test_vpi_put_value_delay_modes`, `ch38/test_vpi_register_systf_methods`, `ch38/test_vpi_systf_compile_and_call_phases`, `ch38/test_vpi_time_callbacks`, `ch38/test_vpi_userdata_compiletf`, `ch38/test_vpi_value_change_callback`, `ch38/test_vpi_value_change_event`, `ch4/test_switch_unknown_control_same_value_resolution`, `ch4/test_switch_x_gate_resolution`, `ch6/test_four_state_two_state_and_real_storage`, `ch6/test_typedef_advanced`, `ch6/test_user_types_built_from_other_types`, `ch7/test_assoc_narrow_prev_next_overflow`, `ch7/test_assoc_traversal_narrow_index`, `ch7/test_packed_array`, `ch7/test_packed_array_member_access`

No longer match (16):

- `ch16/test_illegal_past_automatic_clock`: differ — no error matches 'test_illegal_past_automatic_clock\\.sv:31:'
- `ch16/test_illegal_past_automatic_gating`: differ — no error matches 'test_illegal_past_automatic_gating\\.sv:30:'
- `ch16/test_sequence_repetition_and_concat_precedence`: differ — output differs
- `ch17/test_illegal_checker_always_ff_blocking_forms`: differ — no error matches 'test_illegal_checker_always_ff_blocking_forms\\.sv:(51|59|72):'
- `ch18/test_constraint_block_all_forms`: differ — output differs (exit 2)
- `ch18/test_discarded_soft_distribution`: differ — output differs (exit 2)
- `ch18/test_illegal_inline_constraint_super_unresolved`: differ — no error matches 'test_illegal_inline_constraint_super_unresolved\\.sv:41:'
- `ch18/test_illegal_inline_constraint_this_unresolved`: differ — no error matches 'test_illegal_inline_constraint_this_unresolved\\.sv:35:'
- `ch18/test_illegal_scope_randomize_with_list`: differ — no error matches 'test_illegal_scope_randomize_with_list\\.sv:37:'
- `ch18/test_rand_enum_solver_finds_solution`: differ — output differs (exit 2)
- `ch18/test_randcase_selection`: differ — output differs
- `ch18/test_random_array_kinds`: differ — output differs
- `ch7/test_illegal_assoc_first_argument_type`: differ — the design was accepted, but it is illegal
- `ch7/test_illegal_assoc_last_argument_type`: differ — the design was accepted, but it is illegal
- `ch7/test_illegal_assoc_next_argument_type`: differ — the design was accepted, but it is illegal
- `ch7/test_illegal_assoc_prev_argument_type`: differ — the design was accepted, but it is illegal

## By chapter

![Matching tests by chapter](charts/chapters.svg?v=20261028T003011)

## Each simulator over time

![Icarus Verilog: results by status](charts/status-icarus.svg?v=20261028T003011)

![Verilator: results by status](charts/status-verilator.svg?v=20261028T003011)

![kirimasim: results by status](charts/status-kirimasim.svg?v=20261028T003011)

![Lyra: results by status](charts/status-lyra.svg?v=20261028T003011)

![Ghost: results by status](charts/status-ghost.svg?v=20261028T003011)

## Recent runs

Matching tests of each simulator, with the change since its previous run. The version is shown when it changed.

| Run (UTC) | Suite | Tests | Icarus Verilog | Verilator | kirimasim | Lyra | Ghost |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
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
