/*
:name: test_clocking_default_output_skew
:description: A default output skew applies to the clockvars that give none, and an explicit output skew overrides it (IEEE 1800-2023 Section 14.4)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.4 14.16 14.16.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_default_output_skew.expected
*/
// IEEE 1800-2023 §14.4: the default output skew of a clocking block applies to
// every output clockvar that does not give one, and a clockvar with its own
// skew uses that one instead. Here the default is #2 and b gives #0. §14.16:
// each drive matures in the Re-NBA region of the time step its skew selects.
// The drives at the edge at 5 change b at 5 and a at 7; the drives at the
// edge at 15 change b at 15 and a at 17.

`timescale 1ns/1ns

module test_clocking_default_output_skew;
  logic clk = 0;
  logic a = 0;
  logic b = 0;

  always #5 clk = ~clk;   // posedges at 5, 15

  clocking cb @(posedge clk);
    default output #2;
    output a;
    output #0 b;
  endclocking

  initial begin
    @(cb);
    cb.a <= 1;
    cb.b <= 1;
    #1 $display("%0d: a=%b b=%b", $time, a, b);
    #2 $display("%0d: a=%b b=%b", $time, a, b);
    @(cb);
    cb.a <= 0;
    cb.b <= 0;
    #1 $display("%0d: a=%b b=%b", $time, a, b);
    #2 $display("%0d: a=%b b=%b", $time, a, b);
    $finish;
  end
endmodule
