/*
:name: test_assertion_clock_sampled_value
:description: A variable that is both the clock of an assertion and part of its expression is used with its current value in the clock and with its sampled value in the expression (IEEE 1800-2023 Section 16.5.2)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.5.2 16.5.1 16.14.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assertion_clock_sampled_value.expected
*/
// IEEE 1800-2023 §16.5.2: when a variable appears in the clocking event of an
// assertion and also in its expression, the clock uses its current value and
// the expression its sampled value (16.5.1), so the two can differ. At each
// rising edge of c, the sampled value of c is the 0 from before the edge, so
// a_high fails and a_low passes at every edge. The action blocks count them.

`timescale 1ns/1ns

module test_assertion_clock_sampled_value;
  logic c = 0;
  int high_fail = 0, low_pass = 0;

  always #5 c = ~c;

  a_high: assert property (@(posedge c) c) else high_fail++;
  a_low: assert property (@(posedge c) !c) low_pass++;

  initial begin
    #42;
    $display("edges at 5..35: a_high failed %0d times, a_low passed %0d times", high_fail,
             low_pass);
    $finish;
  end
endmodule
