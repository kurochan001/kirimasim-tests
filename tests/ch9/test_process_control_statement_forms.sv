/*
:name: test_process_control_statement_forms
:description: each form of the process control statements runs as its syntax says, wait with an expression and a statement or a null statement, wait fork, wait_order with each kind of action block, and disable of a task, a block and fork (IEEE 1800-2023 Section 9.6)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6 15.5.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_process_control_statement_forms.expected
*/
// IEEE 1800-2023 §9.6 gives the forms of the wait statement, wait (expression)
// followed by a statement or by a null statement, wait fork; and
// wait_order (...) followed by an action block (15.5.4), and of the disable
// statement, disable of a task, of a block and of fork. The test uses each:
// - wait (go) with a statement and with ; both resume when go becomes 1 at 2;
// - wait fork returns when the child that ends at 5 is done;
// - wait_order (e1, e2) with a statement and an else counts a pass when the
//   events come in order (7), the form with only else counts a failure when
//   e2 comes first (8), and the form with a null action block returns when
//   they come in order (11);
// - disable worker_t ends the task before it sets task_done, disable blk_b
//   ends the block before its delay of 10, and disable fork ends the child
//   that would set child_done to 3.
// Icarus Verilog 13.0 does not parse wait_order, and Verilator 5.052 reports it
// as unsupported; with the wait_order statements written as event controls,
// both give the lines of the other forms as expected.

`timescale 1ns/1ns

module test_process_control_statement_forms;
  bit go;
  event e1, e2;
  int n1, n2, passed, failed, task_done, blk_done, child_done;

  task worker_t();
    #10 task_done = 1;
  endtask

  initial begin
    fork
      wait (go) n1 = 5;
      begin
        wait (go);
        n2 = 7;
      end
      #2 go = 1;
    join
    $display("%0t: wait: n1=%0d n2=%0d", $time, n1, n2);

    fork
      #3 child_done = 1;
    join_none
    wait fork;
    $display("%0t: wait fork: child_done=%0d", $time, child_done);

    fork
      wait_order (e1, e2) passed = passed + 1; else failed = failed + 1;
      begin
        #1 -> e1;
        #1 -> e2;
      end
    join
    $display("%0t: in order: passed=%0d failed=%0d", $time, passed, failed);

    fork
      wait_order (e1, e2) else failed = failed + 1;
      begin
        #1 -> e2;
        #1 -> e1;
      end
    join
    $display("%0t: out of order: passed=%0d failed=%0d", $time, passed, failed);

    fork
      begin
        wait_order (e1, e2);
        passed = passed + 1;
      end
      begin
        #1 -> e1;
        #1 -> e2;
      end
    join
    $display("%0t: null action block: passed=%0d failed=%0d", $time, passed, failed);

    fork
      worker_t();
      #1 disable worker_t;
    join
    $display("%0t: disable task: task_done=%0d", $time, task_done);

    begin : blk_b
      fork
        #1 disable blk_b;
      join_none
      #10 blk_done = 1;
    end
    $display("%0t: disable block: blk_done=%0d", $time, blk_done);

    fork
      #1 child_done = 2;
      #5 child_done = 3;
    join_none
    #2 disable fork;
    #10 $display("%0t: disable fork: child_done=%0d", $time, child_done);
  end
endmodule
