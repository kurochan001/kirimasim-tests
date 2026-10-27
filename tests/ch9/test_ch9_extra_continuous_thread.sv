/*
:name: test_ch9_extra_continuous_thread
:description: each continuous assignment tracks its own sources independently and a chain of them settles before the next time step, as separate continuous threads do (IEEE 1800-2023 Section 9.5)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ch9_extra_continuous_thread.expected
*/
// IEEE 1800-2023 §9.5: each continuous assignment may be viewed as its own
// execution thread under the continuous scheduling rules. This test has
// three of them: wa follows a, wb follows ~b, and wsum follows wa & wb. They
// are independent threads, and the chain shows that an update reaches the
// end of the chain in the time step of the input change, not in a later one.
//
// At time 1 a is still 0 and b is still 1: wa=0, wb=0, wsum=0. At time 2 a
// has become 1, so wa=1 but wb and wsum are still 0. At time 3 b has become
// 0, so wb=1 and wsum=1. Each display is one time unit after the change that
// caused it, so a continuous assignment that had not run, or one that needed
// an extra time step to propagate, prints a different value.

`timescale 1ns/1ns

module test_ch9_extra_continuous_thread;
  logic a = 0;
  logic b = 1;
  wire wa, wb, wsum;

  assign wa = a;
  assign wb = ~b;
  assign wsum = wa & wb;

  initial begin
    #1 $display("t=%0t a=%b b=%b wa=%b wb=%b sum=%b", $time, a, b, wa, wb, wsum);
    a = 1;
    #1 $display("t=%0t a=%b b=%b wa=%b wb=%b sum=%b", $time, a, b, wa, wb, wsum);
    b = 0;
    #1 $display("t=%0t a=%b b=%b wa=%b wb=%b sum=%b", $time, a, b, wa, wb, wsum);
    $finish;
  end
endmodule
