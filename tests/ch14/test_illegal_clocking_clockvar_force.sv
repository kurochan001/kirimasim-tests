/*
:name: test_illegal_clocking_clockvar_force
:description: a clockvar can be written only by a synchronous drive, so a force statement on an output clockvar is illegal (IEEE 1800-2023 Section 14.16)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.16 10.6.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the force statement writes the output clockvar cb.y
:expected_stderr_regex: test_illegal_clocking_clockvar_force\.sv:36:
*/
// IEEE 1800-2023 §14.16: it shall be an error to write to a clockvar other
// than with the synchronous drive syntax, so a procedural continuous
// assignment (assign or force) to a clockvar is illegal. §10.6.2: force is
// the second form of procedural continuous assignment. The synchronous drive
// cb.y <= 1'b0 and the force statement for the variable w, which is not in a
// clocking block, are legal. The last force statement writes the clockvar
// cb.y itself, not the variable y (test_illegal_clocking_output_variable_force
// covers the variable).
// Icarus Verilog 13.0 does not support clocking blocks; the syntax errors it
// reports do not count.

`timescale 1ns/1ns
module test_illegal_clocking_clockvar_force;
  logic clk = 0, a = 1;
  logic y, w;
  clocking cb @(posedge clk);
    output y;
  endclocking
  initial begin
    force w = a;
    @(cb);
    cb.y <= 1'b0;
    force cb.y = a;   // illegal
  end
endmodule
