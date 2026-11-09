/*
:name: test_illegal_clocking_clockvar_continuous_assign
:description: a clockvar can be written only by a synchronous drive, so a continuous assignment to an output clockvar is illegal (IEEE 1800-2023 Section 14.16)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the continuous assignment writes the output clockvar cb.y
:expected_stderr_regex: test_illegal_clocking_clockvar_continuous_assign\.sv:36:
*/
// IEEE 1800-2023 §14.16: it shall be an error to write to a clockvar other
// than with the synchronous drive syntax, so a continuous assignment to a
// clockvar is illegal. The synchronous drive cb.y <= 1'b0 and the continuous
// assignment to the variable w, which is not in a clocking block, are legal.
// The last continuous assignment writes the clockvar cb.y itself, not the
// variable y (test_illegal_clocking_output_variable_continuous_assign covers
// the variable).
// Icarus Verilog 13.0 does not support clocking blocks; the syntax errors it
// reports do not count.

`timescale 1ns/1ns
module test_illegal_clocking_clockvar_continuous_assign;
  logic clk = 0, a = 1;
  logic y, w;
  clocking cb @(posedge clk);
    output y;
  endclocking
  initial begin
    @(cb);
    cb.y <= 1'b0;
  end
  assign w = a;
  assign cb.y = a;   // illegal
endmodule
