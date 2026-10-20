# Clause 9: Processes

[All chapters](README.md). 108 tests. This page is written by `tools/suite_catalog.py` from the metadata of the tests; edit the tests, not this page.

| Test | What it checks | Clauses | Expected output recorded with | Notes |
| --- | --- | --- | --- | --- |
| [`test_initial_block`](../../tests/ch9/test_initial_block.sv) | Initial Block Tests | 9.2.1 | Icarus Verilog 13.0 |  |
| [`test_initial_block_2`](../../tests/ch9/test_initial_block_2.sv) | Initial block execution | 9.2.1 | Icarus Verilog 13.0 |  |
| [`test_initial_edge_cases`](../../tests/ch9/test_initial_edge_cases.sv) | Initial block edge cases | 9.2.1 | Icarus Verilog 13.0 |  |
| [`test_initial_final`](../../tests/ch9/test_initial_final.sv) | Initial and final procedures | 9.2.1 9.2.3 | Icarus Verilog 13.0 |  |
| [`test_always_at_signal_before_nonzero_delay`](../../tests/ch9/test_always_at_signal_before_nonzero_delay.sv) | An always procedure with @(signal) wakes on each change and updates its output before a later delay ends | 9.2.2 9.4.2 | Icarus Verilog 13.0 |  |
| [`test_always_body_event_control`](../../tests/ch9/test_always_body_event_control.sv) | An always procedure whose body starts with an event control counts every event | 9.2.2 9.4.2 15.5.1 | Icarus Verilog 13.0 |  |
| [`test_sequential_logic`](../../tests/ch9/test_sequential_logic.sv) | Counter and register in always procedures with event controls | 9.2.2.1 9.4.2 | Icarus Verilog 13.0 |  |
| [`test_always_blocks`](../../tests/ch9/test_always_blocks.sv) | Clock generation | 9.2.2.2 9.2.2.4 | Icarus Verilog 13.0 |  |
| [`test_always_comb`](../../tests/ch9/test_always_comb.sv) | always_comb | 9.2.2.2 | Icarus Verilog 13.0 |  |
| [`test_always_comb_2`](../../tests/ch9/test_always_comb_2.sv) | Always_comb Tests | 9.2.2.2 | Icarus Verilog 13.0 |  |
| [`test_always_comb_3`](../../tests/ch9/test_always_comb_3.sv) | always_comb (§9.2.2.2) | 9.2.2.2 11.6.1 | Icarus Verilog 13.0 |  |
| [`test_always_comb_4`](../../tests/ch9/test_always_comb_4.sv) | always_comb computing a sum and a difference that follow their inputs | 9.2.2.2 | Icarus Verilog 13.0 |  |
| [`test_always_comb_5`](../../tests/ch9/test_always_comb_5.sv) | always_comb infers its sensitivity from the expressions it reads | 9.2.2.2 | Icarus Verilog 13.0 |  |
| [`test_always_comb_cascade_propagation`](../../tests/ch9/test_always_comb_cascade_propagation.sv) | always_comb cascade chain propagation | 9.2.2.2 4.4.2.3 | Icarus Verilog 13.0 |  |
| [`test_always_comb_case_chain`](../../tests/ch9/test_always_comb_case_chain.sv) | always_comb with a case statement, and a chain of always_comb procedures | 9.2.2.2 12.5 | Icarus Verilog 13.0 |  |
| [`test_always_comb_chain`](../../tests/ch9/test_always_comb_chain.sv) | A chain of always_comb blocks settles after its input changes | 9.2.2.2 | Icarus Verilog 13.0 |  |
| [`test_always_comb_edge_cases`](../../tests/ch9/test_always_comb_edge_cases.sv) | Always_comb edge cases | 9.2.2.2 | Icarus Verilog 13.0 |  |
| [`test_always_comb_latch`](../../tests/ch9/test_always_comb_latch.sv) | Always_comb/latch/ff Tests | 9.2.2.2 9.2.2.3 9.2.2.4 | Icarus Verilog 13.0 | x/z |
| [`test_always_comb_latch_ff`](../../tests/ch9/test_always_comb_latch_ff.sv) | always_comb, always_latch and always_ff procedures | 9.2.2.2 9.2.2.3 9.2.2.4 | Icarus Verilog 13.0 |  |
| [`test_always_comb_perf`](../../tests/ch9/test_always_comb_perf.sv) | always_comb performance optimization test | 9.2.2.2 | Icarus Verilog 13.0 |  |
| [`test_always_comb_reads_writes`](../../tests/ch9/test_always_comb_reads_writes.sv) | always_comb with several reads and writes, including a conditional operator | 9.2.2.2 | Icarus Verilog 13.0 |  |
| [`test_always_comb_sens`](../../tests/ch9/test_always_comb_sens.sv) | always_comb sensitivity | 9.2.2.2 | Icarus Verilog 13.0 |  |
| [`test_barrel_shifter_edge_cases`](../../tests/ch9/test_barrel_shifter_edge_cases.sv) | Barrel shifter edge cases | 9.2.2.2 11.4.10 11.7 | Icarus Verilog 13.0 |  |
| [`test_bcd_edge_cases`](../../tests/ch9/test_bcd_edge_cases.sv) | BCD edge cases | 9.2.2.2 11.4.3 | Icarus Verilog 13.0 |  |
| [`test_decoder4_edge_cases`](../../tests/ch9/test_decoder4_edge_cases.sv) | 2-to-4 Decoder edge cases | 9.2.2.2 12.5 | Icarus Verilog 13.0 |  |
| [`test_decoder_edge_cases`](../../tests/ch9/test_decoder_edge_cases.sv) | Decoder edge cases | 9.2.2.2 11.5.1 | Icarus Verilog 13.0 |  |
| [`test_demux_edge_cases`](../../tests/ch9/test_demux_edge_cases.sv) | DEMUX edge cases | 9.2.2.2 12.5 | Icarus Verilog 13.0 |  |
| [`test_dependency_chain`](../../tests/ch9/test_dependency_chain.sv) | A chain of always_comb blocks updates in order after its input changes | 9.2.2.2 | Icarus Verilog 13.0 |  |
| [`test_encoder_edge_cases`](../../tests/ch9/test_encoder_edge_cases.sv) | Encoder edge cases | 9.2.2.2 12.4 | Icarus Verilog 13.0 |  |
| [`test_gray_edge_cases`](../../tests/ch9/test_gray_edge_cases.sv) | Binary to Gray code and back, and the single-bit change property | 9.2.2.2 11.4.10 | Icarus Verilog 13.0 |  |
| [`test_illegal_always_comb_other_writer`](../../tests/ch9/test_illegal_always_comb_other_writer.sv) | A variable assigned in an always_comb procedure cannot be written by another process | 9.2.2.2 | standard only | illegal design |
| [`test_mux4_edge_cases`](../../tests/ch9/test_mux4_edge_cases.sv) | 4-to-1 Multiplexer edge cases | 9.2.2.2 12.5 | Icarus Verilog 13.0 |  |
| [`test_sensitivity_edge_cases`](../../tests/ch9/test_sensitivity_edge_cases.sv) | Test: Sensitivity list edge cases | 9.2.2.2 9.2.2.4 9.4.2 | Icarus Verilog 13.0 |  |
| [`test_always_comb_reads_generate_scope_names`](../../tests/ch9/test_always_comb_reads_generate_scope_names.sv) | always_comb procedures in generate blocks rerun when variables they read through hierarchical names in other generate blocks change | 9.2.2.2.1 23.6 27.4 | Icarus Verilog 13.0 |  |
| [`test_always_comb_sensitivity_exceptions`](../../tests/ch9/test_always_comb_sensitivity_exceptions.sv) | The implicit sensitivity of always_comb leaves out variables it writes, the contents of called tasks and the expressions of assertion action blocks, but includes task arguments and the expression of an immediate assertion | 9.2.2.2.1 9.2.2.2.2 16.3 | standard only |  |
| [`test_always_comb_vs_always_star`](../../tests/ch9/test_always_comb_vs_always_star.sv) | always_comb runs at time zero and is sensitive to variables read in called functions, unlike always @* | 9.2.2.2.2 9.2.2.2.1 9.4.2.2 | Icarus Verilog 13.0 | x/z |
| [`test_always_latch`](../../tests/ch9/test_always_latch.sv) | Always_latch Tests | 9.2.2.3 | Icarus Verilog 13.0 |  |
| [`test_always_latch_2`](../../tests/ch9/test_always_latch_2.sv) | always_latch holds its outputs while the condition is false | 9.2.2.3 | Icarus Verilog 13.0 |  |
| [`test_always_latch_comb_in_interface`](../../tests/ch9/test_always_latch_comb_in_interface.sv) | always_latch and always_comb procedures in an interface run as they do in a module | 9.2.2.3 9.2.2.2 25.3 | Icarus Verilog 13.0 |  |
| [`test_always_latch_edge_cases`](../../tests/ch9/test_always_latch_edge_cases.sv) | Always_latch edge cases | 9.2.2.3 | Icarus Verilog 13.0 | x/z |
| [`test_illegal_always_latch_other_writer`](../../tests/ch9/test_illegal_always_latch_other_writer.sv) | A variable assigned in an always_latch procedure cannot be written by another process | 9.2.2.3 9.2.2.2 | standard only | illegal design |
| [`test_latch_edge_cases`](../../tests/ch9/test_latch_edge_cases.sv) | A D latch in always_latch: pass and hold | 9.2.2.3 | Icarus Verilog 13.0 |  |
| [`test_always_ff_async`](../../tests/ch9/test_always_ff_async.sv) | always_ff async reset | 9.2.2.4 4.7 | Icarus Verilog 13.0 |  |
| [`test_always_ff_corner`](../../tests/ch9/test_always_ff_corner.sv) | always_ff with asynchronous and synchronous reset, enable, a counter and a shift register | 9.2.2.4 4.7 | Icarus Verilog 13.0 | x/z |
| [`test_always_ff_edge_cases`](../../tests/ch9/test_always_ff_edge_cases.sv) | Always_ff edge cases | 9.2.2.4 | Icarus Verilog 13.0 |  |
| [`test_always_ff_simple`](../../tests/ch9/test_always_ff_simple.sv) | Always FF Simple Tests | 9.2.2.4 10.4.2 | Icarus Verilog 13.0 |  |
| [`test_illegal_always_ff_delay`](../../tests/ch9/test_illegal_always_ff_delay.sv) | An always_ff procedure cannot contain a delay control | 9.2.2.4 | Icarus Verilog 13.0 | illegal design |
| [`test_illegal_always_ff_other_writer`](../../tests/ch9/test_illegal_always_ff_other_writer.sv) | A variable assigned in an always_ff procedure cannot be written by another process | 9.2.2.4 9.2.2.2 | standard only | illegal design |
| [`test_illegal_always_ff_two_event_controls`](../../tests/ch9/test_illegal_always_ff_two_event_controls.sv) | An always_ff procedure cannot contain a second event control | 9.2.2.4 | Icarus Verilog 13.0 | illegal design |
| [`test_illegal_always_ff_written_via_function`](../../tests/ch9/test_illegal_always_ff_written_via_function.sv) | A variable assigned by a function that an always_ff procedure calls cannot be written by another process | 9.2.2.4 | standard only | illegal design |
| [`test_final`](../../tests/ch9/test_final.sv) | A final procedure runs after $finish; generate loop with continuous assignments | 9.2.3 27.4 | Icarus Verilog 13.0 |  |
| [`test_final_block_2`](../../tests/ch9/test_final_block_2.sv) | Final block execution | 9.2.3 | Icarus Verilog 13.0 |  |
| [`test_final_edge_cases`](../../tests/ch9/test_final_edge_cases.sv) | Final block edge cases | 9.2.3 | Icarus Verilog 13.0 |  |
| [`test_begin_end`](../../tests/ch9/test_begin_end.sv) | Sequential blocks | 9.3.1 | Icarus Verilog 13.0 |  |
| [`test_begin_end_2`](../../tests/ch9/test_begin_end_2.sv) | Test begin-end block | 9.3.1 9.3.5 | Icarus Verilog 13.0 |  |
| [`test_block_begin`](../../tests/ch9/test_block_begin.sv) | Begin Block Tests | 9.3.1 12.4 | Icarus Verilog 13.0 |  |
| [`test_block_scope_shadowing`](../../tests/ch9/test_block_scope_shadowing.sv) | Variables with the same name in different and nested begin-end blocks | 9.3.1 6.21 23.9 | Icarus Verilog 13.0 |  |
| [`test_scope_nba`](../../tests/ch9/test_scope_nba.sv) | Block-scoped variables with NBA (non-blocking) assignments | 9.3.1 10.4.2 23.9 6.21 | Icarus Verilog 13.0 |  |
| [`test_stmt_begin_end`](../../tests/ch9/test_stmt_begin_end.sv) | Test for begin-end blocks | 9.3.1 | Icarus Verilog 13.0 |  |
| [`test_fork_automatic_declaration_per_iteration`](../../tests/ch9/test_fork_automatic_declaration_per_iteration.sv) | An automatic variable declared in a fork block gets the loop's value of that iteration in each spawned process, in for, while and do-while loops | 9.3.2 6.21 | Verilator 5.052 |  |
| [`test_fork_child_zero_delay`](../../tests/ch9/test_fork_child_zero_delay.sv) | A fork branch that starts with #0 runs after the branches without a delay | 9.3.2 9.4.1 4.4.2.3 | Icarus Verilog 13.0 |  |
| [`test_fork_join_block_timing`](../../tests/ch9/test_fork_join_block_timing.sv) | Start and finish times of nested sequential and parallel blocks with join, join_any and join_none | 9.3.2 9.3.3 | Icarus Verilog 13.0 |  |
| [`test_join_none_children_start_after_parent_blocks`](../../tests/ch9/test_join_none_children_start_after_parent_blocks.sv) | Processes spawned by fork-join_none do not start until the parent blocks, so they see the value a static loop variable has by then | 9.3.2 | Icarus Verilog 13.0 |  |
| [`test_named_block_hier_write`](../../tests/ch9/test_named_block_hier_write.sv) | Hierarchical writes to variables of a named block, and a force on such a variable | 9.3.4 23.6 10.4.2 10.6.2 | Icarus Verilog 13.0 |  |
| [`test_named_block_scope_hierarchical`](../../tests/ch9/test_named_block_scope_hierarchical.sv) | Named block scope hierarchical access | 9.3.4 23.6 6.21 | Icarus Verilog 13.0 | x/z |
| [`test_assign_delay_edge_cases`](../../tests/ch9/test_assign_delay_edge_cases.sv) | Test: Assignment delay edge cases | 9.4.1 9.4.2 9.4.5 | Icarus Verilog 13.0 |  |
| [`test_timing_edge_cases`](../../tests/ch9/test_timing_edge_cases.sv) | Timing edge cases test | 9.4.1 9.4.5 9.4.2 | Icarus Verilog 13.0 |  |
| [`test_clocked_value_timing`](../../tests/ch9/test_clocked_value_timing.sv) | A variable updated by a clocked always procedure, read one time unit after each edge | 9.4.2 10.4.2 | Icarus Verilog 13.0 |  |
| [`test_edge_detection`](../../tests/ch9/test_edge_detection.sv) | Edge Detection Tests | 9.4.2 10.4.2 | Icarus Verilog 13.0 |  |
| [`test_edge_event_never_changes`](../../tests/ch9/test_edge_event_never_changes.sv) | @(edge v) resumes only on the transitions of Table 9-2, never for a variable that keeps its initial x | 9.4.2 | Icarus Verilog 13.0 | x/z |
| [`test_event_chain_propagation`](../../tests/ch9/test_event_chain_propagation.sv) | A chain of always @(signal) blocks settles in one time slot | 9.4.2 4.4.2.2 | Icarus Verilog 13.0 |  |
| [`test_event_control_on_expression`](../../tests/ch9/test_event_control_on_expression.sv) | An event control on an operator expression waits for a change of the expression's value, not for any change of its operands | 9.4.2 | Icarus Verilog 13.0 |  |
| [`test_event_control_posedge`](../../tests/ch9/test_event_control_posedge.sv) | Waiting for @(posedge clk) in an initial block | 9.4.2 | Icarus Verilog 13.0 |  |
| [`test_event_ctrl`](../../tests/ch9/test_event_ctrl.sv) | Event control | 9.4.2 | Icarus Verilog 13.0 |  |
| [`test_event_nested_struct_member`](../../tests/ch9/test_event_nested_struct_member.sv) | Event controls on members of nested packed structures wake only on a change of that member | 9.4.2 7.2.1 6.8 | Icarus Verilog 13.0 |  |
| [`test_multi_sensitivity_list`](../../tests/ch9/test_multi_sensitivity_list.sv) | Multi-signal sensitivity list test | 9.4.2 | Icarus Verilog 13.0 |  |
| [`test_sens_level`](../../tests/ch9/test_sens_level.sv) | Level sensitivity | 9.4.2 4.7 | Icarus Verilog 13.0 | x/z |
| [`test_sens_multi`](../../tests/ch9/test_sens_multi.sv) | Multiple sensitivity | 9.4.2 | Icarus Verilog 13.0 |  |
| [`test_value_history_clocked`](../../tests/ch9/test_value_history_clocked.sv) | Keeping the previous value of a variable across clock edges in one process | 9.4.2 | Icarus Verilog 13.0 |  |
| [`test_zero_width_pulse_wakes_edge_control`](../../tests/ch9/test_zero_width_pulse_wakes_edge_control.sv) | A variable that goes from 0 to 1 and back within one time step wakes both a posedge and a negedge event control | 9.4.2 4.3 | Icarus Verilog 13.0 |  |
| [`test_event_or_iff`](../../tests/ch9/test_event_or_iff.sv) | The or and comma event operators, and iff conditions that are checked only when the event occurs | 9.4.2.1 9.4.2.3 9.4.2 | Verilator 5.052 |  |
| [`test_always_star_for_loop_ieee`](../../tests/ch9/test_always_star_for_loop_ieee.sv) | Test: For loop variables must NOT be in sensitivity list | 9.4.2.2 | Icarus Verilog 13.0 |  |
| [`test_implicit_event`](../../tests/ch9/test_implicit_event.sv) | Test for @* (implicit event control) - IEEE 1800-2023 §9.4.2.2 | 9.4.2.2 | Icarus Verilog 13.0 |  |
| [`test_sequence_as_event_control`](../../tests/ch9/test_sequence_as_event_control.sv) | A named sequence used as an event control resumes the process at the end of a match | 9.4.2.4 16.8 | Verilator 5.052 |  |
| [`test_wait_on_array_size`](../../tests/ch9/test_wait_on_array_size.sv) | wait on the size() of a queue and of a dynamic array resumes when push_back or new[] changes it | 9.4.3 7.10.2.7 7.5.1 | Icarus Verilog 13.0 |  |
| [`test_intra_assignment_repeat_nonblocking`](../../tests/ch9/test_intra_assignment_repeat_nonblocking.sv) | A nonblocking assignment with an intra-assignment repeat event control takes the right-hand value when it executes and assigns it after the given number of events; the count is evaluated once, and a count of zero or less assigns without waiting | 9.4.5 10.4.2 | Icarus Verilog 13.0 |  |
| [`test_wait_fork_disable_fork`](../../tests/ch9/test_wait_fork_disable_fork.sv) | wait fork waits for immediate child processes only, and disable fork ends all descendants, also those of children that have finished | 9.6.1 9.6.3 9.3.2 | Verilator 5.052 |  |
| [`test_wait_fork_ignores_grandchildren`](../../tests/ch9/test_wait_fork_ignores_grandchildren.sv) | wait fork waits only for the immediate children of the process, not for the processes those children started | 9.6.1 9.3.2 | Icarus Verilog 13.0 |  |
| [`test_wait_fork_without_children`](../../tests/ch9/test_wait_fork_without_children.sv) | wait fork in a process without child processes continues at once, even while other processes have children running | 9.6.1 | Icarus Verilog 13.0 |  |
| [`test_disable_advanced`](../../tests/ch9/test_disable_advanced.sv) | disable statement advanced tests | 9.6.2 12.8 | Icarus Verilog 13.0 |  |
| [`test_disable_block`](../../tests/ch9/test_disable_block.sv) | Test for disable statement | 9.6.2 | Icarus Verilog 13.0 |  |
| [`test_disable_enclosing_task`](../../tests/ch9/test_disable_enclosing_task.sv) | A task that disables the task that called it ends both activations, and the caller of the outer task continues | 9.6.2 | Icarus Verilog 13.0 |  |
| [`test_disable_named_block_with_forks`](../../tests/ch9/test_disable_named_block_with_forks.sv) | disable ends a named block started by fork...join_none, and a block's disable ends the processes forked inside it | 9.6.2 9.3.2 | Icarus Verilog 13.0 |  |
| [`test_disable_stmt_2`](../../tests/ch9/test_disable_stmt_2.sv) | Disable Statement Tests | 9.6.2 | Icarus Verilog 13.0 |  |
| [`test_disable_stmt_3`](../../tests/ch9/test_disable_stmt_3.sv) | disable of named blocks, nested blocks and blocks containing loops | 9.6.2 | Icarus Verilog 13.0 |  |
| [`test_disable_stmt_edge_cases`](../../tests/ch9/test_disable_stmt_edge_cases.sv) | Test: Disable statement edge cases | 9.6.2 | Icarus Verilog 13.0 |  |
| [`test_disable_task_from_another_process`](../../tests/ch9/test_disable_task_from_another_process.sv) | disable with a task's name ends every running activation of the task, and each caller resumes after its call | 9.6.2 | Icarus Verilog 13.0 |  |
| [`test_disable_wait`](../../tests/ch9/test_disable_wait.sv) | Process Control | 9.6.2 9.4.3 | Icarus Verilog 13.0 |  |
| [`test_named_block_disable`](../../tests/ch9/test_named_block_disable.sv) | Test for named block disable | 9.6.2 | Icarus Verilog 13.0 |  |
| [`test_stmt_disable`](../../tests/ch9/test_stmt_disable.sv) | Test for disable statement | 9.6.2 | Icarus Verilog 13.0 |  |
| [`test_stmt_disable_2`](../../tests/ch9/test_stmt_disable_2.sv) | Disable statement test | 9.6.2 | Icarus Verilog 13.0 |  |
| [`test_task_disable`](../../tests/ch9/test_task_disable.sv) | Tests disabling named blocks within tasks | 9.6.2 13.3 | Verilator 5.052 |  |
| [`test_task_disable_2`](../../tests/ch9/test_task_disable_2.sv) | Disable in tasks test | 9.6.2 13.3 | Verilator 5.052 |  |
| [`test_disable_fork_ends_loops_and_class_tasks`](../../tests/ch9/test_disable_fork_ends_loops_and_class_tasks.sv) | disable fork ends child processes that wait inside while and for loops and one that runs a class task | 9.6.3 9.3.2 | Icarus Verilog 13.0 |  |
| [`test_process_await_from_fork_child`](../../tests/ch9/test_process_await_from_fork_child.sv) | await() called in a process started by fork returns when the awaited process ends, or at once if it has already ended | 9.7 9.3.2 | standard only |  |
| [`test_process_class_control`](../../tests/ch9/test_process_class_control.sv) | The process class: self, status and kill | 9.7 | Verilator 5.052 |  |
| [`test_process_kill_self`](../../tests/ch9/test_process_kill_self.sv) | A process that calls kill() on itself ends at once with the status KILLED, as one killed by another process does | 9.7 | standard only |  |
| [`test_process_suspend_resume_await`](../../tests/ch9/test_process_suspend_resume_await.sv) | The process class: await waits for another process to end, and a process suspended during a delay continues only after resume | 9.7 | standard only |  |
