/*
:name: test_task_output_copied_out_on_return
:description: An output argument passed by value is copied to the caller's variable when the task returns, as a blocking assignment that the next statement sees and that wakes the processes waiting for the variable (IEEE 1800-2023 Section 4.9.7)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.9.7 13.5.1 4.9.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_task_output_copied_out_on_return.expected
*/
// IEEE 1800-2023 §4.9.7: subroutine arguments are passed by value, copied in
// on the call and copied out on the return, and the copy-out behaves as a
// blocking assignment (§4.9.3). §13.5.1: an output argument is copied to the
// actual argument when the task completes.
// The task produce writes its output o at once and then waits #2. At time 1,
// in the middle of the call, the caller's variable q still has its old
// value 0. The task returns at 2: the statement after the call reads q = 5,
// as after a blocking assignment, and the process waiting for a change of q
// wakes at 2 and records 5.
// The release 5.052 of Verilator records the time 0 for that wake-up.

module test_task_output_copied_out_on_return;
  int q = 0, q_woken = -1, q_woken_time = -1;

  task automatic produce(output int o, input int v);
    o = v;
    #2;
  endtask

  always @(q) begin
    q_woken = q;
    q_woken_time = $time;
  end

  initial begin
    produce(q, 5);
    $display("after the call at %0d: q=%0d", $time, q);
    #1 $display("woken: q=%0d at %0d", q_woken, q_woken_time);
  end

  initial #1 $display("during the call at 1: q=%0d", q);
endmodule
