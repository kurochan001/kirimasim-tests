# Nightly results of kirimasim-tests

The [nightly workflow](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml) of [kirimasim-tests](https://github.com/kurochan001/kirimasim-tests) writes this branch. Each night it runs every test of the suite's main branch with each simulator, adds the results to `history.json` and draws the charts below. A test matches when the simulator's normalized standard output is exactly its expected output; see the suite's README for what each status means.

Latest run: 2026-10-21 22:46 UTC, suite commit [`4752cea`](https://github.com/kurochan001/kirimasim-tests/commit/4752cea52e9dc0d24ef58240eddee11ef055c673), 3719 tests, [workflow run](https://github.com/kurochan001/kirimasim-tests/actions/runs/39686633157).

| Simulator | Version | Match | Differ | Known differences | Unsupported | Since the previous run |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| Icarus Verilog | Icarus Verilog version 14.0 (devel) (s20260301-631-gce986819) | 2611 (70.2%) | 0 | 1108 | 0 | 318 new tests (140 match), 2 tests removed |
| Verilator | Verilator 5.053 devel rev v5.052-525-g019f1ca6 | 2659 (71.5%) | 0 | 1060 | 0 | 318 new tests (149 match), 2 tests removed |
| kirimasim | kirimasim 0.0.0 (commit b27968d1f3c1), built with GNU 13.3.0 | 2552 (68.6%) | 21 | 0 | 1146 | 5 newly match, 318 new tests (142 match), 2 tests removed |
| sukimasim | sukimasim version 0.9.9.2 (commit 5321c9d4581f) | 3109 (83.6%) | 610 | 0 | 0 | 362 newly match, 318 new tests (172 match), 2 tests removed |

sukimasim's repository is private: the nightly workflow builds its latest `main` from there, and only its results are published.

![Tests that match their expected output](charts/overview.svg)

![Share of the tests that match](charts/rate.svg)

## Changes in the latest run

Tests that match now but did not in the previous run of the same simulator, and tests that matched then but do not now. Tests added to the suite are counted in the table above.

### kirimasim

Newly match (5): `ch18/test_randcase_zero_weight`, `ch18/test_urandom_range_bounds`, `ch18/test_urandom_seed_repeatable`, `ch20/test_dist_functions_annex_n`, `ch20/test_stacktrace_function`

### sukimasim

Newly match (362): `ch14/test_illegal_clocking_blocking_write`, `ch14/test_illegal_clocking_drive_intra_delay`, `ch14/test_illegal_clocking_read_output_clockvar`, `ch14/test_illegal_clocking_two_default`, `ch14/test_illegal_clocking_write_input_clockvar`, `ch14/test_illegal_cycle_delay_intra_assignment`, `ch14/test_illegal_two_global_clocking`, `ch14/test_illegal_unnamed_clocking_not_default`, `ch16/test_multiclock_leading_clock`, `ch16/test_sequence_linear_and_ranges`, `ch17/test_illegal_checker_always_ff_blocking`, `ch17/test_illegal_checker_free_variable_continuous_assign`, `ch17/test_illegal_checker_in_checker_procedure`, `ch17/test_illegal_checker_in_fork`, `ch17/test_illegal_checker_module_instance`, `ch17/test_illegal_checker_net_declaration`, `ch17/test_illegal_checker_plain_always`, `ch17/test_illegal_checker_variable_hierarchical_write`, `ch18/test_illegal_solve_before_randc`, `ch18/test_illegal_solve_before_state_variable`, `ch20/test_elaboration_severity_not_generated`, `ch20/test_error_does_not_end_run`, `ch20/test_fatal_ends_with_error_code`, `ch20/test_fatal_in_assertion_action`, `ch20/test_fatal_runs_final_procedures`, `ch23/test_illegal_port_connected_twice`, `ch23/test_illegal_unknown_port_name`, `ch24/test_illegal_program_always`, `ch25/test_interface_specify_terminal`, `ch25/test_virtual_interface_clocking_block`, `ch26/test_illegal_package_missing_member`, `ch26/test_illegal_wildcard_import_conflict`, `ch28/test_gate_delay_specification`, `ch28/test_illegal_pullup_delay`, `ch28/test_trireg_three_delay_form`, `ch29/test_illegal_udp_combinational_reg`, `ch29/test_illegal_udp_conflicting_entries`, `ch29/test_illegal_udp_initial_delay`, `ch29/test_illegal_udp_inout_port`, `ch29/test_illegal_udp_instance_three_delays`, `ch29/test_illegal_udp_output_not_first`, `ch29/test_illegal_udp_two_transitions_in_entry`, `ch29/test_illegal_udp_z_in_table`, `ch30/test_path_polarity_no_effect`, `ch35/test_dpi_import_zero_time`, `ch4/test_pli_read_write_synch_write`, `ch6/test_illegal_const_assigned`, `ch6/test_illegal_enum_from_int`, `ch6/test_illegal_real_bit_select`, `ch6/test_illegal_real_edge_event`, `ch8/test_illegal_local_member_outside`, `ch9/test_illegal_always_ff_delay`, `ch9/test_illegal_always_ff_two_event_controls`, `gen/ch4/test_gen_sched_assign_monitor_always_delay0`, `gen/ch4/test_gen_sched_assign_monitor_always_delay1`, `gen/ch4/test_gen_sched_assign_monitor_always_nodelay`, `gen/ch4/test_gen_sched_assign_monitor_fork_delay0`, `gen/ch4/test_gen_sched_assign_monitor_fork_delay1`, `gen/ch4/test_gen_sched_assign_monitor_fork_nodelay`, `gen/ch4/test_gen_sched_assign_monitor_function_delay0`, `gen/ch4/test_gen_sched_assign_monitor_function_delay1`, `gen/ch4/test_gen_sched_assign_monitor_function_nodelay`, `gen/ch4/test_gen_sched_assign_monitor_generate_delay0`, `gen/ch4/test_gen_sched_assign_monitor_generate_delay1`, `gen/ch4/test_gen_sched_assign_monitor_generate_nodelay`, `gen/ch4/test_gen_sched_assign_monitor_initial_delay0`, `gen/ch4/test_gen_sched_assign_monitor_initial_delay1`, `gen/ch4/test_gen_sched_assign_monitor_initial_nodelay`, `gen/ch4/test_gen_sched_assign_monitor_interface_delay0`, `gen/ch4/test_gen_sched_assign_monitor_interface_nodelay`, `gen/ch4/test_gen_sched_assign_monitor_task_delay0`, `gen/ch4/test_gen_sched_assign_monitor_task_delay1`, `gen/ch4/test_gen_sched_assign_monitor_task_nodelay`, `gen/ch4/test_gen_sched_assign_strobe_always_delay0`, `gen/ch4/test_gen_sched_assign_strobe_always_delay1`, `gen/ch4/test_gen_sched_assign_strobe_always_nodelay`, `gen/ch4/test_gen_sched_assign_strobe_fork_delay0`, `gen/ch4/test_gen_sched_assign_strobe_fork_delay1`, `gen/ch4/test_gen_sched_assign_strobe_fork_nodelay`, `gen/ch4/test_gen_sched_assign_strobe_function_delay0`, `gen/ch4/test_gen_sched_assign_strobe_function_delay1`, `gen/ch4/test_gen_sched_assign_strobe_function_nodelay`, `gen/ch4/test_gen_sched_assign_strobe_generate_delay0`, `gen/ch4/test_gen_sched_assign_strobe_generate_delay1`, `gen/ch4/test_gen_sched_assign_strobe_generate_nodelay`, `gen/ch4/test_gen_sched_assign_strobe_initial_delay0`, `gen/ch4/test_gen_sched_assign_strobe_initial_delay1`, `gen/ch4/test_gen_sched_assign_strobe_initial_nodelay`, `gen/ch4/test_gen_sched_assign_strobe_interface_delay0`, `gen/ch4/test_gen_sched_assign_strobe_interface_delay1`, `gen/ch4/test_gen_sched_assign_strobe_interface_nodelay`, `gen/ch4/test_gen_sched_assign_strobe_task_delay0`, `gen/ch4/test_gen_sched_assign_strobe_task_delay1`, `gen/ch4/test_gen_sched_assign_strobe_task_nodelay`, `gen/ch4/test_gen_sched_assign_wait_always_delay1`, `gen/ch4/test_gen_sched_assign_wait_fork_delay0`, `gen/ch4/test_gen_sched_assign_wait_fork_delay1`, `gen/ch4/test_gen_sched_assign_wait_function_delay0`, `gen/ch4/test_gen_sched_assign_wait_function_delay1`, `gen/ch4/test_gen_sched_assign_wait_generate_delay0` and 262 more

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
