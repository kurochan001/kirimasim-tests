/*
:name: test_clocking_default_input_skew
:description: A default input skew applies to the clockvars that give none, and an explicit input skew overrides it (IEEE 1800-2023 Section 14.4)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.4 14.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_default_input_skew.expected
*/
// IEEE 1800-2023 §14.4: the default input skew of a clocking block applies to
// every input clockvar that does not give one, and a clockvar with its own
// skew uses that one instead. Here the default is #2 and b gives #0, which
// samples in the Observed region of the event. a and b change at 4.5 and at
// 13.5. At the edge at 5 the default samples a at 3 and gets 0, while b
// samples at the edge and gets 1. At the edge at 15 a samples at 13 and
// gets 1, while b samples at the edge and gets 0.

`timescale 1ns/1ns

module test_clocking_default_input_skew;
  logic clk = 0;
  logic a = 0;
  logic b = 0;

  always #5 clk = ~clk;   // posedges at 5, 15

  clocking cb @(posedge clk);
    default input #2;
    input a;
    input #0 b;
  endclocking

  initial begin
    #4.5 a = 1;
    b = 1;
    @(cb);
    $display("%0d: a=%b b=%b", $time, cb.a, cb.b);
    #9 a = 0;
    b = 0;
    @(cb);
    $display("%0d: a=%b b=%b", $time, cb.a, cb.b);
    $finish;
  end
endmodule
