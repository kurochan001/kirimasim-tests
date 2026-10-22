# Nightly results of kirimasim-tests

The [nightly workflow](https://github.com/kurochan001/kirimasim-tests/actions/workflows/nightly.yml) of [kirimasim-tests](https://github.com/kurochan001/kirimasim-tests) writes this branch. Each night it runs every test of the suite's main branch with each simulator, adds the results to `history.json` and draws the charts below. A test matches when the simulator's normalized standard output is exactly its expected output; see the suite's README for what each status means.

Latest run: 2026-10-22 23:07 UTC, suite commit [`bc1609d`](https://github.com/kurochan001/kirimasim-tests/commit/bc1609dc005548ac6dd7848355b705983d7aacd5), 3938 tests, [workflow run](https://github.com/kurochan001/kirimasim-tests/actions/runs/39865168055).

| Simulator | Version | Match | Differ | Known differences | Unsupported | Since the previous run |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| Icarus Verilog | Icarus Verilog version 14.0 (devel) (s20260301-638-ge072b333) | 2719 (69.0%) | 0 | 1219 | 0 | 2 newly match, 220 new tests (106 match), 1 tests removed |
| Verilator | Verilator 5.053 devel rev v5.052-550-gbb916d05 | 2802 (71.2%) | 1 | 1135 | 0 | 3 newly match, 220 new tests (141 match), 1 tests removed |
| kirimasim | kirimasim 0.0.0 (commit 499198369a07), built with GNU 13.3.0 | 2660 (67.5%) | 21 | 0 | 1257 | 2 newly match, 220 new tests (106 match), 1 tests removed |
| sukimasim | sukimasim version 0.9.9.2 (commit 1c55957496d3) | 3351 (85.1%) | 587 | 0 | 0 | 90 newly match, 220 new tests (152 match), 1 tests removed |

sukimasim's repository is private: the nightly workflow builds its latest `main` from there, and only its results are published.

![Tests that match their expected output](charts/overview.svg)

![Share of the tests that match](charts/rate.svg)

## Changes in the latest run

Tests that match now but did not in the previous run of the same simulator, and tests that matched then but do not now. Tests added to the suite are counted in the table above.

### Icarus Verilog

Newly match (2): `ch26/test_package_export_all`, `ch3/test_timeunit_program`

### Verilator

Newly match (3): `ch18/test_foreach_dynamic_multidim_constraint`, `ch20/test_math_advanced`, `ch20/test_math_hyperbolic_special_values`

### kirimasim

Newly match (2): `ch11/test_mintypmax_expressions`, `ch26/test_package_export_all`

### sukimasim

Newly match (90): `ch16/test_assertions_in_interface_and_program`, `ch20/test_array_query_fixed_dimensions`, `ch20/test_assert_action_control_tasks`, `ch20/test_assertcontrol`, `ch20/test_fatal_finish_number_zero`, `ch20/test_timeunit_timeprecision_functions`, `ch20/test_timeunit_unit_root`, `ch21/test_format_p_struct`, `ch24/test_anonymous_program`, `ch24/test_program_calls_module_task`, `ch24/test_program_end_kills_descendants`, `ch27/test_generate_instances_param`, `ch29/test_udp_initial_value_not_delayed`, `ch31/test_illegal_width_notifier_without_threshold`, `ch32/test_sdf_default_scope`, `ch32/test_sdf_device_all_paths`, `ch32/test_sdf_device_primitive_without_paths`, `ch32/test_sdf_iopath_absolute`, `ch32/test_sdf_iopath_all_conditional_paths`, `ch32/test_sdf_iopath_turnoff_values`, `ch32/test_sdf_scope_argument`, `ch32/test_sdf_separate_setup_hold`, `ch32/test_sdf_width_period_limits`, `ch35/test_dpi_packed_canonical`, `ch36/test_vpi_chk_error_callbacks`, `ch36/test_vpi_systf_in_always`, `ch37/test_vpi_active_time_format`, `ch37/test_vpi_callback_objects`, `ch37/test_vpi_class_definitions`, `ch37/test_vpi_class_obj_id`, `ch37/test_vpi_clocking_blocks`, `ch37/test_vpi_constraint_items`, `ch37/test_vpi_frames_and_threads`, `ch37/test_vpi_iterator_objects`, `ch37/test_vpi_named_events`, `ch37/test_vpi_nettype_declarations`, `ch37/test_vpi_property_sequence_decls`, `ch37/test_vpi_property_sequence_exprs`, `ch37/test_vpi_ref_obj_actual`, `ch37/test_vpi_time_queue`, `ch37/test_vpi_virtual_interface_vars`, `ch38/test_vpi_get_cb_info`, `ch38/test_vpi_get_cb_info_value_change`, `ch38/test_vpi_get_systf_info_function_types`, `ch38/test_vpi_handle_multi_intermod_path`, `ch38/test_vpi_vprintf_flush_mcd`, `ch39/test_vpi_assertion_callbacks`, `ch39/test_vpi_assertion_control`, `ch39/test_vpi_assertion_gclk_future_callback`, `ch39/test_vpi_assertion_kill_reset`, `ch39/test_vpi_assertion_step_callbacks`, `ch39/test_vpi_assertion_system_control`, `ch39/test_vpi_assertion_system_lock_reset`, `ch39/test_vpi_assertion_system_vacuous_actions`, `ch4/test_reactive_region_set_order`, `ch4/test_sched_nba_delays_same_time_keep_order`, `ch40/test_coverage_api_minimum_types`, `ch40/test_coverage_control_program_scope`, `ch40/test_coverage_control_results`, `ch40/test_coverage_get_values`, `ch40/test_coverage_reset_and_stop`, `ch40/test_coverage_root_hierarchy`, `ch40/test_coverage_save_after_stop`, `ch40/test_coverage_save_merge`, `ch40/test_coverage_save_merge_all_types`, `ch40/test_coverage_scope_sums`, `ch40/test_vpi_fsm_from_pragmas`, `ch6/test_illegal_mixed_continuous_procedural`, `ch6/test_net_declaration_drive_strength`, `ch7/test_queue_write_at_size_appends`, `ch9/test_intra_assignment_repeat_nonblocking`, `gen/ch11/test_gen_xz_cond_07`, `gen/ch11/test_gen_xz_cond_08`, `gen/ch11/test_gen_xz_weq_02`, `gen/ch11/test_gen_xz_wne_01`, `gen/ch4/test_gen_sched_assign_monitor_interface_delay1`, `gen/ch4/test_gen_sched_assign_wait_always_delay0`, `gen/ch4/test_gen_sched_blocking_monitor_interface_delay1`, `gen/ch4/test_gen_sched_blocking_wait_always_delay0`, `gen/ch4/test_gen_sched_blocking_wait_interface_delay0`, `gen/ch4/test_gen_sched_blocking_wait_interface_delay1`, `gen/ch4/test_gen_sched_force_wait_always_delay0`, `gen/ch4/test_gen_sched_nba_wait_always_delay0`, `gen/ch4/test_gen_sched_nba_wait_always_nodelay`, `gen/ch4/test_gen_sched_nbadelay_monitor_interface_delay0`, `gen/ch4/test_gen_sched_nbadelay_monitor_interface_delay1`, `gen/ch4/test_gen_sched_nbadelay_monitor_interface_nodelay`, `gen/ch4/test_gen_sched_nbadelay_wait_interface_delay0`, `gen/ch4/test_gen_sched_nbadelay_wait_interface_delay1`, `gen/ch4/test_gen_sched_nbadelay_wait_interface_nodelay`

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
