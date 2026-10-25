/*
:name: test_illegal_proc_assign_to_part_select
:description: The left-hand side of an assign procedural continuous assignment cannot be a part-select of a variable (IEEE 1800-2023 Section 10.6.1)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.6.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the assign procedural continuous assignment writes the part-select v[3:2]
:expected_stderr_regex: test_illegal_proc_assign_to_part_select\.sv:28:
*/
// IEEE 1800-2023 §10.6.1: the left-hand side of an assign procedural
// continuous assignment shall be a singular variable reference or a
// concatenation of variables; it shall not be a bit-select or a part-select
// of a variable. The concatenation {w, x} is legal, v[3:2] is not.
// Icarus Verilog 13.0 stops there with a message that it cannot handle a
// procedural assign to a select (an unsupported construct, which does not
// count); the 5.052 release of Verilator accepts the design.

module test_illegal_proc_assign_to_part_select;
  logic [3:0] v, w;
  logic [1:0] x, a = 2'b10;

  initial begin
    assign {w, x} = {4'h0, a};
    assign v[3:2] = a;   // illegal: procedural assign to a part-select
  end
endmodule
