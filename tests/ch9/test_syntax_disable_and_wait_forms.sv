/*
:name: test_syntax_disable_and_wait_forms
:description: disable of a task, of a named block and of a fork, and wait (expression) with a statement or null statement and wait fork, stop exactly the processes that A.6.5 and 9.6 name (IEEE 1800-2023 Sections 9.6.1 to 9.6.3, A.6.5)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6 9.6.1 9.6.2 9.6.3 A.6.5 A.6.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_disable_and_wait_forms.expected
*/
// IEEE 1800-2023 A.6.5: a wait statement is "wait ( expression )
// statement_or_null", "wait fork ;" or wait_order; a disable statement is
// "disable hierarchical_task_identifier ;", "disable
// hierarchical_block_identifier ;" or "disable fork ;". §9.6.1: wait fork
// blocks until every process started by the current process has finished.
// §9.6.2: disable ends the named task or block and its child processes, and
// the statement after the disabled block runs. §9.6.3: disable fork ends the
// current process's child processes.
//
// n counts the completed statements. The task sets n to 1 and disables
// itself, so its next statement does not run. The inner block adds 10 and
// disables itself, so its last statement does not run and the statement after
// the block does. The two waits wake when n becomes 12 and 13. The wait fork
// returns after the branch at 3 time units, when n is 16, not after the
// branch at 1. The disable fork at 1 time unit after the last fork kills its
// branch, so the branch at 5 never adds 100 and the print is at 7.

`timescale 1ns/1ns

module test_syntax_disable_and_wait_forms;
  int n = 0;

  task automatic stop_me;
    n = n + 1;
    disable stop_me;
    n = n + 100;
  endtask

  initial begin
    stop_me();
    $display("task: n=%0d", n);

    begin : outer_block
      begin : inner_block
        n = n + 10;
        disable inner_block;
        n = n + 100;
      end
      $display("block: n=%0d", n);
    end : outer_block

    fork
      #2 n = n + 1;
    join_none
    wait (n == 12);
    $display("wait null: n=%0d", n);

    fork
      #1 n = n + 1;
    join_none
    wait (n == 13) $display("wait statement: n=%0d", n);

    fork
      #3 n = n + 1;
      #1 n = n + 2;
    join_none
    wait fork;
    $display("wait fork: n=%0d", n);

    fork
      #5 n = n + 100;
    join_none
    #1 disable fork;
    $display("disable fork: n=%0d at %0t", n, $time);

    #10 $finish;
  end
endmodule
