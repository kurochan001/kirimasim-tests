/*
:name: test_illegal_clocking_drive_concatenation
:description: the target of a synchronous drive can be a whole output clockvar, a bit-select or a slice of it, but not a concatenation of clockvars (IEEE 1800-2023 Section 14.16)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the target of the synchronous drive is the concatenation {cb.a, cb.b}
:expected_stderr_regex: test_illegal_clocking_drive_concatenation\.sv:35:
*/
// IEEE 1800-2023 §14.16: the clockvar expression of a synchronous drive is
// the entire clockvar, a bit-select or a slice of it; a concatenation is not
// allowed. The drives of cb.a, cb.a[0] and cb.a[3:2] use the three legal
// forms. The last drive writes the concatenation {cb.a, cb.b}.
// Icarus Verilog 13.0 does not support clocking blocks; the syntax errors it
// reports do not count. The 5.052 release of Verilator accepts the design.

`timescale 1ns/1ns
module test_illegal_clocking_drive_concatenation;
  logic clk = 0;
  logic [3:0] a;
  logic b;
  default clocking cb @(posedge clk);
    output a, b;
  endclocking
  always #5 clk = ~clk;
  initial begin
    @(cb);
    cb.a <= 4'h1;
    cb.a[0] <= 1'b1;
    cb.a[3:2] <= 2'b10;
    {cb.a, cb.b} <= 5'h1f;   // illegal
  end
  initial #30 $finish;
endmodule
