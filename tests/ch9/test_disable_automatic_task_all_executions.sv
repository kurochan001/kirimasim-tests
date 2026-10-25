/*
:name: test_disable_automatic_task_all_executions
:description: a task that disables itself ends every concurrent execution of it, unlike return, which ends only its own; disabling a block inside an automatic task ends that block in every execution (IEEE 1800-2023 Section 9.6.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_disable_automatic_task_all_executions.expected
*/
// IEEE 1800-2023 §9.6.2: a task disabling itself with a disable statement is
// not a shorthand for return: disable applies to every currently active
// execution of the task, and each caller resumes after its task call. This
// holds for automatic tasks, and for a named block inside an automatic task,
// for all concurrent executions. A return ends only the execution that runs
// it (12.8).
//
// Each task is called by two processes at time 0. Execution 1 waits #2 and
// then ends itself; execution 2 waits #10 and then marks itself done.
//   wd uses "disable wd": both callers resume at 2, neither execution is done
//   wr uses "return":     caller 1 resumes at 2, caller 2 at 10, done
// wb has a named block body (#10, then a mark) and a statement after it;
// a third process runs "disable wb.body" at time 3, so both executions skip
// the rest of body and reach the statement after it at time 3.
// All values are printed at time 30.

`timescale 1ns/1ns
module test_disable_automatic_task_all_executions;
  int done_d[1:2] = '{0, 0}, back_d[1:2] = '{-1, -1};
  int done_r[1:2] = '{0, 0}, back_r[1:2] = '{-1, -1};
  int body_end[1:2] = '{0, 0}, after_body[1:2] = '{-1, -1};

  task automatic wd(int id);
    if (id == 1) begin
      #2;
      disable wd;
    end
    #10;
    done_d[id] = 1;
  endtask

  task automatic wr(int id);
    if (id == 1) begin
      #2;
      return;
    end
    #10;
    done_r[id] = 1;
  endtask

  task automatic wb(int id);
    begin : body
      #10;
      body_end[id] = 1;
    end
    after_body[id] = $time;
  endtask

  initial begin wd(1); back_d[1] = $time; end
  initial begin wd(2); back_d[2] = $time; end
  initial begin wr(1); back_r[1] = $time; end
  initial begin wr(2); back_r[2] = $time; end
  initial wb(1);
  initial wb(2);
  initial #3 disable wb.body;

  initial begin
    #30;
    $display("disable: back=%0d,%0d done=%0d,%0d", back_d[1], back_d[2], done_d[1], done_d[2]);
    $display("return:  back=%0d,%0d done=%0d,%0d", back_r[1], back_r[2], done_r[1], done_r[2]);
    $display("block:   after=%0d,%0d end=%0d,%0d", after_body[1], after_body[2], body_end[1],
             body_end[2]);
  end
endmodule
