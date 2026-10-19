/*
:name: test_disable_fork_ends_loops_and_class_tasks
:description: disable fork ends child processes that wait inside while and for loops and one that runs a class task (IEEE 1800-2023 Section 9.6.3)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6.3 9.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_disable_fork_ends_loops_and_class_tasks.expected
*/
// IEEE 1800-2023 §9.6.3: disable fork ends all the active child processes of
// the process that runs it, and their descendants. A child that is waiting
// in a delay inside a while or a for loop ends there: the rest of the loop
// body does not run when the delay would have expired. A child that runs a
// task of a class object ends as well. Here join_any returns at 25, when the
// shortest branch ends, and none of the counters changes after that.

class watcher;
  int hits = 0;
  task watch();
    forever begin
      #2;
      hits++;
    end
  endtask
endclass

module test_disable_fork_ends_loops_and_class_tasks;
  int c_while = 0, c_for = 0;
  watcher w = new;

  initial begin
    fork
      while (c_while < 20) begin
        #30;
        c_while++;
      end
      for (int k = 0; k < 20; k++) begin
        #30;
        c_for++;
      end
      w.watch();
      #25;
    join_any
    disable fork;
    $display("t=%0d c_while=%0d c_for=%0d hits=%0d", $time, c_while, c_for, w.hits);
    #100;
    $display("t=%0d c_while=%0d c_for=%0d hits=%0d", $time, c_while, c_for, w.hits);
  end
endmodule
