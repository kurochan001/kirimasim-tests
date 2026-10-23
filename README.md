# Nightly results of kirimasim-tests

The [nightly workflow](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml) of [kirimasim-tests](https://github.com/kurochan001/kirimasim-tests) writes this branch. Each night it runs every test of the suite's main branch with each simulator, adds the results to `history.json` and draws the charts below. A test matches when the simulator's normalized standard output is exactly its expected output; see the suite's README for what each status means.

Latest run: 2026-10-23 23:03 UTC, suite commit [`721db37`](https://github.com/kurochan001/kirimasim-tests/commit/721db3743b9db84ecb14fa86a8165dbcff8fdb0d), 3986 tests, [workflow run](https://github.com/kurochan001/kirimasim-tests/actions/runs/40033104165).

| Simulator | Version | Match | Differ | Known differences | Unsupported | Since the previous run |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| Icarus Verilog | Icarus Verilog version 14.0 (devel) (s20260301-649-g1a663cb3) | 2720 (68.2%) | 0 | 1266 | 0 | 48 new tests (1 match) |
| Verilator | Verilator 5.053 devel rev v5.052-567-g0041d207 | 2821 (70.8%) | 1 | 1164 | 0 | 2 newly match, 48 new tests (17 match) |
| kirimasim | kirimasim 0.0.0 (commit 0d27da4e7757), built with GNU 13.3.0 | 2786 (69.9%) | 24 | 0 | 1176 | 126 newly match, 48 new tests (0 match) |
| sukimasim | sukimasim version 0.9.9.2 (commit 982c2320a46f) | 3376 (84.7%) | 610 | 0 | 0 | 13 newly match, 48 new tests (12 match) |

sukimasim's repository is private: the nightly workflow builds its latest `main` from there, and only its results are published.

![Tests that match their expected output](charts/overview.svg)

![Share of the tests that match](charts/rate.svg)

## Changes in the latest run

Tests that match now but did not in the previous run of the same simulator, and tests that matched then but do not now. Tests added to the suite are counted in the table above.

### Verilator

Newly match (2): `ch18/test_randomize_checker_state_only`, `ch3/test_name_spaces`

### kirimasim

Newly match (126): `ch10/test_assignment_patterns`, `ch10/test_intra_assignment_delay_nba_concatenation`, `ch10/test_unpacked_concat_typed_array_and_string_item`, `ch11/test_assign_ext`, `ch11/test_ct_eval_side_effects`, `ch12/test_foreach_block_scope`, `ch12/test_foreach_loop`, `ch12/test_loop_control_forms`, `ch12/test_loop_statements`, `ch12/test_statement_foreach`, `ch13/test_function_call_2`, `ch13/test_function_call_3`, `ch13/test_function_early_return`, `ch13/test_function_side_effects`, `ch13/test_local_variable_scope`, `ch13/test_output_ref_combination`, `ch13/test_recursive_func_2`, `ch13/test_ref_arg`, `ch20/test_array_multidim_query`, `ch20/test_bits_size`, `ch20/test_comb_array_query`, `ch20/test_dimensions`, `ch20/test_edge_time_round`, `ch20/test_size_array`, `ch20/test_size_func`, `ch20/test_sysfunc_high_low`, `ch20/test_sysfunc_left_right`, `ch20/test_sysfunc_size`, `ch20/test_sysfunc_size_2`, `ch23/test_top_level_instances`, `ch24/test_exit_outside_program_ignored`, `ch24/test_program_automatic_lifetime`, `ch24/test_program_calls_module_task`, `ch24/test_program_comprehensive`, `ch24/test_program_end_kills_descendants`, `ch24/test_program_exit`, `ch24/test_program_exit_from_fork`, `ch24/test_program_exit_in_task`, `ch24/test_program_final_after_initial_ends`, `ch24/test_program_final_procedure`, `ch24/test_program_hierarchical_reference_between_programs`, `ch24/test_program_initial_procedures`, `ch24/test_program_instances`, `ch24/test_program_output_after_module_nba_chain`, `ch24/test_program_port_connection`, `ch24/test_program_port_reactive`, `ch24/test_program_reactive`, `ch24/test_program_reactive_sees_nba`, `ch24/test_program_reactive_zero_delay`, `ch24/test_program_stimulus_after_clock_edge`, `ch24/test_program_variables`, `ch26/test_package_import_program_header`, `ch3/test_timeunit_program`, `ch4/test_program_renba_after_zero_delay`, `ch5/test_builtin_method_forms_after_mutation`, `ch6/test_dollar_parameter_unbounded`, `ch6/test_typedef_corner`, `ch6/test_unbounded_queue_tail_after_resize`, `ch7/test_array_assign_2`, `ch7/test_array_predicates`, `ch7/test_assign_queue`, `ch7/test_comb_queue_ops`, `ch7/test_container_assign_pattern`, `ch7/test_dyn_array_basic`, `ch7/test_dyn_array_delete`, `ch7/test_dyn_array_edge`, `ch7/test_dyn_array_edge_cases`, `ch7/test_dyn_array_method`, `ch7/test_dyn_array_new`, `ch7/test_dyn_array_ops`, `ch7/test_dynamic_arr_edge_cases`, `ch7/test_dynamic_array`, `ch7/test_dynamic_array_2`, `ch7/test_dynamic_array_edge`, `ch7/test_dynamic_array_edge_cases`, `ch7/test_dynamic_array_ops`, `ch7/test_dynamic_array_queue_size`, `ch7/test_dynamic_resize`, `ch7/test_member_access_patterns`, `ch7/test_member_queue`, `ch7/test_queue_basic`, `ch7/test_queue_basic_edge_cases`, `ch7/test_queue_delete`, `ch7/test_queue_delete_2`, `ch7/test_queue_edge`, `ch7/test_queue_edge_2`, `ch7/test_queue_edge_cases`, `ch7/test_queue_edge_cases_2`, `ch7/test_queue_insert`, `ch7/test_queue_insert_2`, `ch7/test_queue_insert_delete`, `ch7/test_queue_insert_positions`, `ch7/test_queue_method`, `ch7/test_queue_method_edges`, `ch7/test_queue_methods`, `ch7/test_queue_methods_2`, `ch7/test_queue_methods_3`, `ch7/test_queue_methods_4`, `ch7/test_queue_methods_basic`, `ch7/test_queue_methods_bounded` and 26 more

### sukimasim

Newly match (13): `ch14/test_clocking_input_skew_fractional`, `ch14/test_global_clocking`, `ch24/test_exit_outside_program_ignored`, `ch24/test_illegal_anonymous_program_hierarchical_reference`, `ch24/test_illegal_module_calls_program_task`, `ch24/test_illegal_program_signal_from_module`, `ch24/test_program_clocking_input`, `ch24/test_program_exit`, `ch24/test_program_exit_from_fork`, `ch24/test_program_exit_in_task`, `ch24/test_program_output_after_module_nba_chain`, `ch24/test_program_port_reactive`, `ch25/test_virtual_if_array`

## By chapter

![Matching tests by chapter](charts/chapters.svg)

## Each simulator over time

![Icarus Verilog: results by status](charts/status-icarus.svg)

![Verilator: results by status](charts/status-verilator.svg)

![kirimasim: results by status](charts/status-kirimasim.svg)

![sukimasim: results by status](charts/status-sukimasim.svg)

## Recent runs

Matching tests of each simulator, with the change since its previous run. The version is shown when it changed.

| Run (UTC) | Suite | Tests | Icarus Verilog | Verilator | kirimasim | sukimasim |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| [2026-10-23 23:03](https://github.com/kurochan001/kirimasim-tests/actions/runs/40033104165) | [`721db37`](https://github.com/kurochan001/kirimasim-tests/commit/721db3743b9db84ecb14fa86a8165dbcff8fdb0d) | 3986 | 2720 (+1 −0) `14.0 devel 1a663cb` | 2821 (+19 −0) `5.053 devel 0041d20` | 2786 (+126 −0) `0d27da4e7` | 3376 (+25 −0) `982c2320a` |
| [2026-10-22 23:07](https://github.com/kurochan001/kirimasim-tests/actions/runs/39865168055) | [`bc1609d`](https://github.com/kurochan001/kirimasim-tests/commit/bc1609dc005548ac6dd7848355b705983d7aacd5) | 3938 | 2719 (+108 −0) `14.0 devel e072b33` | 2802 (+144 −0) `5.053 devel bb916d0` | 2660 (+108 −0) `499198369` | 3351 (+242 −0) `1c5595749` |
| [2026-10-21 22:46](https://github.com/kurochan001/kirimasim-tests/actions/runs/39686633157) | [`4752cea`](https://github.com/kurochan001/kirimasim-tests/commit/4752cea52e9dc0d24ef58240eddee11ef055c673) | 3719 | 2611 (+140 −0) `14.0 devel ce98681` | 2659 (+149 −0) `5.053 devel 019f1ca` | 2552 (+147 −0) `b27968d1f` | 3109 (+534 −0) `5321c9d45` |
| [2026-10-21 01:31](https://github.com/kurochan001/kirimasim-tests/actions/runs/39523323680) | [`0cfd00b`](https://github.com/kurochan001/kirimasim-tests/commit/0cfd00b58140ba628bb18a68e439933a07312fa2) | 3403 | 2471 (+36 −0) | 2512 (+35 −0) `5.053 devel 4c98f02` | 2405 (+61 −0) `7b2b17aa1` | 2576 (+22 −0) `d6f36ecb4` |
| [2026-10-21 01:02](https://github.com/kurochan001/kirimasim-tests/actions/runs/39507186309) | [`824f574`](https://github.com/kurochan001/kirimasim-tests/commit/824f5748dd619afaf472f60fd0ce83d0a547d829) | 3332 | 2435 (+857 −0) | 2477 (+549 −0) `5.053 devel 3cc4981` | 2344 (+754 −0) `0680c67d5` | 2554 (+511 −0) `2754b2970` |
| [2026-10-20 07:49](https://github.com/kurochan001/kirimasim-tests/actions/runs/39387575855) | [`6bffc4a`](https://github.com/kurochan001/kirimasim-tests/commit/6bffc4a184134250ca4b934ef2b40af9961bc4d5) | 2327 | 1578 `14.0 devel 7e3d0c6` | — | 1590 `b1be7015e` | 2043 `02efa6d73` |
| [2026-10-20 05:01](https://github.com/kurochan001/kirimasim-tests/actions/runs/39363555028) | [`56508cd`](https://github.com/kurochan001/kirimasim-tests/commit/56508cdce0a414ca1623756c6856dd1f49819977) | 2327 | 1578 (+56 −0) | 1928 (+103 −0) `5.053 devel 0177067` | 1590 (+60 −0) `ff80adcf6` | — |
| [2026-10-19 22:42](https://github.com/kurochan001/kirimasim-tests/actions/runs/39329365210) | [`42081bd`](https://github.com/kurochan001/kirimasim-tests/commit/42081bd73c354db73c20b1b17fb076975ae5a16f) | 2176 | 1522 `14.0 devel eed9291` | 1825 `5.053 devel 60f166e` | 1530 `8b598b574` | — |

## Files

- `history.json`: one entry per run, with the counts of each simulator by status and by chapter, and the tests whose result changed.
- `latest/<simulator>.json`: the result of every test in the latest run of each simulator, which the next run is compared with.
- `charts/*.svg`: the charts above.
