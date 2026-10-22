/*
:name: test_sched_subroutine_copy_out
:description: Output and inout arguments are copied out when a task returns, while a ref argument is written at once (IEEE 1800-2023 Section 4.9.7)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.9.7 13.3 13.5.1 13.5.2 13.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_subroutine_copy_out.expected
*/
// IEEE 1800-2023 §4.9.7, §13.5.1: arguments passed by value are copied in when
// the task is called and copied out when it returns. So while a task with a
// delay is still running, its output argument has not reached the caller's
// variable, and the value copied out of an inout argument at return replaces
// a write that another process made in the meantime. §13.5.2: a ref argument
// is the caller's variable itself, so a write to it is seen at once.

module test_sched_subroutine_copy_out;
  int x = 1;
  int y = 2;
  int z = 3;
  int seen_x, seen_y, seen_z;

  task automatic produce(output int o);
    o = 5;
    #2;
    o = 6;
  endtask

  task automatic bump(inout int v);
    v = v + 10;
    #2;
  endtask

  task automatic bump_ref(ref int v);
    v = v + 30;
    #2;
  endtask

  initial produce(x);
  initial bump(y);
  initial bump_ref(z);

  initial begin
    #1;
    seen_x = x;
    seen_z = z;
    y = 100;
    $display("t1 x=%0d z=%0d", seen_x, seen_z);
    #2;
    $display("t3 x=%0d y=%0d z=%0d", x, y, z);
  end
endmodule
