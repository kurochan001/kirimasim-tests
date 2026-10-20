# Where Icarus Verilog 13.0 and Verilator 5.052 differ from the standard

The expected outputs of the suite follow IEEE 1800-2023 and are checked with
Icarus Verilog 13.0 and Verilator 5.052 (see "Where the expected outputs come
from" in the README). This file lists the places found so far where one of
these releases gives another result than the cited clauses require, or
accepts a design that the standard makes illegal, with the tests that show
it.

Constructs that a release does not support at all, where it stops with an
error, a "sorry" or "unsupported" message, are not listed: they show as known
differences that do not compile. Verilator's lack of x, z and strengths, as a
two-state simulator, is not listed either.

None of these has been reported to the projects. Before reporting one, check
it with the current development version: the [nightly
report](https://github.com/kurochan001/kirimasim-tests/tree/results#readme)
runs the latest `master` of both, and a known difference that a development
version now matches shows there as `NOW MATCHES` for Icarus Verilog or as a
new match.

When a new test finds such a place, add it here, and say it in the comment
of the test as well.

## Icarus Verilog 13.0

### Results

| Clause | What Icarus Verilog 13.0 does | Tests |
| --- | --- | --- |
| 11.4.11 | With an x or z condition, `?:` gives z where both operands have z in the same bit; Table 11-20 gives x. | `gen/ch11/test_gen_xz_cond_07`, `_08` |
| 28.12.1, 28.12.4 | On wand, wor, triand and trior nets it ignores the strengths of the drivers: it combines their values with the logic function and gives the result strong strength. The stronger driver has to win, and only drivers of equal strength are combined, at that strength. | the 29 `gen/ch28/test_gen_strength_{wand,wor,triand,trior}_*` tests with `:oracle: spec` |
| 30.4.4.1 | It treats the condition of a state-dependent path as false when it is x or z; it has to be treated as true. | `ch30/test_specify_condition_unknown_true` |
| 28.14 | rcmos passes a strong drive as strong; it has to reduce it to pull, as rtran and rtranif do. | `ch28/test_rcmos_reduction` |
| 29.7 | The delay of a sequential UDP instance also delays its initial value, which shows x until then. | `ch29/test_udp_initial_value_not_delayed` |
| 24.3 | When a program's initial procedures end, the threads they forked go on running; they have to end with the program. | `ch24/test_program_end_kills_descendants` |
| 24.5, 24.3.1 | A program's thread, and a module task it calls, run in the Active region with the module's processes instead of in the Reactive region: the call sees a variable before the nonblocking update of its time step, and runs before the module's own processes of the time step it resumes in. | `ch24/test_program_calls_module_task` |
| 24.3.1 | A program's process sees the values from before the nonblocking updates of its time step (Verilator 5.052 too). | `ch24/test_program_reactive_sees_nba` |
| 10.6.1, 4.9.2 | `assign` (procedural continuous) evaluates its right-hand side once, so the variable does not follow later changes (it warns about this; Verilator 5.052 does the same). | `ch4/test_sched_procedural_assign_deassign` |
| 11.5.2, 7.4.5 | Reading a 2-state memory at an invalid address gives x instead of the default value 0. | `ch11/test_memory_invalid_address_2state` |
| 22.5.3 | It does not know `` `undefineall `` and treats it as an empty macro, so the macros stay defined. | `ch22/test_undefineall` |
| 32.5 | It applies INCREMENT delays of an SDF file as absolute ones. | `ch32/test_sdf_increment_absolute` |
| 32.4.1 | It leaves module paths with COND entries at their specify delays. | `ch32/test_sdf_cond_iopath` |
| 32.4.3 | It does not read the LABEL section of an SDF file. | `ch32/test_sdf_label_specparam` |
| 32.9 | It uses only the first two arguments of `$sdf_annotate`, and rejects an empty module instance argument. | `ch32/test_sdf_mtm_spec`, `ch32/test_sdf_scale_factors` |
| 33 | It skips config declarations without an error, so the design is not configured. | `ch33/test_config_cell_use`, `ch33/test_config_cell_with_library`, `ch33/test_config_defparam_precedence`, `ch33/test_config_design_top`, `ch33/test_config_design_two_tops`, `ch33/test_config_instance_deep_path`, `ch33/test_config_instance_use`, `ch33/test_config_library_binding_format` |
| 31 | It skips timing checks such as `$setup`, `$timeskew` and `$fullskew` without an error, so their notifiers never change. | `ch31/test_timing_timeskew_flags`, `ch31/test_timing_timeskew_remain_active`, `ch31/test_timing_fullskew_event_based`, `ch31/test_timing_notifier_x_and_z` and the other tests of chapter 31 with `:oracle: spec` |
| 36.10.1, 38.36.2 | `vpi_chk_error` reports no error after `vpi_register_cb` refuses a callback that the standard makes an error, and a cbAtStartOfSimTime with delay 0 makes it stop on an internal assertion. | `ch36/test_vpi_chk_error_callbacks` |
| 37.42 | It evaluates an argument of a user-defined system task that the application never reads; such an argument must not be evaluated. | `ch36/test_vpi_systf_argument_on_demand` |
| 38.34 | `vpi_put_value` keeps every scheduled event in all three delay modes; inertial delay has to cancel the pending ones. | `ch38/test_vpi_put_value_delay_modes` |
| 38.36.1 | A value change callback on a named event gets a value structure. | `ch38/test_vpi_value_change_event` |
| 36.8.1 | User-defined system functions need their return types at compile time (in a `.sft` file), and it stops at the first real result. | `ch36/test_vpi_systf_function_types` |
| 9.6.1, 9.6.3 | It stops with an internal assertion. | `ch9/test_wait_fork_disable_fork` |
| 7.10.2.4, 7.10.2.5, 7.4.5 | `pop_front()` and `pop_back()` on an empty queue of int give x, and an int variable then holds x; Table 7-1 gives 0. | `ch7/test_queue_method_edges` |

### Illegal designs that it accepts

| Clause | Design | Tests |
| --- | --- | --- |
| 9.2.2.2 to 9.2.2.4 | A variable of always_ff, always_comb or always_latch written by another process, also through a function | `ch9/test_illegal_always_ff_other_writer`, `ch9/test_illegal_always_comb_other_writer`, `ch9/test_illegal_always_latch_other_writer`, `ch9/test_illegal_always_ff_written_via_function` |
| 6.5 | An input port declared as a variable and assigned by its module | `ch6/test_illegal_input_port_variable_assigned` |
| 25.5 | A modport that names a signal its interface does not declare | `ch25/test_illegal_modport_undeclared_name` |
| 8.10 | A static method that reads a non-static property | `ch8/test_illegal_static_method_uses_property` |
| 13.4 | fork-join in a function | `ch13/test_illegal_function_fork_join` |
| 6.20.5 | A parameter whose value uses a specify parameter | `ch6/test_illegal_parameter_from_specparam` |
| 33.4.1.2, 33.4.1.4 | Two default liblist clauses, and a cell clause with a library and a liblist (it skips config declarations) | `ch33/test_illegal_config_two_default_liblists`, `ch33/test_illegal_config_cell_library_liblist` |
| 6.7.1 | A net type keyword followed directly by `reg` (`wire reg`) | `ch6/test_illegal_net_type_then_reg` |
| 23.10.4.2 | A defparam whose hierarchical name resolves to another parameter once the generate blocks are elaborated | `ch23/test_illegal_defparam_early_resolution` |

It also rejects some illegal designs for another reason than their error:
it does not support ref ports or output arguments of functions, and it does
not parse the modport in an interface port of a module.

## Verilator 5.052

### Results

| Clause | What Verilator 5.052 does | Tests |
| --- | --- | --- |
| 20.10 | `$error` stops the run; it has to report the error and go on. The runner passes `+verilator+error+limit+1000000`, with which it goes on. | `ch20/test_error_does_not_end_run` (without that option) |
| 20.10, 9.2.3 | When `$fatal` ends the run, the final procedures do not run. | `ch20/test_fatal_runs_final_procedures` |
| 4.4.2.3, 21.2.2, 21.2.3 | At time 0, `$strobe` and `$monitor` show the values from before a write made after `#0` or by a nonblocking assignment; `$monitor` also misses changes of variables of an interface instance. | the 51 `gen/ch4/test_gen_sched_*_{strobe,monitor}_*` tests it does not match |
| 4.9.1, 4.4.2.3 | After a second `#0`, it still shows the old value of a continuous assignment. | `ch4/test_sched_contassign_zero_delay` |
| 9.2.2.2.2 | `always @*` runs at time 0 and wakes for a change of a variable that it only reads in a called function. | `ch9/test_always_comb_vs_always_star` |
| 9.4.2 | Event controls wake once at time 0 although nothing changed. | `ch9/test_event_nested_struct_member`, `ch12/test_foreach_index_shadows_outer` |
| 24.3.1 | A program's process sees the values from before the nonblocking updates of its time step (as Icarus Verilog 13.0). | `ch24/test_program_reactive_sees_nba` |
| 10.6.1, 4.9.2 | `assign` (procedural continuous) does not follow later changes of its right-hand side (as Icarus Verilog 13.0). | `ch4/test_sched_procedural_assign_deassign` |
| 11.5.2, 7.4.5 | An invalid address of a memory loses its upper bits, so another element is read and written. | `ch11/test_memory_invalid_address_2state` |
| 29.7 | A sequential UDP instance with a delay changes its output before the delay has passed. | `ch29/test_udp_initial_value_not_delayed` |
| 14.16 | A synchronous drive of a clocking output on a net, here a 0 against a weak 1 and on a wand net, does not reach the net. | `ch14/test_clocking_output_net_driver` |
| 33.4.1.1, 33.5.4 | With a config whose design statement names two cells, it also makes another uninstantiated module a top-level module. | `ch33/test_config_design_two_tops` |
| 30 | It ignores the module path delays of specify blocks without an error, so outputs change without them. | the tests of chapter 30 with `iverilog@13.0` in `:oracle:`, such as `ch30/test_specify_path_rise_fall` |
| 20.4.2 | `$printtimescale` prints the name of the design element without parentheses. | `ch20/test_printtimescale_other_module`, `ch3/test_timeunit_with_precision` |
| 21.2.3 | `$monitoron` prints nothing. | `ch21/test_monitor_end_of_step` |
| 21.3.7 | `$ferror` puts "Undefined error: 0" in its string when there is no error. | `ch21/test_file_fflush_ferror` |
| 21.3.5 | After `$fseek` from the end of a file, it reads EOF and reports the wrong position. | `ch21/test_file_seek_tell_rewind` |
| 35.5.6, H.7.4 | shortreal arguments and results of imported functions are wrong (0.0). | `ch35/test_dpi_shortreal` |
| 18.5.12 | A guard of a constraint does not keep a null handle from being dereferenced. | `ch18/test_constraint_guard_null` |
| 18.6.3 | When randomization fails, it still calls post_randomize and changes the variables passed to `std::randomize`. | `ch18/test_randomize_failure_keeps_values` |
| 8.26.5 | A cast from one interface class handle to another fails. | `ch8/test_interface_class_cast` |
| 19.5.7 | Values of a bin that do not survive the cast to the type of the coverpoint are not left out. | `ch19/test_cg_bins_value_resolution` |
| 19.5.1 | A fixed number of bins is ignored, one bin per value is made. | `ch19/test_cg_fixed_count_bins` |
| 19.5.3 | An enum coverpoint gets the wrong number of automatic bins. | `ch19/test_cg_enum_auto_bins` |
| 19.5.5, 19.5.6 | Ignored and illegal values stay in the bins and are counted. | `ch19/test_cg_ignore_bins`, `ch19/test_cg_illegal_bins_removed` |
| 19.7 | `at_least` is ignored: a bin is covered after one hit. | `ch19/test_cg_at_least` |
| 19.6, 19.11 | Coverage of a cross, and of a covergroup with weights, is the share of all bins, ignoring the weight option. | `ch19/test_cg_cross_coverage`, `ch19/test_cg_item_weighted_average` |
| 19.8 | Sampling goes on after `stop()`, and `get_coverage` sets both of its arguments to 0. | `ch19/test_cg_start_stop_counts` |
| 11.3.1 | It treats shortreal as real, so an expression with a shortreal operand and no real one is 64 bits wide instead of 32. | `ch11/test_real_operand_result_types` |
| 7.10.3, 13.5.2 | A reference to a queue element follows the position instead of the element: after the element is deleted, a write through the reference changes the element that took its place, and after an assignment to the whole queue it reads memory that is no longer the queue's. | `ch7/test_queue_reference_persistence` |

### Illegal designs that it accepts

| Clause | Design | Tests |
| --- | --- | --- |
| 9.2.2.2 to 9.2.2.4 | A variable of always_ff, always_comb or always_latch written by another process (it only warns, MULTIDRIVEN) | `ch9/test_illegal_always_ff_other_writer`, `ch9/test_illegal_always_comb_other_writer`, `ch9/test_illegal_always_latch_other_writer`, `ch9/test_illegal_always_ff_written_via_function` |
| 9.2.2.4 | always_ff with a delay or a second event control | `ch9/test_illegal_always_ff_delay`, `ch9/test_illegal_always_ff_two_event_controls` |
| 6.6.2 | A uwire net with two drivers | `ch6/test_illegal_uwire_two_drivers` |
| 6.5 | Continuous assignments to overlapping bits of a variable, and a variable driven by an output port and assigned elsewhere | `ch6/test_illegal_overlapping_continuous_assigns`, `ch6/test_illegal_output_port_variable_also_assigned` |
| 26.3 | A reference to a name that two wildcard imports provide | `ch26/test_illegal_wildcard_import_conflict` |
| 13.5.2 | A ref argument of a static task | `ch13/test_illegal_ref_in_static_task` |
| 13.4 | A function with an output argument called in a continuous assignment | `ch13/test_illegal_function_in_continuous_assign_output` |
| 30.4.1, 30.4.5 | A module path from an output port, to an input port, or in parallel between vectors of different widths | `ch30/test_illegal_specify_path_from_output`, `ch30/test_illegal_specify_path_to_input`, `ch30/test_illegal_specify_parallel_width_mismatch` |
| 33.4.1.2, 33.4.1.4 | Two default liblist clauses, and a cell clause with a library and a liblist | `ch33/test_illegal_config_two_default_liblists`, `ch33/test_illegal_config_cell_library_liblist` |
| 6.7.1 | A net type keyword followed directly by `reg` (`wire reg`) | `ch6/test_illegal_net_type_then_reg` |
| 6.22.2, 6.22.3 | An assignment between variables of two anonymous unpacked struct types from different declarations, which are not equivalent | `ch6/test_illegal_anonymous_struct_not_equivalent` |
| 23.10.4.2 | A defparam whose hierarchical name resolves to another parameter once the generate blocks are elaborated | `ch23/test_illegal_defparam_early_resolution` |
| 8.26.4 | A class that implements a type parameter, or a forward typedef of an interface class | `ch8/test_illegal_class_implements_type_parameter`, `ch8/test_illegal_implements_forward_typedef` |
| 8.26.6.2 | An interface class that inherits the same typedef name from two interface classes and does not declare it | `ch8/test_illegal_interface_class_typedef_conflict` |
