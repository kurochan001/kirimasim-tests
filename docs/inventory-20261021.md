# Inventory of the suite, 2026-10-21

Phase 0 of the extension work: what the suite already has, before anything
is added. Nothing outside this file was changed for it. The counts are those
of `main` at commit 6177339 (3403 tests).

## Versions

| Tool | Version |
| --- | --- |
| `iverilog` on `PATH` | 14.0 (devel) (s20260301-411-gca6b8d376), not 13.0 |
| Icarus Verilog used for the oracle | 13.0 (stable) (v13_0), Homebrew's 13.0 keg, given to the runner with `--iverilog-bin` |
| `verilator` | 5.052 2026-09-05 |

The `iverilog` on `PATH` is a development version, so every run of the
oracle names the directory of 13.0 with `--iverilog-bin`, as README.md says.

## Where the request and the existing conventions differ

The request says that the existing conventions win where they differ from
it. These are the places, with what the later phases will do:

| Request | Existing convention | Plan |
| --- | --- | --- |
| Only the normalized stdout is judged; exit code and stderr are not | `:expected_exit:` and `:expected_stderr_regex:` already judge them when a test asks for it (README.md, "How a test is judged") | Keep |
| Add `:type: elaboration` and `:should_fail_because:`; a nonzero exit passes | Both exist (121 illegal designs). A rejection passes only when an error names the line in `:expected_stderr_regex:`, so a rejection for another reason does not pass | Keep the stricter rule |
| Add `:expected_exit: 0 \| nonzero` | Exists, with `0`, `nonzero` or a number (5 tests) | Keep |
| Add `:plusargs:` | Plusargs are given with `:args:` (5 tests) | Keep `:args:`; no second field for the same thing |
| Add `:files:` | Exists: sources compiled before the test, and included files whose directory becomes an include directory (6 tests) | Keep |
| Add `:defines:`, `:incdirs:`, `:top_module:` | Do not exist | Add in phase 1 |
| kirimasim's "unsupported" does not pass a should-fail test | Already so in `tools/run_kirimasim.py` | Keep |
| check.yml checks that the releases reject the should-fail tests | Already so: an illegal design with `iverilog@13.0` or `verilator@5.052` in `:oracle:` has to be rejected at the line it names | Keep |
| Check every expected output with both Icarus Verilog and Verilator | Icarus Verilog 13.0 first, Verilator 5.052 where it fails; a test that was run with both lists each that produces the output | Run both for new tests and record by the existing rule |
| `tests/ch04` | Directories are `tests/chNN` without a leading zero (`tests/ch4`) | `tests/ch4` |
| `tools/gen_wide_tests.py`, output next to hand-written tests | Generators live in `generators/`, write `tests/gen/chNN/`, and record oracles in `generators/oracles.txt`; `width_sign` already covers widths 63 to 1000 | A new generator in `generators/` that writes `tests/gen/`, without repeating what `width_sign` does |
| A function cannot contain fork-join_none (3-2) | IEEE 1800-2023 13.4.4 allows fork-join_none in a function; fork-join and fork-join_any are illegal there (`ch13/test_illegal_function_fork_join`) | Test the legal fork-join_none; the clause decides |

## IEEE 1800-2023 features

Searched in the code of every test, outside comments.

| Feature | Tests | Which |
| --- | ---: | --- |
| Triple-quoted strings `"""` (5.9) | 0 | — |
| `` `ifdef `` with an expression (22.6) | 0 | — |
| `class :final` (8.13) | 0 | — |
| Methods with `:initial`, `:extends`, `:final` (8.20) | 0 | — |
| Array method `map()` (7.12.5) | 2 | `ch7/test_array_map_method`, `ch7/test_map_result_to_same_array` |
| Index argument of array methods (7.12) | 0 | — |
| `rand real` (18.4.1) | 0 | — |
| `$timeunit`, `$timeprecision` (20.4.1) | 2 | `ch20/test_timeunit_timeprecision_functions`, `ch20/test_timeunit_unit_root` |
| `$stacktrace` (20.17.2) | 1 | `ch20/test_stacktrace_function` |
| `[a +/- b]` (11.4.13, 18.5.3, 19.5) | 0 | — |
| `[a +%- b]` (11.4.13, 18.5.3, 19.5) | 0 | — |
| `weak_reference` (8.30) | 5 | `ch8/test_illegal_weak_reference_non_class`, `ch8/test_object_strongly_reachable`, `ch8/test_weak_reference_get_clear`, `ch8/test_weak_reference_get_id`, `ch8/test_weak_reference_wait_cleared` |
| `type(this)` (8.11, 6.23) | 0 | — |
| `default :/` in dist (18.5.3) | 0 | — |
| `super.new(default)` (8.17) | 0 | — |
| `union soft` (7.3.1) | 0 | — |
| covergroup `extends` (19.4.1) | 1 | `ch19/test_cg_embedded_inheritance` |

Comparison results with x and z (11.4.4 to 11.4.6) are covered by the
`xz_propagation` generator and by hand-written tests of chapter 11.

## Illegal designs that phase 3-1 asks for

| Rule | Existing test |
| --- | --- |
| Procedural assignment to a net (10.4) | `ch10/test_illegal_procedural_assign_to_net` |
| Timing control in a function (13.4.4) | `ch13/test_illegal_function_delay`, `ch13/test_illegal_function_event_control` |
| ref argument of a static subroutine (13.5.2) | `ch13/test_illegal_ref_in_static_task` |
| `new` of an abstract class (8.21) | `ch8/test_illegal_abstract_class_new` |
| `:final` class extended (8.13), `:final` method overridden (8.20), new in 2023 | none |
| Modport direction (25.5) | `ch25/test_illegal_modport_input_written` |
| Import name conflict (26.3) | `ch26/test_illegal_wildcard_import_conflict` |
| real in a packed array (7.4.1) | none (the packed struct with a real member, 7.2.1, is `ch7/test_illegal_packed_struct_real_member`) |
| Delay in always_comb (9.2.2.2) | none |
| A variable of always_ff written by another process (9.2.2.4) | `ch9/test_illegal_always_ff_other_writer` and 3 more |
| Assignment to a const variable (6.20.6) | `ch6/test_illegal_const_assigned` |
| Assignment of an integer or another enum to an enum (6.19.3) | `ch6/test_illegal_enum_from_int`, `ch6/test_illegal_enum_from_other_enum` |
| Undeclared net under `` `default_nettype none `` (22.8) | `ch22/test_illegal_default_nettype_none_assign`, `ch22/test_illegal_default_nettype_none_port` |

## Scheduling items of phase 3-2

Matched by the descriptions of the hand-written tests; the 325 generated
tests of `scheduling` add the combinations of write, read and place that
README.md lists. Phase 3-2 looks at each item closely before adding tests.

| Item | Existing tests |
| --- | --- |
| Active, Inactive (`#0`), NBA, Postponed in order | `ch4/test_edge_event_regions`, `ch4/test_event_delta_cycles`, `ch4/test_nba_after_zero_delay`, `ch4/test_sched_strobe_after_nba`, and the generator |
| Order of nonblocking updates (10.4.2), several to one variable | `ch4/test_array_element_noop_nba_keeps_override_order`, ch10 tests, the generator |
| `$monitor` once per time step | `ch21/test_monitor_end_of_step`, the generator |
| Several `#0` in a row | `ch4/test_event_delta_cycles`, `ch10/test_edge_delta_cycle_chain` |
| An event control woken by a nonblocking update | `ch4/test_sched_strobe_after_nba`, `ch10/test_nba_intra_assignment_event_control` |
| `wait` and nonblocking updates | few; to be added |
| always_ff feeding always_comb, one cycle later | `ch9/test_always_comb_latch_ff` |
| Deferred assertions (`assert #0`) in the Observed region | `ch16/test_deferred_assertion_flush`, `ch16/test_deferred_assertion_per_process` |
| fork-join_none children start after the parent blocks (9.3.2) | `ch9/test_join_none_children_start_after_parent_blocks`, `ch9/test_fork_join_block_timing` |
| What `disable fork` ends (9.6.3) | `ch9/test_disable_fork_ends_loops_and_class_tasks`, `ch9/test_wait_fork_disable_fork` |
| fork-join_none in a function (13.4.4) | none for the legal use |
| A loop of zero delays, `$time` stays | none |

## Tests of chapters 4, 14 to 19, 22, 24 and 35

Every clause of these chapters that sets out observable behavior is cited by
a test ([docs/tests/clauses.md](tests/clauses.md)); the clauses cited by one
test only are the thinnest. The catalog ([docs/tests/](tests/README.md)) has
the description of every test.

### Chapter 4

26 hand-written tests and 325 generated; 27 clauses in scope, every one cited, 14 of them by one test only: 4.4.1, 4.4.2.1, 4.4.2.5, 4.4.2.7, 4.4.2.8, 4.4.3.2, 4.4.3.4, 4.4.3.9, 4.4.3.10, 4.9.1, 4.9.2, 4.9.3, 4.9.5, 4.9.7.

| Test | `:lrm:` | Oracle |
| --- | --- | --- |
| `test_nba_cross_module` | 4.3 10.4.2 4.6 | iverilog@13.0 |
| `test_nba_cross_module_timing` | 4.3 | iverilog@13.0 |
| `test_nba_port_propagation` | 4.3 10.4.2 4.9.6 10.3 | iverilog@13.0 |
| `test_preponed_sampling` | 4.4.2.1 16.5.1 16.9.3 | verilator@5.052 |
| `test_edge_event_regions` | 4.4.2.2 4.4.2.3 4.4.2.4 21.2.2 | iverilog@13.0 verilator@5.052 |
| `test_delta_cycle` | 4.4.2.3 4.6 10.4.2 10.3.2 | iverilog@13.0 |
| `test_delta_cycles` | 4.4.2.3 3.14.2.3 22.7 21.3.2 | iverilog@13.0 |
| `test_delta_scheduler` | 4.4.2.3 9.2.2.2 10.4.2 | iverilog@13.0 |
| `test_event_delta_cycles` | 4.4.2.3 4.7 9.4.1 | iverilog@13.0 |
| `test_nba_after_zero_delay` | 4.4.2.3 4.4.2.4 10.4.2 | iverilog@13.0 |
| `test_reactive_region_set_order` | 4.4.2.7 4.4.2.8 4.5 24.3 | standard only |
| `test_sched_strobe_after_nba` | 4.4.2.9 21.2.2 10.4.2 | iverilog@13.0 verilator@5.052 |
| `test_pli_pre_active_write` | 4.4.3.2 4.10 38.36.2 38.34 | iverilog@13.0 |
| `test_pli_read_write_synch_write` | 4.4.3.4 4.4.3.3 4.10 38.36.2 | iverilog@13.0 |
| `test_pli_end_of_time_write` | 4.4.3.9 4.4.3.10 4.10 4.5 38.36.2 | iverilog@13.0 |
| `test_ieee1800_2023_delta_convergence` | 4.5 4.4.2.3 10.3 | iverilog@13.0 |
| `test_array_element_noop_nba_keeps_override_order` | 4.6 10.4.2 | iverilog@13.0 |
| `test_port_complex_expr_extended` | 4.7 23.3.2 23.3.3 4.9.6 | iverilog@13.0 |
| `test_range_select_lhs` | 4.9 11.5.1 | iverilog@13.0 |
| `test_sched_contassign_zero_delay` | 4.9.1 4.4.2.2 4.4.2.3 10.3.2 | iverilog@13.0 |
| `test_sched_procedural_assign_deassign` | 4.9.2 10.6.1 | standard only |
| `test_sched_intra_assignment_target` | 4.9.3 4.9.4 9.4.5 10.4.1 10.4.2 | iverilog@13.0 |
| `test_switch_x_gate_resolution` | 4.9.5 28.8 28.12 | iverilog@13.0 |
| `test_sched_subroutine_copy_out` | 4.9.7 13.3 13.5.1 13.5.2 | verilator@5.052 |
| `test_pli_nba_synch_callback` | 4.10 4.4.3.3 38.36.2 | standard only |
| `test_pli_region_callbacks` | 4.10 4.4.3 38.36.2 | iverilog@13.0 |

The 325 generated tests (`tests/gen/ch4/`) come from the `scheduling` generator (README.md, "Generated tests").

### Chapter 14

29 hand-written tests; 14 clauses in scope, every one cited, 3 of them by one test only: 14.7, 14.9, 14.15.

| Test | `:lrm:` | Oracle |
| --- | --- | --- |
| `test_clocking_blk_edge_cases` | 14.3 14.13 | verilator@5.052 |
| `test_clocking_blocks` | 14.3 14.13 14.16 | verilator@5.052 |
| `test_clocking_blocks_edge_cases` | 14.3 14.13 14.16 | verilator@5.052 |
| `test_clocking_input` | 14.3 14.4 14.13 | verilator@5.052 |
| `test_clocking_input_with_expression` | 14.3 14.13 | verilator@5.052 |
| `test_clocking_ops` | 14.3 14.13 14.16 | verilator@5.052 |
| `test_illegal_clocking_read_output_clockvar` (illegal) | 14.3 | verilator@5.052 |
| `test_illegal_clocking_write_input_clockvar` (illegal) | 14.3 14.16 | verilator@5.052 |
| `test_illegal_unnamed_clocking_not_default` (illegal) | 14.3 14.12 | verilator@5.052 |
| `test_clocking_input_output_skew` | 14.4 14.13 14.16 14.5 | verilator@5.052 |
| `test_clocking_input_skew_fractional` | 14.4 14.3 3.14.2.2 | standard only |
| `test_clocking_multiple_blocks` | 14.6 14.5 14.4 14.13 | verilator@5.052 |
| `test_clocking_interface_modport` | 14.9 25.5 14.16 14.10 | standard only |
| `test_clocking_event_cycle_delay` | 14.10 14.11 14.12 | verilator@5.052 |
| `test_cycle_delay` | 14.11 14.12 | verilator@5.052 |
| `test_cycle_delay_clocking` | 14.11 14.12 14.16 | verilator@5.052 |
| `test_illegal_cycle_delay_intra_assignment` (illegal) | 14.11 10.4 | verilator@5.052 |
| `test_illegal_cycle_delay_without_default_clocking` (illegal) | 14.11 14.12 | verilator@5.052 |
| `test_illegal_clocking_two_default` (illegal) | 14.12 | verilator@5.052 |
| `test_global_clocking` | 14.14 | standard only |
| `test_illegal_two_global_clocking` (illegal) | 14.14 | verilator@5.052 |
| `test_clocking_synchronous_events` | 14.15 14.7 14.13 14.3 | standard only |
| `test_clocking_drive_between_edges` | 14.16 14.11 14.12 | verilator@5.052 |
| `test_clocking_output_net_driver` | 14.16 14.16.2 6.6.1 | standard only |
| `test_illegal_clocking_blocking_write` (illegal) | 14.16 | verilator@5.052 |
| `test_illegal_clocking_drive_intra_delay` (illegal) | 14.16 14.16.1 | verilator@5.052 |
| `test_clocking_inout_drive_keeps_input` | 14.16.1 14.3 14.13 14.16 | verilator@5.052 |
| `test_clocking_drive_last_wins` | 14.16.2 14.16.1 14.16 14.3 | verilator@5.052 |
| `test_clocking_two_blocks_one_output` | 14.16.2 14.6 14.16 | verilator@5.052 |

### Chapter 15

26 hand-written tests; 20 clauses in scope, every one cited, 12 of them by one test only: 15.4.2, 15.4.3, 15.4.4, 15.4.5, 15.4.6, 15.4.7, 15.4.8, 15.4.9, 15.5.2, 15.5.4, 15.5.5.2, 15.5.5.3.

| Test | `:lrm:` | Oracle |
| --- | --- | --- |
| `test_semaphore_basic` | 15.3 | verilator@5.052 |
| `test_semaphore_edge` | 15.3 | verilator@5.052 |
| `test_semaphore_edge_cases` | 15.3 | verilator@5.052 |
| `test_semaphore_multiple` | 15.3 | verilator@5.052 |
| `test_semaphore_new` | 15.3 15.3.1 | verilator@5.052 |
| `test_semaphore_try_get` | 15.3 15.3.4 | verilator@5.052 |
| `test_semaphore_blocking_keys` | 15.3.3 15.3.2 15.3.1 15.3.4 | verilator@5.052 |
| `test_semaphore_fifo_order` | 15.3.3 15.3.1 15.3.2 | verilator@5.052 |
| `test_mailbox_6` | 15.4 | verilator@5.052 |
| `test_mailbox_basic` | 15.4 | verilator@5.052 |
| `test_mailbox_basic_2` | 15.4 | verilator@5.052 |
| `test_mailbox_bounded` | 15.4 | verilator@5.052 |
| `test_mailbox_bounded_methods` | 15.4 15.4.1 15.4.2 15.4.4 15.4.6 15.4.7 15.4.8 | verilator@5.052 |
| `test_mailbox_edge` | 15.4 | verilator@5.052 |
| `test_mailbox_edge_cases` | 15.4 | verilator@5.052 |
| `test_mailbox_edge_cases_2` | 15.4 | verilator@5.052 |
| `test_mailbox_blocking_put_get` | 15.4.3 15.4.5 15.4.9 15.4.1 | verilator@5.052 |
| `test_event_named` | 15.5 15.5.1 | verilator@5.052 |
| `test_event_nonblocking_trigger` | 15.5.1 4.4.2.4 9.4 | standard only |
| `test_event_ordering` | 15.5.1 9.4.2 4.4.2.3 | iverilog@13.0 |
| `test_hierarchical_event_trigger` | 15.5.1 15.5.3 23.6 | verilator@5.052 |
| `test_event_triggered` | 15.5.3 | verilator@5.052 |
| `test_event_triggered_same_step` | 15.5.3 15.5.2 15.5.1 | verilator@5.052 |
| `test_wait_order` | 15.5.4 15.5.1 | standard only |
| `test_event_merge` | 15.5.5.1 15.5.5 15.5.1 | standard only |
| `test_event_null_compare` | 15.5.5.3 15.5.5.2 15.5.5.1 | standard only |

### Chapter 16

73 hand-written tests; 66 clauses in scope, every one cited, 37 of them by one test only: 16.4.3, 16.4.4, 16.4.5, 16.5.2, 16.9.1, 16.9.2.1, 16.9.8, 16.9.10, 16.11, 16.12.1, 16.12.3, 16.12.4, 16.12.5, 16.12.6, 16.12.8, 16.12.9, 16.12.10, 16.12.11, 16.12.12, 16.12.13, 16.12.14, 16.12.15, 16.12.16, 16.12.17, 16.12.19, 16.13.2, 16.13.3, 16.13.5, 16.13.7, 16.14.4, 16.14.5, 16.14.6.2, 16.14.6.3, 16.14.6.4, 16.14.8, 16.17, 16.18.

| Test | `:lrm:` | Oracle |
| --- | --- | --- |
| `test_assert_imm` | 16.3 | iverilog@13.0 |
| `test_assert_imm_edge_cases` | 16.3 | iverilog@13.0 |
| `test_assert_immed` | 16.3 | iverilog@13.0 |
| `test_assert_immed_2` | 16.3 | standard only |
| `test_assert_immed_edge_cases` | 16.3 | iverilog@13.0 |
| `test_assert_simple` | 16.3 | iverilog@13.0 |
| `test_assertion_basic_edge_cases` | 16.3 | iverilog@13.0 |
| `test_diag_assert` | 16.3 | iverilog@13.0 |
| `test_immed_assert_edge_cases` | 16.3 | iverilog@13.0 |
| `test_immediate_assert` | 16.3 | iverilog@13.0 |
| `test_immediate_assert_assume` | 16.3 | iverilog@13.0 |
| `test_immediate_assert_compound_expr` | 16.3 | iverilog@13.0 |
| `test_immediate_assert_pass_action` | 16.3 | iverilog@13.0 |
| `test_immediate_assert_value_checks` | 16.3 | iverilog@13.0 |
| `test_immediate_assertions` | 16.3 | iverilog@13.0 |
| `test_immediate_assertions_2` | 16.3 | standard only |
| `test_immediate_assume` | 16.3 | iverilog@13.0 |
| `test_immediate_simple` | 16.3 | iverilog@13.0 |
| `test_deferred_assertion_flush` | 16.4 16.4.1 16.4.2 16.4.3 16.4.4 16.3 24.3 | standard only |
| `test_deferred_assertion_per_process` | 16.4.5 16.4.2 16.4 | standard only |
| `test_assertion_clock_sampled_value` | 16.5.2 16.5.1 16.14.1 | verilator@5.052 |
| `test_sequence_linear_and_ranges` | 16.7 16.14.3 16.9.2 | verilator@5.052 |
| `test_sequence_formal_arguments` | 16.8 16.8.1 16.12.1 16.12.18 16.14.3 | standard only |
| `test_untyped_formal_arguments` | 16.8 16.12 11.12 16.14.3 | standard only |
| `test_sequence_local_formal_arguments` | 16.8.2 16.10 16.12.7 16.14.1 | standard only |
| `test_sequence_operator_precedence` | 16.9.1 16.9.7 16.9.5 16.9.9 | standard only |
| `test_sequence_consecutive_repetition` | 16.9.2 16.9.2.1 16.14.3 | standard only |
| `test_sequence_goto_nonconsecutive` | 16.9.2 16.14.3 | standard only |
| `test_comb_stable_multiinstance` | 16.9.3 | verilator@5.052 |
| `test_past_deep_history` | 16.9.3 16.5.1 16.14.7 | verilator@5.052 |
| `test_past_gating_expression` | 16.9.3 16.5.1 16.14.6 | standard only |
| `test_sampled_function` | 16.9.3 | verilator@5.052 |
| `test_sampled_in_action_block` | 16.9.3 16.14.1 16.5.1 4.4.2 | standard only |
| `test_system_sampled` | 16.9.3 | verilator@5.052 |
| `test_value_change_first_tick` | 16.9.3 16.5.1 16.14.6 6.8 | standard only |
| `test_value_change_functions_on_vectors` | 16.9.3 16.14.7 | verilator@5.052 |
| `test_global_clocking_sampled_functions` | 16.9.4 16.9.3 14.14 16.14.1 16.14.3 | standard only |
| `test_sequence_and_or_intersect` | 16.9.5 16.9.6 16.9.7 16.14.3 | standard only |
| `test_sequence_first_match` | 16.9.8 16.9.7 16.14.3 | standard only |
| `test_sequence_throughout_within` | 16.9.9 16.9.10 16.9.6 16.14.3 | standard only |
| `test_sequence_instance_vs_triggered` | 16.9.11 16.13.6 16.7 | standard only |
| `test_sequence_local_variables` | 16.10 16.11 16.12.7 16.14.1 16.14.3 | standard only |
| `test_comb_assert_binary_ops` | 16.12 11.4.3 11.4.10 | verilator@5.052 |
| `test_sva_array_bitselect` | 16.12 16.6 | verilator@5.052 |
| `test_sva_cast_expression` | 16.12 6.24.1 | verilator@5.052 |
| `test_sva_range_select` | 16.12 11.4.13 | verilator@5.052 |
| `test_property_not_or_and` | 16.12.3 16.12.4 16.12.5 16.12.2 16.12.7 16.14.1 | standard only |
| `test_property_if_else_case` | 16.12.6 16.12.16 16.12.7 16.14.1 | verilator@5.052 |
| `test_property_implies_iff_followed_by` | 16.12.8 16.12.9 16.12.7 16.14.1 | standard only |
| `test_property_nexttime_eventually` | 16.12.10 16.12.13 16.12.7 16.14.1 | standard only |
| `test_property_always_ranges` | 16.12.11 16.12.15 16.12.7 16.14.1 | verilator@5.052 |
| `test_property_until` | 16.12.12 16.12.7 16.14.1 | verilator@5.052 |
| `test_property_abort` | 16.12.14 16.5.1 16.12.7 16.14.1 | standard only |
| `test_recursive_properties` | 16.12.17 16.12.19 16.12.7 16.14.1 | standard only |
| `test_illegal_nonoverlapping_antecedent_no_match` (illegal) | 16.12.22 16.12.7 16.9.6 | standard only |
| `test_illegal_overlapping_antecedent_empty_only` (illegal) | 16.12.22 16.12.7 | standard only |
| `test_illegal_sequence_property_empty_match` (illegal) | 16.12.22 16.12 | standard only |
| `test_multiclock_sequences` | 16.13.1 16.13.2 16.13.3 16.14.1 16.14.3 | standard only |
| `test_sequence_matched_across_clocks` | 16.13.5 16.13.6 16.14.3 | standard only |
| `test_sequence_triggered` | 16.13.6 9.4.2.4 9.4.3 24.3 16.14.3 | standard only |
| `test_sequence_local_variable_initialization` | 16.13.7 16.10 16.8 | standard only |
| `test_assertion_clocked_by_named_event` | 16.14.1 16.5 16.14.6 16.16 | verilator@5.052 |
| `test_cover_disable_iff` | 16.14.3 16.12 16.15 | standard only |
| `test_cover_property_restrict` | 16.14.3 16.14.4 16.14.2 16.12.2 | standard only |
| `test_procedural_assertion_in_initial` | 16.14.6 16.14.5 16.14.1 | standard only |
| `test_procedural_concurrent_assertions` | 16.14.6 16.14.6.1 16.14.6.4 16.5.1 16.14.1 | standard only |
| `test_procedural_assertion_no_glitch` | 16.14.6.2 16.14.6.3 16.14.6 16.14.6.1 | standard only |
| `test_inferred_clock_disable` | 16.14.7 16.15 14.12 16.12 | standard only |
| `test_default_disable_iff` | 16.15 16.12 16.14.1 | verilator@5.052 |
| `test_illegal_multiclock_two_leading_clocks` (illegal) | 16.16.1 16.16 | standard only |
| `test_multiclock_leading_clock` | 16.16.1 16.13.1 16.16 | standard only |
| `test_expect_statement` | 16.17 | standard only |
| `test_clocking_block_assertions` | 16.18 14.3 14.4 16.5.1 16.14.1 | standard only |

### Chapter 17

20 hand-written tests; 9 clauses in scope, every one cited, 4 of them by one test only: 17.4, 17.6, 17.7.2, 17.7.3.

| Test | `:lrm:` | Oracle |
| --- | --- | --- |
| `test_checker_always_comb_output` | 17.2 17.5 17.7.1 17.3 | standard only |
| `test_checker_concurrent_assertion` | 17.2 17.3 16.14 14.12 | standard only |
| `test_checker_in_package` | 17.2 17.3 17.8 16.9.3 | standard only |
| `test_illegal_checker_module_instance` (illegal) | 17.2 | verilator@5.052 |
| `test_checker_port_connections` | 17.3 17.2 17.5 17.7.1 | standard only |
| `test_checker_procedural_instance` | 17.3 16.14.6 17.5 | standard only |
| `test_illegal_checker_in_checker_procedure` (illegal) | 17.3 17.5 | standard only |
| `test_illegal_checker_in_fork` (illegal) | 17.3 9.3.2 | standard only |
| `test_checker_context_inference` | 17.4 16.14.7 14.12 16.15 | standard only |
| `test_checker_always_ff_sampled` | 17.5 17.7 17.7.1 17.2 16.5.1 | standard only |
| `test_illegal_checker_plain_always` (illegal) | 17.5 | standard only |
| `test_checker_covergroup` | 17.6 17.7.1 19.3 19.11.1 | standard only |
| `test_checker_free_variables_assigned` | 17.7 17.7.1 17.7.2 17.3 | standard only |
| `test_illegal_checker_net_declaration` (illegal) | 17.7 17.2 | verilator@5.052 |
| `test_illegal_checker_always_ff_blocking` (illegal) | 17.7.1 17.5 | standard only |
| `test_illegal_checker_free_variable_continuous_assign` (illegal) | 17.7.1 17.7 | standard only |
| `test_illegal_checker_variable_hierarchical_write` (illegal) | 17.7.1 23.6 | standard only |
| `test_illegal_checker_variable_initial_assignment` (illegal) | 17.7.1 17.5 | standard only |
| `test_checker_reactive_triggered` | 17.7.3 17.5 16.13.6 4.4.2.5 | standard only |
| `test_checker_default_arg_function` | 17.8 17.2 17.3 17.7.1 | standard only |

### Chapter 18

36 hand-written tests; 44 clauses in scope, every one cited, 23 of them by one test only: 18.3, 18.4.1, 18.5.1, 18.5.2, 18.5.4, 18.5.5, 18.5.7.1, 18.5.7.2, 18.5.8, 18.5.11, 18.5.12, 18.5.13.1, 18.5.13.2, 18.7.1, 18.10, 18.11.1, 18.12.1, 18.14.3, 18.15, 18.16, 18.17.2, 18.17.3, 18.17.5.

| Test | `:lrm:` | Oracle |
| --- | --- | --- |
| `test_randc_full_cycle` | 18.4.2 | verilator@5.052 |
| `test_extern_constraint_function` | 18.5.1 18.5.11 | verilator@5.052 |
| `test_constraint_inheritance_override` | 18.5.2 18.6.3 | verilator@5.052 |
| `test_dist_zero_weight` | 18.5.3 | verilator@5.052 |
| `test_constraint_unique` | 18.5.4 | verilator@5.052 |
| `test_constraint_implication_ifelse` | 18.5.5 18.5.6 18.7 | verilator@5.052 |
| `test_constraint_foreach_sum` | 18.5.7.1 18.5.7.2 | verilator@5.052 |
| `test_global_constraints_rand_handles` | 18.5.8 18.4 18.6.1 | verilator@5.052 |
| `test_illegal_solve_before_randc` (illegal) | 18.5.9 18.4.2 | verilator@5.052 |
| `test_illegal_solve_before_state_variable` (illegal) | 18.5.9 | standard only |
| `test_solve_before_same_solutions` | 18.5.9 18.5.6 18.6.1 | verilator@5.052 |
| `test_static_constraint_mode` | 18.5.10 18.9 | verilator@5.052 |
| `test_constraint_guard_null` | 18.5.12 18.5.6 | standard only |
| `test_soft_constraint_priority` | 18.5.13.1 18.5.13.2 18.5.13 18.7 | verilator@5.052 |
| `test_rand_constraints_hold` | 18.6.1 18.3 18.4.1 18.5 11.4.13 | verilator@5.052 |
| `test_pre_post_randomize` | 18.6.2 18.4 | verilator@5.052 |
| `test_randomize_failure_keeps_values` | 18.6.3 18.6.2 18.12 | standard only |
| `test_randomize_with_local_scope` | 18.7.1 18.7 | verilator@5.052 |
| `test_illegal_rand_mode_non_random` (illegal) | 18.8 | verilator@5.052 |
| `test_rand_mode_array_element` | 18.8 18.4 8.9 | standard only |
| `test_rand_mode_constraint_mode` | 18.8 18.9 | verilator@5.052 |
| `test_dist_weights_changed` | 18.10 18.5.3 18.5.6 | verilator@5.052 |
| `test_randomize_argument_list` | 18.11 18.6.1 18.4 | verilator@5.052 |
| `test_randomize_null_checker` | 18.11.1 18.11 | verilator@5.052 |
| `test_std_randomize_with` | 18.12.1 18.12 | verilator@5.052 |
| `test_urandom_seed_repeatable` | 18.13.1 18.14.2 7.4.6 | verilator@5.052 |
| `test_urandom_range_bounds` | 18.13.2 18.13.1 | iverilog@13.0 |
| `test_random_state_restore` | 18.13.4 18.13.5 18.13.3 18.14.3 18.13.2 | verilator@5.052 |
| `test_thread_stability_fork` | 18.14.2 18.14.1 18.13.4 18.13.5 | verilator@5.052 |
| `test_srandom_object_repeatable` | 18.15 18.13.3 18.14.1 | verilator@5.052 |
| `test_randcase_zero_weight` | 18.16 | verilator@5.052 |
| `test_randsequence` | 18.17 18.17.1 18.17.3 | verilator@5.052 |
| `test_randsequence_control` | 18.17 18.17.2 18.17.4 18.17.6 18.17.7 | verilator@5.052 |
| `test_randsequence_weights` | 18.17.1 18.17 18.17.4 | verilator@5.052 |
| `test_rand_join_interleaving` | 18.17.5 18.17 | verilator@5.052 |
| `test_randsequence_return_values` | 18.17.7 18.17 18.17.6 | standard only |

### Chapter 19

26 hand-written tests; 22 clauses in scope, every one cited, 15 of them by one test only: 19.4.1, 19.5.1.1, 19.5.1.2, 19.5.2, 19.5.4, 19.5.5, 19.5.6, 19.5.7, 19.6.1.3, 19.6.1.4, 19.6.3, 19.8.1, 19.9, 19.10, 19.11.3.

| Test | `:lrm:` | Oracle |
| --- | --- | --- |
| `test_cg_clocking_event` | 19.3 19.11.1 | verilator@5.052 |
| `test_cg_embedded_in_class` | 19.4 19.11.1 | verilator@5.052 |
| `test_cg_embedded_inheritance` | 19.4.1 19.4 19.11 19.11.1 19.8 | standard only |
| `test_cg_iff_guard` | 19.5 19.11.1 | verilator@5.052 |
| `test_cg_fixed_count_bins` | 19.5.1 19.11.1 | standard only |
| `test_cg_value_bins_default` | 19.5.1 19.5 19.11.1 19.8 | verilator@5.052 |
| `test_cg_bins_with_set_expr` | 19.5.1.1 19.5.1.2 19.5.1 19.8 19.11.1 | standard only |
| `test_cg_transition_bins` | 19.5.2 19.11.1 | verilator@5.052 |
| `test_cg_auto_bins_max` | 19.5.3 19.7 19.11.1 | verilator@5.052 |
| `test_cg_enum_auto_bins` | 19.5.3 19.11.1 | standard only |
| `test_cg_wildcard_bins` | 19.5.4 19.11.1 | verilator@5.052 |
| `test_cg_ignore_bins` | 19.5.5 19.11.1 | standard only |
| `test_cg_illegal_bins_removed` | 19.5.6 19.11.1 | standard only |
| `test_cg_bins_value_resolution` | 19.5.7 19.5 19.11.1 | standard only |
| `test_cg_cross_coverage` | 19.6 19.11.2 19.11 | standard only |
| `test_cg_cross_select_bins` | 19.6.1 19.6.1.1 19.6.2 19.11.2 19.8 | standard only |
| `test_cg_cross_with_expression` | 19.6.1.2 19.6.1 19.6.2 19.11.2 | standard only |
| `test_cg_cross_set_expression` | 19.6.1.4 19.6.1.3 19.6.1.2 19.11.2 | standard only |
| `test_cg_cross_illegal_excluded` | 19.6.3 19.6.1 19.11.2 | standard only |
| `test_cg_at_least` | 19.7 19.11.1 | standard only |
| `test_cg_start_stop_counts` | 19.8 19.11.1 | standard only |
| `test_cg_sample_arguments` | 19.8.1 19.8 19.11.1 | verilator@5.052 |
| `test_get_coverage_weights` | 19.9 19.7.1 19.11 19.11.1 | standard only |
| `test_option_struct_members` | 19.10 19.7 19.7.1 | standard only |
| `test_cg_item_weighted_average` | 19.11 19.11.1 19.7 | standard only |
| `test_cg_type_coverage_merge` | 19.11.3 19.7 19.7.1 19.8 19.5.1 | standard only |

### Chapter 22

30 hand-written tests; 20 clauses in scope, every one cited, 10 of them by one test only: 22.5.3, 22.9, 22.10, 22.14.2, 22.14.3, 22.14.4, 22.14.6, 22.14.7, 22.14.8, 22.14.9.

| Test | `:lrm:` | Oracle |
| --- | --- | --- |
| `test_resetall_default_nettype` | 22.3 22.8 6.10 | iverilog@13.0 verilator@5.052 |
| `test_include_file_declarations` | 22.4 | iverilog@13.0 |
| `test_include_guard_twice` | 22.4 22.6 22.5.1 | iverilog@13.0 |
| `test_include_guard_two_files` | 22.4 22.5.1 3.12.1 | iverilog@13.0 |
| `test_include_nested` | 22.4 | iverilog@13.0 |
| `test_compiler_directives` | 22.5.1 22.6 22.7 22.8 | iverilog@13.0 |
| `test_compiler_directives_comprehensive` | 22.5.1 22.5.2 22.6 22.7 | iverilog@13.0 |
| `test_conditional_compilation_2` | 22.5.1 22.6 | iverilog@13.0 |
| `test_define_with_args` | 22.5.1 | iverilog@13.0 |
| `test_directive_corner_cases` | 22.5.1 22.6 22.13 | iverilog@13.0 |
| `test_directive_nested` | 22.5.1 22.6 | iverilog@13.0 |
| `test_ieee_ch22_directives_edge` | 22.5.1 22.6 | iverilog@13.0 |
| `test_macro_advanced` | 22.5.1 22.6 | iverilog@13.0 |
| `test_macro_args` | 22.5.1 | iverilog@13.0 |
| `test_macro_concat` | 22.5.1 | iverilog@13.0 |
| `test_macro_redefine_string_literal` | 22.5.1 | iverilog@13.0 |
| `test_undef` | 22.5.2 22.6 | iverilog@13.0 |
| `test_undefineall` | 22.5.3 22.5.1 22.6 | verilator@5.052 |
| `test_conditional_compilation` | 22.6 | iverilog@13.0 |
| `test_ifdef_nested` | 22.6 | iverilog@13.0 |
| `test_timescale_child_units_in_parent` | 22.7 3.14.2.3 20.3.1 | iverilog@13.0 |
| `test_timescale_delay_rounded_to_precision` | 22.7 20.3.3 | iverilog@13.0 |
| `test_illegal_default_nettype_none_assign` (illegal) | 22.8 | iverilog@13.0 |
| `test_illegal_default_nettype_none_port` (illegal) | 22.8 6.10 | iverilog@13.0 |
| `test_unconnected_drive` | 22.9 | iverilog@13.0 |
| `test_vpi_celldefine` | 22.10 22.3 37.10 | iverilog@13.0 |
| `test_pragma_unrecognized` | 22.11 | iverilog@13.0 verilator@5.052 |
| `test_line_directive` | 22.12 22.13 | iverilog@13.0 verilator@5.052 |
| `test_begin_keywords_1364_2005` | 22.14 22.14.5 | iverilog@13.0 verilator@5.052 |
| `test_begin_keywords_versions` | 22.14 22.14.2 22.14.3 22.14.4 22.14.5 22.14.6 22.14.7 22.14.8 22.14.9 | iverilog@13.0 verilator@5.052 |

### Chapter 24

18 hand-written tests; 6 clauses in scope, every one cited, 1 of them by one test only: 24.3.2.

| Test | `:lrm:` | Oracle |
| --- | --- | --- |
| `test_illegal_anonymous_program_hierarchical_reference` (illegal) | 24.3 24.6 | standard only |
| `test_illegal_program_always` (illegal) | 24.3 | iverilog@13.0 verilator@5.052 |
| `test_illegal_program_module_instance` (illegal) | 24.3 | iverilog@13.0 verilator@5.052 |
| `test_illegal_program_signal_from_module` (illegal) | 24.3 23.6 | standard only |
| `test_program_automatic_lifetime` | 24.3 13.4.2 6.21 | iverilog@13.0 verilator@5.052 |
| `test_program_comprehensive` | 24.3 24.2 4.4 | iverilog@13.0 |
| `test_program_end_kills_descendants` | 24.3 9.2.3 | standard only |
| `test_program_hierarchical_reference_between_programs` | 24.3 24.5 23.6 | iverilog@13.0 |
| `test_program_reactive` | 24.3 24.4 4.4 | iverilog@13.0 |
| `test_program_variables` | 24.3 | iverilog@13.0 |
| `test_program_reactive_sees_nba` | 24.3.1 4.4.1 4.4.2.6 | standard only |
| `test_program_port_reactive` | 24.3.2 24.3.1 4.5 | standard only |
| `test_program_stimulus_after_clock_edge` | 24.4 24.3.1 4.4.2.6 | standard only |
| `test_illegal_module_calls_program_task` (illegal) | 24.5 24.3 | standard only |
| `test_program_calls_module_task` | 24.5 24.3.1 4.4.2.6 | standard only |
| `test_anonymous_program` | 24.6 24.3 3.12.1 | standard only |
| `test_exit_outside_program_ignored` | 24.7 24.3 | standard only |
| `test_program_exit` | 24.7 24.3 9.2.3 | standard only |

### Chapter 35

21 hand-written tests; 17 clauses in scope, every one cited, 8 of them by one test only: 35.2.1, 35.5.1.1, 35.5.1.2, 35.5.1.3, 35.5.1.4, 35.5.1.5, 35.6.1.1, 35.6.2.

| Test | `:lrm:` | Oracle |
| --- | --- | --- |
| `test_dpi_one_function_two_imports` | 35.2.1 13.6 35.5.4 35.6 | verilator@5.052 |
| `test_dpi_linkage_names` | 35.4 35.5.4 | verilator@5.052 |
| `test_dpi_import_zero_time` | 35.5.1.1 35.5.1 10.3.2 4.4.2.3 | verilator@5.052 |
| `test_dpi_pure_context_properties` | 35.5.1.3 35.5.2 35.5.3 35.7 | verilator@5.052 |
| `test_dpi_chandle_foreign_memory` | 35.5.1.4 6.14 35.5.6 | verilator@5.052 |
| `test_dpi_import_task_reentrant` | 35.5.1.5 35.8 35.5.3 | standard only |
| `test_dpi_pure_function` | 35.5.2 35.5.4 10.3 | verilator@5.052 |
| `test_dpi_import_small_types` | 35.5.5 35.5.6 H.7.4 H.8.7 H.8.9 H.8.10 | verilator@5.052 |
| `test_dpi_shortreal` | 35.5.6 H.7.4 H.8.7 H.8.9 6.12 | standard only |
| `test_dpi_sized_unpacked_array` | 35.5.6 H.7.6 H.8.7 | verilator@5.052 |
| `test_dpi_unpacked_struct` | 35.5.6 H.7.8 H.8.7 | standard only |
| `test_dpi_unsigned_types` | 35.5.6 35.5.5 H.7.4 H.8.9 | verilator@5.052 |
| `test_dpi_open_array` | 35.5.6.1 35.6.1.1 H.12.1 H.12.2 H.12.3 H.12.7 | verilator@5.052 |
| `test_dpi_open_array_2d` | 35.5.6.1 H.12.2 H.12.3 H.7.6 | verilator@5.052 |
| `test_dpi_import_output_inout` | 35.6.2 35.5.1.2 35.6.1 H.8.8 H.8.10 | verilator@5.052 |
| `test_dpi_export_function` | 35.7 35.5.3 35.4 | verilator@5.052 |
| `test_dpi_export_task_time` | 35.8 35.5.3 35.5.4 35.9 | standard only |
| `test_dpi_disable_import_task` | 35.9 35.8 35.5.3 | standard only |
| `test_dpi_packed_canonical` | H.7.7 H.8.4 H.11.5 35.5.6 | verilator@5.052 |
| `test_dpi_context_scope` | H.9.3 35.5.3 H.9.2 | verilator@5.052 |
| `test_dpi_logic_values` | H.10.1.1 H.10.1.2 H.7.7 H.8.8 | standard only |


## Tests whose expected output follows the standard only

For review by a person: `:oracle: spec` alone, that is, neither Icarus
Verilog 13.0 nor Verilator 5.052 produces the expected output. Why each
release differs is in [docs/simulator-differences.md](simulator-differences.md)
and in the comment of each test.

| Chapter | Tests | Names |
| ---: | ---: | --- |
| 3 | 2 | `test_name_spaces`, `test_timeunit_precedence` |
| 4 | 3 | `test_pli_nba_synch_callback`, `test_reactive_region_set_order`, `test_sched_procedural_assign_deassign` |
| 5 | 1 | `test_string_literal_to_unpacked_byte_array` |
| 6 | 19 | `test_enum_default_and_invalid_index`, `test_enum_wider_than_64_bits_name`, `test_event_variable_alias_null`, `test_illegal_anonymous_struct_not_equivalent`, `test_illegal_interconnect_assigned`, `test_illegal_interconnect_data_type`, `test_illegal_net_type_then_reg`, `test_nettype_initial_value_resolution`, `test_nettype_rename_matches`, `test_nettype_resolution`, `test_shortreal_single_precision`, `test_string_conversion`, `test_string_edge`, `test_string_functions_comprehensive`, `test_string_getc_is_byte`, `test_string_ops_edge_cases`, `test_trireg_default_value_strength`, `test_trireg_holds_charge`, `test_type_operator_matching_types` |
| 7 | 8 | `test_array_index_wider_than_64_bits`, `test_array_map_method`, `test_assoc_allocate_on_write`, `test_assoc_array_unknown_index`, `test_assoc_traversal_narrow_index`, `test_queue_method_edges`, `test_queue_reference_persistence`, `test_tagged_union_packed` |
| 8 | 14 | `test_class_extends`, `test_class_inheritance`, `test_class_inheritance_virtual_super`, `test_illegal_class_implements_type_parameter`, `test_illegal_implements_forward_typedef`, `test_illegal_interface_class_typedef_conflict`, `test_illegal_weak_reference_non_class`, `test_interface_class_cast`, `test_interface_class_randomize`, `test_interface_class_typedef_conflict_resolved`, `test_object_strongly_reachable`, `test_weak_reference_get_clear`, `test_weak_reference_get_id`, `test_weak_reference_wait_cleared` |
| 9 | 9 | `test_always_comb_sensitivity_exceptions`, `test_illegal_always_comb_other_writer`, `test_illegal_always_ff_other_writer`, `test_illegal_always_ff_written_via_function`, `test_illegal_always_latch_other_writer`, `test_process_await_from_fork_child`, `test_process_kill_self`, `test_process_suspend_resume_await`, `test_wait_sequence_triggered` |
| 10 | 4 | `test_alias_part_select_and_ports`, `test_assignment_like_contexts`, `test_net_delay_port_driver_and_undriven`, `test_unpacked_array_concat_rules` |
| 11 | 5 | `test_inside_nested_unpacked_arrays`, `test_memory_invalid_address_2state`, `test_real_operand_result_types`, `gen/ch11/test_gen_xz_cond_07`, `gen/ch11/test_gen_xz_cond_08` |
| 12 | 1 | `test_pattern_matching` |
| 13 | 2 | `test_illegal_function_in_continuous_assign_output`, `test_illegal_ref_in_static_task` |
| 14 | 5 | `test_clocking_input_skew_fractional`, `test_clocking_interface_modport`, `test_clocking_output_net_driver`, `test_clocking_synchronous_events`, `test_global_clocking` |
| 15 | 4 | `test_event_merge`, `test_event_nonblocking_trigger`, `test_event_null_compare`, `test_wait_order` |
| 16 | 41 | `test_assert_immed_2`, `test_clocking_block_assertions`, `test_cover_disable_iff`, `test_cover_property_restrict`, `test_deferred_assertion_flush`, `test_deferred_assertion_per_process`, `test_expect_statement`, `test_global_clocking_sampled_functions`, `test_illegal_multiclock_two_leading_clocks`, `test_illegal_nonoverlapping_antecedent_no_match`, `test_illegal_overlapping_antecedent_empty_only`, `test_illegal_sequence_property_empty_match`, `test_immediate_assertions_2`, `test_inferred_clock_disable`, `test_multiclock_leading_clock`, `test_multiclock_sequences`, `test_past_gating_expression`, `test_procedural_assertion_in_initial`, `test_procedural_assertion_no_glitch`, `test_procedural_concurrent_assertions`, `test_property_abort`, `test_property_implies_iff_followed_by`, `test_property_nexttime_eventually`, `test_property_not_or_and`, `test_recursive_properties`, `test_sampled_in_action_block`, `test_sequence_and_or_intersect`, `test_sequence_consecutive_repetition`, `test_sequence_first_match`, `test_sequence_formal_arguments`, `test_sequence_goto_nonconsecutive`, `test_sequence_instance_vs_triggered`, `test_sequence_local_formal_arguments`, `test_sequence_local_variable_initialization`, `test_sequence_local_variables`, `test_sequence_matched_across_clocks`, `test_sequence_operator_precedence`, `test_sequence_throughout_within`, `test_sequence_triggered`, `test_untyped_formal_arguments`, `test_value_change_first_tick` |
| 17 | 18 | `test_checker_always_comb_output`, `test_checker_always_ff_sampled`, `test_checker_concurrent_assertion`, `test_checker_context_inference`, `test_checker_covergroup`, `test_checker_default_arg_function`, `test_checker_free_variables_assigned`, `test_checker_in_package`, `test_checker_port_connections`, `test_checker_procedural_instance`, `test_checker_reactive_triggered`, `test_illegal_checker_always_ff_blocking`, `test_illegal_checker_free_variable_continuous_assign`, `test_illegal_checker_in_checker_procedure`, `test_illegal_checker_in_fork`, `test_illegal_checker_plain_always`, `test_illegal_checker_variable_hierarchical_write`, `test_illegal_checker_variable_initial_assignment` |
| 18 | 5 | `test_constraint_guard_null`, `test_illegal_solve_before_state_variable`, `test_rand_mode_array_element`, `test_randomize_failure_keeps_values`, `test_randsequence_return_values` |
| 19 | 18 | `test_cg_at_least`, `test_cg_bins_value_resolution`, `test_cg_bins_with_set_expr`, `test_cg_cross_coverage`, `test_cg_cross_illegal_excluded`, `test_cg_cross_select_bins`, `test_cg_cross_set_expression`, `test_cg_cross_with_expression`, `test_cg_embedded_inheritance`, `test_cg_enum_auto_bins`, `test_cg_fixed_count_bins`, `test_cg_ignore_bins`, `test_cg_illegal_bins_removed`, `test_cg_item_weighted_average`, `test_cg_start_stop_counts`, `test_cg_type_coverage_merge`, `test_get_coverage_weights`, `test_option_struct_members` |
| 20 | 10 | `test_array_query_fixed_dimensions`, `test_assert_action_control_tasks`, `test_assertcontrol`, `test_assertion_control_levels_and_scopes`, `test_associative_array_query_functions`, `test_illegal_array_query_variable_dimension`, `test_pla_async_array_plane`, `test_system_call_null_command`, `test_timeunit_timeprecision_functions`, `test_timeunit_unit_root` |
| 21 | 4 | `test_display_format`, `test_format_p_struct`, `test_readmem_multidim_packed`, `test_vcd_dump_readback` |
| 23 | 8 | `test_empty_named_connection_ignores_default`, `test_extern_module`, `test_illegal_defparam_early_resolution`, `test_illegal_interface_port_unconnected`, `test_illegal_named_interface_port_other_type`, `test_interconnect_port_merge`, `test_interconnect_primitive_terminal`, `test_vpi_port_kind_defaults` |
| 24 | 11 | `test_anonymous_program`, `test_exit_outside_program_ignored`, `test_illegal_anonymous_program_hierarchical_reference`, `test_illegal_module_calls_program_task`, `test_illegal_program_signal_from_module`, `test_program_calls_module_task`, `test_program_end_kills_descendants`, `test_program_exit`, `test_program_port_reactive`, `test_program_reactive_sees_nba`, `test_program_stimulus_after_clock_edge` |
| 25 | 4 | `test_illegal_specify_ref_port_terminal`, `test_interface_specify_terminal`, `test_interface_task_export`, `test_modport_clocking_block` |
| 26 | 1 | `test_package_variable_wakes_processes` |
| 27 | 1 | `test_genvar_hierarchical_reference` |
| 28 | 34 | `test_rcmos_reduction`, `test_trireg_charge_decay`, `test_trireg_charge_strength`, `test_trireg_three_delay_form`, `test_wired_logic_strength`, `gen/ch28/test_gen_strength_triand_02`, `gen/ch28/test_gen_strength_triand_03`, `gen/ch28/test_gen_strength_triand_04`, `gen/ch28/test_gen_strength_triand_05`, `gen/ch28/test_gen_strength_triand_06`, `gen/ch28/test_gen_strength_triand_07`, `gen/ch28/test_gen_strength_triand_08`, `gen/ch28/test_gen_strength_trior_02`, `gen/ch28/test_gen_strength_trior_03`, `gen/ch28/test_gen_strength_trior_04`, `gen/ch28/test_gen_strength_trior_05`, `gen/ch28/test_gen_strength_trior_06`, `gen/ch28/test_gen_strength_trior_07`, `gen/ch28/test_gen_strength_trior_08`, `gen/ch28/test_gen_strength_wand_01`, `gen/ch28/test_gen_strength_wand_02`, `gen/ch28/test_gen_strength_wand_03`, `gen/ch28/test_gen_strength_wand_04`, `gen/ch28/test_gen_strength_wand_05`, `gen/ch28/test_gen_strength_wand_06`, `gen/ch28/test_gen_strength_wand_07`, `gen/ch28/test_gen_strength_wand_08`, `gen/ch28/test_gen_strength_wor_02`, `gen/ch28/test_gen_strength_wor_03`, `gen/ch28/test_gen_strength_wor_04`, `gen/ch28/test_gen_strength_wor_05`, `gen/ch28/test_gen_strength_wor_06`, `gen/ch28/test_gen_strength_wor_07`, `gen/ch28/test_gen_strength_wor_08` |
| 29 | 3 | `test_illegal_udp_conflicting_entries`, `test_udp_initial_value_not_delayed`, `test_udp_instance_array_delays` |
| 30 | 4 | `test_illegal_showcancelled_after_path`, `test_negative_pulse_cancelled`, `test_specify_condition_unknown_true`, `test_specify_pulse_filtering` |
| 31 | 18 | `test_illegal_nochange_edge_control`, `test_illegal_period_reference_not_edge`, `test_illegal_width_reference_not_edge`, `test_timing_conditioned_event`, `test_timing_edge_control_specifier`, `test_timing_fullskew_event_based`, `test_timing_nochange`, `test_timing_nochange_window_endpoints`, `test_timing_notifier_x_and_z`, `test_timing_recovery_removal_recrem`, `test_timing_recrem_windows`, `test_timing_setup_hold_notifier`, `test_timing_setuphold`, `test_timing_skew_checks`, `test_timing_timeskew_flags`, `test_timing_timeskew_remain_active`, `test_timing_vector_signal`, `test_timing_width_period_notifier` |
| 32 | 10 | `test_sdf_cond_iopath`, `test_sdf_device_all_paths`, `test_sdf_device_primitive_without_paths`, `test_sdf_increment_absolute`, `test_sdf_label_specparam`, `test_sdf_mtm_spec`, `test_sdf_port_delay`, `test_sdf_scale_factors`, `test_sdf_timing_check_limits`, `test_sdf_width_period_limits` |
| 33 | 14 | `test_config_defparam_precedence`, `test_config_design_top`, `test_config_design_two_tops`, `test_config_hierarchical`, `test_config_instance_deep_path`, `test_config_instance_use`, `test_config_library_binding_format`, `test_config_parameter_override`, `test_illegal_config_cell_library_liblist`, `test_illegal_config_hierarchical_name_in_expression`, `test_illegal_config_instance_inside_other_config`, `test_illegal_config_localparam_not_literal`, `test_illegal_config_package_binding`, `test_illegal_config_two_default_liblists` |
| 35 | 6 | `test_dpi_disable_import_task`, `test_dpi_export_task_time`, `test_dpi_import_task_reentrant`, `test_dpi_logic_values`, `test_dpi_shortreal`, `test_dpi_unpacked_struct` |
| 36 | 6 | `test_vpi_chk_error_callbacks`, `test_vpi_compiletf_sizetf`, `test_vpi_expression_operands`, `test_vpi_systf_argument_on_demand`, `test_vpi_systf_function_in_continuous_assign`, `test_vpi_systf_function_types` |
| 37 | 46 | `test_vpi_active_time_format`, `test_vpi_array_var`, `test_vpi_callback_objects`, `test_vpi_case_loop_force_stmts`, `test_vpi_class_definitions`, `test_vpi_class_obj_id`, `test_vpi_clocking_blocks`, `test_vpi_constant_select`, `test_vpi_constraint_items`, `test_vpi_cont_assign_drivers`, `test_vpi_delay_expressions`, `test_vpi_file_line`, `test_vpi_frames_and_threads`, `test_vpi_generate_scopes`, `test_vpi_instance_arrays`, `test_vpi_interconnect_elements`, `test_vpi_interface_program`, `test_vpi_interface_typespecs`, `test_vpi_is_protected_property`, `test_vpi_iterator_objects`, `test_vpi_let_expr_arguments`, `test_vpi_module_paths`, `test_vpi_module_relations`, `test_vpi_named_events`, `test_vpi_net_properties`, `test_vpi_nettype_declarations`, `test_vpi_packed_array_vars`, `test_vpi_parameters`, `test_vpi_ports`, `test_vpi_prefix_has_actual`, `test_vpi_process_statements`, `test_vpi_property_sequence_decls`, `test_vpi_property_sequence_exprs`, `test_vpi_put_value_side_effect`, `test_vpi_ref_obj_actual`, `test_vpi_relationships_and_tags`, `test_vpi_scopes`, `test_vpi_struct_typespecs`, `test_vpi_systf_argument_expressions`, `test_vpi_time_queue`, `test_vpi_timing_checks`, `test_vpi_type_strings`, `test_vpi_udp_definitions`, `test_vpi_variable_drivers_loads`, `test_vpi_variable_properties`, `test_vpi_virtual_interface_vars` |
| 38 | 8 | `test_vpi_gate_delays`, `test_vpi_get_cb_info`, `test_vpi_get_value_array`, `test_vpi_handle_by_multi_index`, `test_vpi_put_value_array`, `test_vpi_put_value_delay_modes`, `test_vpi_statement_callbacks`, `test_vpi_value_change_event` |
| 39 | 13 | `test_vpi_assertion_callback_scope_removal`, `test_vpi_assertion_callbacks`, `test_vpi_assertion_control`, `test_vpi_assertion_deferred_queue`, `test_vpi_assertion_gclk_future_callback`, `test_vpi_assertion_handles`, `test_vpi_assertion_immediate_callbacks`, `test_vpi_assertion_kill_reset`, `test_vpi_assertion_procedural_queue`, `test_vpi_assertion_step_callbacks`, `test_vpi_assertion_system_control`, `test_vpi_assertion_system_lock_reset`, `test_vpi_assertion_system_vacuous_actions` |
| 40 | 11 | `test_coverage_api_minimum_types`, `test_coverage_control_bad_arguments`, `test_coverage_control_results`, `test_coverage_get_values`, `test_coverage_reset_and_stop`, `test_coverage_root_hierarchy`, `test_coverage_save_merge`, `test_coverage_scope_sums`, `test_vpi_coverage_assertion`, `test_vpi_coverage_control`, `test_vpi_fsm_from_pragmas` |


## Plan for phases 1 to 4

### Phase 1: runners

- Add `:defines:` (`NAME` or `NAME=VALUE`, separated by spaces),
  `:incdirs:` (directories relative to the test) and `:top_module:` to
  `tools/suite_results.py`, and pass them in every runner: Icarus Verilog
  `-D`, `-I`, `-s`; Verilator `-D`, `-I`, `--top-module`; kirimasim
  `+define+`, `+incdir+`, `--top=` (its CLI.md lists them). `:args:`,
  `:files:`, `:expected_exit:` and the illegal
  designs stay as they are.
- README.md: the new fields in "Metadata", and how runners use them.
- One small test for each new field: a macro value from `:defines:`, an
  `` `include `` found through `:incdirs:`, and a design with two top-level
  candidates where `:top_module:` picks one. The other fields already have
  tests.

### Phase 2: lint and template

- `tools/lint_metadata.py`, run by the readme job of check.yml: required
  fields, allowed values, `:lrm:` of the form `1800-2023 N.N...` whose first
  chapter is the directory, `:tags:`, `:fourstate: no` with x or z literals,
  `:expected_stdout:` naming a file that exists and is not empty,
  `:should_fail_because:` only with `:type: elaboration` and with
  `:expected_stderr_regex:`, and the rules of "Contributing" that a script
  can check (line lengths, no comment line starting with the word
  Verilator, a `` `timescale `` when a time is printed). Existing tests that
  it flags are listed, not changed.
- `tools/new_test.py ch16 test_name --lrm "16.9.3"` writes the header and an
  empty `.expected`; README.md, "Contributing", says how to use it.

### Phase 3: tests

- 3-1: at least 20 illegal designs, first the three rules above that have
  none (`:final`, real in a packed array, delay in always_comb), then other
  rules of the same kind, written from the standard. kirimasim's
  `tests/suite/` has illegal designs with expected errors; where one is
  ported, it is rewritten in the form of this suite.
- 3-2: at least 30 tests in `tests/ch4` of the items above, in particular
  `wait` with nonblocking updates, chains of `#0`, a loop of zero delays, and
  fork-join_none in a function, all with an order that the standard fixes.
- 3-3: a generator in `generators/` for values wider than 64 bits through
  paths that `width_sign` does not use (function results, both arms of `?:`,
  ref and output arguments, task arguments, part selects with `+:`, `-:`
  and variable indices, partial writes, concatenation and replication,
  shifts by more than 64, comparisons, `%h`, `%b`, `%d`, `$bits`), 2-state
  and 4-state, signed and unsigned, with x and z in the upper chunk; about 40
  files in `tests/gen/`, with the generator kept for regeneration.
- 3-4: the features of the table above that no test uses: triple-quoted
  strings, `` `ifdef `` expressions, `:final`, `:initial` and `:extends`,
  the index argument of array methods, `rand real`, `[a +/- b]` and
  `[a +%- b]`, `type(this)`, `default :/` in dist, `super.new(default)`,
  `union soft`; each with a legal test and, where the clause has a rule, an
  illegal design. The features that already have tests (`map()`,
  `$timeunit`, `$timeprecision`, `$stacktrace`, `weak_reference`,
  covergroup `extends`) get more only where a clause has no test yet.
- 3-5: about 10 tests of `:args:` (each format of `$value$plusargs`, the
  first of several matches, 0 when nothing matches), `:defines:`,
  `:incdirs:`, `:files:` (packages and interfaces in separate files, `$unit`
  with several compilation units, 3.12.1, without depending on how a tool
  groups files) and `:top_module:`.

### Phase 4: nightly ratchet (optional)

A job in nightly.yml that fails when a kirimasim test that matched in the
previous run on the `results` branch (`latest/kirimasim.json`) no longer
matches; new tests and unsupported ones do not fail it, and it is skipped
when there is no previous run.

Each phase runs the Icarus Verilog and Verilator runners on every test,
updates the README tables and the catalog with their scripts, and becomes one
commit; nothing is pushed until asked.

## Final report

The phases above were carried out on 2026-10-21, each as local commits:
ce32c60 (this inventory), b82e845 (phase 1), 5a86259 (phase 2), 59d87b3,
afc9988, 78194e0, 05507ef and 87fbcac (phases 3-1 to 3-5), 66fa34f (phase 4),
and the commit that adds this report.

### Tests added

136 tests, 87 of them run (simulation) and 49 generated by
`generators/wide_paths.py`, of which 47 are illegal designs. The oracle
columns follow `:oracle:`: "both" is `iverilog@13.0 verilator@5.052`.

| Chapter | Tests | Both | Icarus Verilog 13.0 only | Verilator 5.052 only | Standard only | Illegal designs | Generated |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 4 | 30 | 24 | 2 | 2 | 2 | | |
| 5 | 2 | 1 | | 1 | | 1 | |
| 6 | 11 | 1 | 8 | 2 | | 4 | 7 |
| 7 | 19 | 1 | 8 | 8 | 2 | 3 | 14 |
| 8 | 16 | 2 | 1 | 8 | 5 | 12 | |
| 9 | 4 | | 4 | | | 4 | |
| 11 | 15 | | 14 | | 1 | | 14 |
| 12 | 1 | | | | 1 | 1 | |
| 13 | 18 | 2 | 6 | 8 | 2 | 4 | 14 |
| 18 | 4 | | | 1 | 3 | 2 | |
| 21 | 2 | 2 | | | | | |
| 22 | 9 | 7 | | 2 | | 2 | |
| 23 | 2 | 2 | | | | | |
| 25 | 1 | | | 1 | | | |
| 26 | 2 | 1 | 1 | | | 1 | |
| All | 136 | 43 | 44 | 33 | 16 | 34 | 49 |

The illegal designs of the table are those of phases 3-1 (22) and 3-4
(12). Besides the tests, the work added three metadata fields
(`:defines:`, `:incdirs:`, `:top_module:`) to every runner,
`tools/lint_metadata.py` with `tools/lint_baseline.txt`, `tools/new_test.py`,
`tools/results_ratchet.py`, and the ratchet step of the nightly kirimasim
job.

### Where the work followed the existing conventions

Besides the table at the top of this file:

- Phase 3 became five commits, one for each of its parts, instead of one.
- Phase 3-3 has 49 files, seven widths for each of seven families, rather
  than about 40.
- Phase 3-5 did not repeat what tests of 21.6 already covered: each format of
  `$value$plusargs`, the first match, no match, and prefix matches of
  `$test$plusargs`. `$unit` across files was left out, since how a tool groups
  files into compilation units is its own (3.12.1), and the suite does not
  depend on it.
- The lint fails only on problems that `tools/lint_baseline.txt` does not
  list, so that the existing tests that break a rule are reported without
  being changed.

### Where Icarus Verilog 13.0 and Verilator 5.052 disagreed

Tests that both releases ran to an output or a verdict, and where they gave
different ones; the clause decided, and docs/simulator-differences.md lists
each place.

| Test | Icarus Verilog 13.0 | Verilator 5.052 | Clause |
| --- | --- | --- | --- |
| `ch4/test_sched_strobe_after_zero_delays_and_nba` | follows the standard | `$strobe` shows the value from before the nonblocking update | 21.2.2, 4.4.2.9 |
| `ch4/test_sched_monitor_once_per_time_step` | follows the standard | `$monitor` shows the value from before the writes after `#0` | 21.2.3, 4.4.2.9 |
| `ch4/test_sched_fork_join_none_in_function` | rejects the delay in the spawned process | follows the standard | 13.4.4 |
| `ch4/test_sched_disable_fork_in_called_task` | disable fork in a task does not end the caller's child | follows the standard | 9.6.3 |
| `ch8/test_type_this` | does not support type(this) | rejects type(this) in a static method | 6.23, 8.11 |
| `gen/ch7/test_gen_wide_select_*_2state` | rejects a write through a variable index of a packed array, then stops on an internal assertion | follows the standard | 7.4.5, 11.5.1 |
| `ch13/test_illegal_function_fork_join_any`, `ch12/test_illegal_break_in_fork_to_outer_loop` and the others of the next list | accept or reject as listed there | | |

Two more disagreements did not become tests as first written. In
`ch4/test_sched_deferred_action_arguments` the first expectation was wrong:
by 16.4 the by-value arguments of the action block of a deferred assertion
are evaluated with its expression, and the test was rewritten to show that
and a const ref argument; Verilator runs the action block at once, and Icarus
Verilog does not support deferred assertions. A test that redefined in the
source a macro that a tool option had defined was dropped: Icarus Verilog
keeps the source's definition and Verilator (and kirimasim) the option's, and
the standard leaves options to the tool.

### Illegal designs that a release accepts

- Icarus Verilog 13.0: `ch13/test_illegal_function_fork_join_any` and
  `ch12/test_illegal_break_in_fork_to_outer_loop`; it stops on an internal
  assertion for `ch6/test_illegal_dynamic_array_element_continuous`.
- Verilator 5.052: `ch7/test_illegal_packed_array_of_real`,
  `ch9/test_illegal_always_comb_delay`,
  `ch9/test_illegal_always_comb_event_control`,
  `ch9/test_illegal_always_comb_fork_join`,
  `ch9/test_illegal_always_latch_delay`,
  `ch13/test_illegal_ref_in_static_function`,
  `ch8/test_illegal_global_constant_assigned_in_constructor`,
  `ch8/test_illegal_static_instance_constant`,
  `ch6/test_illegal_enum_sized_literal_width`,
  `ch12/test_illegal_break_in_fork_to_outer_loop`,
  `ch26/test_illegal_local_declaration_after_import` and
  `ch8/test_illegal_final_pure_virtual`.

Twelve rejections by Icarus Verilog 13.0 come from constructs that it does not
support and fall on the line the test names (`:final`, `:initial`,
`:extends`, `type(this)`, `static const`, ref arguments, `` `ifdef ``
expressions, constraints, `sum` of a queue, `default` in `super.new`). The
comments of the tests say so, and the check workflow shows them as NOW
MATCHES, 38 lines now.

### Existing tests that the lint flags

`tools/lint_baseline.txt` lists 378 problems, none of them changed:

- width: 368 tests with comment lines over 80 or code lines over 100 columns,
  written before that rule of Contributing;
- fourstate: `ch5/test_operator_token_lengths`, `ch19/test_cg_wildcard_bins`,
  `ch20/test_pla_async_array_plane` and `ch37/test_vpi_case_loop_force_stmts`
  have `:fourstate: no` and an x, z or `?` literal;
- chapter: `ch35/test_dpi_context_scope`, `ch35/test_dpi_logic_values` and
  `ch35/test_dpi_packed_canonical` cite a clause of Annex H first, and
  `ch36/test_vpi_systf_argument_on_demand` one of chapter 37;
- timescale: `ch21/test_display_format_edge_cases` prints `%t` of time 0 and
  `ch37/test_vpi_active_time_format` calls `$timeformat` without a
  `` `timescale ``; the check is a heuristic, and neither output seems to
  depend on the time unit.

### Tests whose expected output follows the standard only

The existing ones are listed by chapter above. The work adds 16:
`ch4/test_sched_deferred_action_arguments`,
`ch4/test_sched_nonblocking_event_trigger`,
`ch7/test_array_method_index_argument`,
`ch7/test_illegal_iterator_argument_without_with`,
`ch8/test_illegal_final_pure_virtual`,
`ch8/test_illegal_static_instance_constant`,
`ch8/test_illegal_super_new_default_without_default`,
`ch8/test_super_new_default`,
`ch8/test_type_this`, `ch11/test_inside_tolerance_ranges`,
`ch12/test_illegal_break_in_fork_to_outer_loop`,
`ch13/test_illegal_ref_in_static_function`, `ch18/test_dist_default_weight`,
`ch18/test_illegal_dist_two_defaults`, `ch18/test_rand_real_constraint` and
`gen/ch13/test_gen_wide_subroutine_w65_4state`.

### kirimasim on the new tests

A local build of kirimasim (commit 8b23f517c274) matches 125 of the 136; 8
use what it does not support yet, and 3 differ:

- `ch13/test_illegal_function_fork_join_any`: kirimasim reports the error at
  `join_any` (line 25), not at `fork` (line 22), which the test names.
  The test was not changed to follow kirimasim: the place of the error is
  the fork that starts the statement, and `ch13/test_illegal_function_fork_join`
  was changed afterwards to name only its fork as well. kirimasim reports
  that one at its `join` too, so it no longer matches it; kirimasim issue
  [#34](https://github.com/kurochan001/kirimasim/issues/34) asks for both
  errors at the fork.
- `ch26/test_illegal_local_declaration_after_import`: kirimasim reports the
  reference that imports `limit` (line 25); 26.3 makes the later local
  declaration (line 26) the illegal one.
- `ch21/test_plusargs_key_from_variable`: kirimasim does not accept an
  integral variable as the plusarg string, which 21.6 allows.

### Versions of the local simulators

`iverilog` on `PATH` is 14.0 (devel); every oracle run used Icarus Verilog
13.0 (stable) (v13_0) through `--iverilog-bin`. Verilator is 5.052
2026-09-05.

## Tests added after this report

The tests below were added on 2026-10-22, after the report above. The work
of the report left chapters 3, 14, 17, 24, 26, 29, 32, 33, 36, 39 and 40
with the fewest tests. Two later commits added 19 tests to them,
`b43cfa4` (12 tests) and `3c2472f` (7 tests). The suite then had 3699
tests.

| Chapter | Tests | Which |
| ---: | ---: | --- |
| 3 | 2 | the order of `timeprecision` and `timeunit`, and the state shared through `$unit` |
| 14 | 2 | default clocking skews, and a clocking event gated by `iff` |
| 17 | 3 | `always_latch` and a generate loop in checkers, and the illegal instance of a checker in a function |
| 24 | 3 | `$exit` in a task, the state and parameters of program instances, and a final procedure of a program |
| 26 | 2 | `export *::*`, and an import in an interface header |
| 29 | 1 | the rise and fall delays of a sequential UDP instance |
| 32 | 2 | the `TIMESCALE` of an SDF file, and an unknown `COND` condition |
| 33 | 1 | an instance rule that overrides a cell rule |
| 36 | 1 | a user-defined system task in a program and in a final procedure |
| 39 | 1 | the `cbAssertionSuccess` callback of a cover property |
| 40 | 1 | an interface instance as the scope of the coverage calls |

By `:oracle:`, Icarus Verilog 13.0 recorded 7 of them, Verilator 5.052
(seeds 1 and 7) 7, and 5 follow the standard only. One is an illegal
design, two have VPI C code, and two depend on x or z values.

The tests found four places where a release differs from the standard,
all listed in [simulator-differences.md](simulator-differences.md):

- Verilator 5.052: `$exit` called in a task returns from the task instead
  of ending the initial procedures of the program (24.7).
- Verilator 5.052: a sequential UDP instance with two delays changes its
  output at the clock edge and uses neither delay (29.8).
- Icarus Verilog 13.0: it ignores the `TIMESCALE` of an SDF file and reads
  its delay values in the time unit of the design (32.3).
- Icarus Verilog 13.0: it treats the unknown condition of an SDF `COND`
  entry as false; such a condition is true (30.4.4.1, 32.4.1).

### Six more tests

A third commit, `b0994fd`, added 6 more tests to the thinnest chapters;
the suite then had 3705 tests. `0641d74` initialized the output port of
`test_program_clocking_output`, because Verilator gives an uninitialized
variable a random initial value, which changed the result with seed 7.

| Chapter | Tests | Which |
| ---: | ---: | --- |
| 3 | 2 | an import at the compilation-unit scope, and the time unit of a class in a package |
| 24 | 1 | a clocking block, with its output skew, in a program |
| 36 | 1 | a user-defined system task called from an always procedure |
| 39 | 1 | the `cbAssertionStart` callback of every attempt of a cover property |
| 40 | 1 | a program instance as the scope of the coverage calls |

The two chapter 3 tests list both Icarus Verilog 13.0 and Verilator
5.052; the chapter 36 test lists Icarus Verilog 13.0, the chapter 24
test Verilator 5.052, and the chapter 39 and 40 tests follow the
standard only. No new simulator difference was found.

### Five more tests

A fourth commit, `fea36a2`, added 5 more tests; the suite then had 3710
tests.

| Chapter | Tests | Which |
| ---: | ---: | --- |
| 3 | 1 | the time unit of a task in an interface |
| 24 | 1 | a clocking block input skew in a program |
| 36 | 1 | a user-defined system task called from a class method |
| 39 | 1 | the disable of an immediate assertion through VPI |
| 40 | 1 | a package as the scope of the coverage calls |

The chapter 3 test lists both Icarus Verilog 13.0 and Verilator 5.052;
the chapter 36 test lists Icarus Verilog 13.0, the chapter 24 test
Verilator 5.052, and the chapter 39 and 40 tests follow the standard
only. No new simulator difference was found.

### Three more tests

A fifth commit, `4ff57d6`, added 3 more tests; the suite then had 3713
tests.

| Chapter | Tests | Which |
| ---: | ---: | --- |
| 32 | 1 | separate `SETUP` and `HOLD` entries of an SDF file |
| 33 | 1 | a cell rule that binds its instances with parameter overrides |
| 39 | 1 | the VPI handles of immediate assert, assume and cover statements |

None of the three is produced by Icarus Verilog 13.0 or Verilator
5.052, so all follow the standard only. No new simulator difference was
found.

### Three further tests

A sixth commit, `c7d3edb`, added 3 more tests; the suite then had 3716
tests.

| Chapter | Tests | Which |
| ---: | ---: | --- |
| 3 | 1 | the time unit of a program |
| 39 | 1 | the absence of a failure callback for a cover that does not match |
| 40 | 1 | saving coverage after a stop |

Verilator 5.052 produces the chapter 3 test; the chapter 39 and 40
tests follow the standard only. No new simulator difference was found.

### Three tests of SDF, VPI and coverage

A seventh commit, `f6b1fab`, added 3 more tests; the suite then had 3719
tests.

| Chapter | Tests | Which |
| ---: | ---: | --- |
| 32 | 1 | the `RECREM` entry of an SDF file |
| 36 | 1 | a user-defined system task called from a generate block |
| 40 | 1 | the `NOCOV` answer for a module definition with no instances |

Icarus Verilog 13.0 produces the chapter 36 test; the chapter 32 and 40
tests follow the standard only. No new simulator difference was found.

### 61 more tests

A final batch of 61 tests brought the additions to 100 (39 + 61). They
were written in the thinnest chapters:

| Chapter | Tests | Which |
| ---: | ---: | --- |
| 3 | 7 | time units and precision, including an illegal coarser precision |
| 14 | 14 | input, output, default and edge-clock skews of clocking blocks |
| 17 | 6 | checker ports, always procedures, generate instances and contexts |
| 24 | 6 | program ports, initial and final procedures, clocking and `$exit` |
| 26 | 6 | explicit and wildcard imports, exports and header imports |
| 29 | 12 | UDP delays, edge symbols, initial values and table matching |
| 36 | 5 | system tasks called from tasks, forks, startups and compiletf |
| 39 | 3 | assertion system controls, procedural callbacks and per-instance controls |
| 40 | 2 | coverage reset/merge and control by definition or instance |

By `:oracle:`, Icarus Verilog 13.0 recorded 33 of them, Verilator 5.052
21, and 7 follow the standard only. Two are illegal designs. The tests
found three further places where a release differs, all in
[simulator-differences.md](simulator-differences.md): Verilator's
explicit-import precedence (26.3) and `$exit` from a program fork
(24.7), and Icarus Verilog's named wildcard export (26.5).

### 12 second tests for the priority queue

The depth report found 68 clauses with one test and only a standard-only
expectation. A first slice adds a second test for 12 of them:

| Clause | New test | Oracle |
| ---: | --- | --- |
| 4.9.2 | `ch4/test_sched_procedural_assign_part_select` | both |
| 7.8.7 | `ch7/test_assoc_allocate_on_write_types` | Verilator |
| 7.10.2.1 | `ch7/test_queue_size_method` | both |
| 7.10.2.2 | `ch7/test_queue_insert_positions` | both |
| 7.10.2.4 | `ch7/test_queue_pop_front_order` | both |
| 7.10.2.5 | `ch7/test_queue_pop_back_order` | both |
| 10.10.2 | `ch10/test_unpacked_concat_vector_string` | both |
| 14.7 | `ch14/test_clocking_scope_names` | Verilator |
| 14.9 | `ch14/test_clocking_interface_plain_port` | Verilator |
| 14.15 | `ch14/test_clocking_event_controls` | Verilator |
| 21.4.3 | `ch21/test_readmemh_address_range` | both |
| 33.7 | `ch33/test_config_binding_nested` | Verilator |

The priority queue fell from 68 to 55 clauses, the clauses with one test
from 191 to 177, and the clauses with only standard-only tests from 265
to 252. The tests with both releases rose from 164 to 171. The next
slice should continue with the remaining 55.

The clause text also requires `%L`; `ch33/test_config_binding_upper`
adds it, recorded with Verilator, so the suite then had 3793 tests.

### Clause-text corrections

Reading the clause text in the IEEE 1800-2023 PDF found three
corrections to the metadata:

- `3.11` is “Overview of hierarchy”, not the behavior of top-level
  modules. `test_top_level_instances` moved to `ch23`, cites `23.3.1`,
  and `3.11` is tagged `none` again. This is one of the reasons the
  one-test count is 177 rather than 178.
- `37.69` is “Repeat control”; the test that cites it is right, and the
  clause list now has it.
- `21.7.1.1` to `21.7.1.4` and `21.7.1.6` name the `$dumpfile`,
  `$dumpvars`, `$dumpoff`/`$dumpon`, `$dumpall` and `$dumpflush`
  controls, not the content of a VCD file. They are in scope again; only
  `21.7.1.5` (`$dumplimit`) and the VCD content clauses that no test reads
  keep the `dump` tag.
- `21.7.2.1` to `21.7.2.3` and `21.7.5` are VCD content clauses that
  `test_vcd_dump_readback` does read back, so their `dump` tag goes as
  well. The README says that these four are in scope.
- `8.30.1` is an overview, but it also says that the parameter type of
  `weak_reference` shall be a class type, which is behavior. Its `none`
  tag goes. `25.3.3` is called an example, but it also says that a
  generic interface reference in a non-ANSI port list is illegal; its
  `none` tag goes too.
- `25.7.2` and `25.7.3` are examples of tasks in modports and of
  exporting tasks, not behavior. The two tests that cited them now cite
  25.5 instead.
- `25.3.1` is an example without interfaces and `34.5.x.1` are the
  syntax subclauses of the excluded clause 34; both are in the clause
  list now, tagged `none` and `excluded`.

### VPI object model and binding properties

The eleven VPI statement clauses 37.55, 37.62, 37.66, 37.67, 37.70,
37.71, 37.73, 37.74, 37.77, 37.78 and 37.83, and the 33.7 properties
`vpiLibrary`, `vpiCell` and `vpiConfig`, have no release that can run
them. They are covered by three spec-only tests: one lists the statement
types, one reads an attribute object, and one reads the three module
properties. `tools/clauses.txt` has the eleven clauses again. The depth
report therefore counts eleven new one-test spec-only clauses; a second
test for them needs a VPI-capable simulator.

### Review fixes of 2026-10-22

The content review in [test-content-review-20261022.md](test-content-review-20261022.md)
found twelve problems in twenty-four tests. They are fixed:

- F01: the procedural assign to a part-select is now an illegal design in
  `ch10/test_sched_procedural_assign_part_select`; the clause list and the
  simulator differences say that Icarus Verilog 13.0 and Verilator 5.052
  accept it.
- F02: the two package export tests now import the names they re-export
  explicitly; both releases reproduce them, and they cite 26.6.
- F03: the output-driven variables of the program and checker tests no
  longer have declaration initializers.
- F04: the program tests keep a second initial procedure alive past the
  module observation, so the implicit finish of 24.3 does not cut it off.
- F05: `before`, a reserved word, is renamed to `value_before` in the
  coverage save test.
- F06: the expect statement in the VPI statement test has an explicit
  `@(posedge en)` clock.
- F07: the fast checker in the context test keeps `fast_ok` low through
  the edge at 42.
- F08: the nine VPI C files copy each `vpi_get_str()` result before the
  next call, as 38.11 requires.
- F09: the exported wait task of the reentrant DPI test is automatic.
- F10: the setup violation is reported at the reference edge, 10, not at
  the data change, 7.
- F11: the recrem checks use `(d, posedge clk, ...)`, and the RECREM entry
  annotates the separate `$removal` check too; the expected notifiers are
  updated.
- F12: the coverage definition test rejects `SV_COV_ERROR` from every
  control and query; `SV_COV_NOCOV` and `SV_COV_PARTIAL` stay allowed.
  An all-ERROR implementation can no longer pass.

The follow-up review in
[test-content-review-followup-20261022.md](test-content-review-followup-20261022.md)
found three remaining points, all fixed:

- R01: the two program clocking tests give the program output formal a
  default initial value, so they see q=0 at 6 and q=1 at 8 again.
- R02: the coverage definition test accepts NOCOV/PARTIAL from START and
  only fails on ERROR.
- R03: its comparisons check that both query values are not ERROR before
  comparing them; the start and stop of the whole definition are checked
  too.

### Matching rounds of 2026-10-25 and 2026-10-26

Thirteen pending batches (p01, p05, p07, p12, p09, p10, p13, p15 and
the annex batches a01-a05, g05, g08, g09, h01, h02) were independently
verified and merged. Of 1388 proposals, 1365 were accepted and 23
rejected; 620 new tests were added. Eighteen tests found defective were
repaired (eight `input var` ports, four diagnostic locations, a comment
width, three `:oracle:` entries and a clause citation) before the merge.
Four tests with remaining semantic defects stayed out. Restoring the ch22
include fixtures changed the include-directory digest of ten existing
mappings; they were rehashed and re-run, and the baseline updates record
why.

A further creation round added header and distribution tests: K.2 (31
accepted), I.3 (55) and N.2 (7), 18 tests. One I.3 test with a reversed
array-pattern expectation was excluded.

Another creation round added assertion control (20.11, 42 accepted),
coverage control and VPI coverage (40.3.2.1/40.5.2, 20), checker
declarations (17.2/17.3/17.7.2, 29) and 1364 compatibility (36.12.1, 8),
30 tests. One checker test that relied on a program's implicit finish was
excluded.

The final round covered Annex A grammar in four partitions: 369 links
were applied from the 517 proposals, with 93 tests kept after the
independent review. Fifteen tests with wrong expectations or illegal
syntax stayed out; five repaired tests were re-verified first. This
takes the ledger past the 75% target: 9244 of 12319 rows (75.04%).

An execution audit then ran the whole suite and found 277 spec-only
tests whose output or diagnostic already matches Icarus Verilog 13.0.
They now list iverilog@13.0, and their requirements count as executed:
5270 of 12319 rows (42.78%). Verilator matched none of the spec-only
tests, and 179 requirements with a fixed oracle still lack fresh
evidence.

### Current state

After these commits the suite has 6799 tests in 37 chapters, 1308 of them
generated. By `:oracle:`, 4092 list Icarus Verilog 13.0, 1339 list
Verilator 5.052, and 1368 follow the standard only. 855 tests depend on
x or z values, 512 have C code (97 DPI and 415 VPI), 1695 are illegal
designs, and 33 set an expected exit code. The requirement ledger maps
9244 of 12319 rows (75.04%), with 5270 executed (42.78%).

### Tests added in this work

| Chapter | Tests |
| ---: | ---: |
| 3 | 13 |
| 14 | 16 |
| 17 | 9 |
| 24 | 11 |
| 26 | 8 |
| 29 | 13 |
| 32 | 4 |
| 33 | 2 |
| 36 | 9 |
| 39 | 8 |
| 40 | 7 |
| **All** | **100** |

The 12 second tests in the depth follow-up, the `%L` test, the five
illegal clocking tests, and the three spec-only VPI tests bring the
total added in this work to 121.

### 14.7 illegal placements

The clause text also fixes where a clocking block may be declared. Five
illegal designs add the missing negative cases: in a function, in a task,
in a package, nested in another clocking block, and at the compilation-unit
scope. Verilator 5.052 rejects each at the named line; Icarus Verilog
13.0 rejects them too, but because it does not support clocking blocks.
