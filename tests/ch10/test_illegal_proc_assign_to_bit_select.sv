/*
:name: test_illegal_proc_assign_to_bit_select
:description: The left-hand side of an assign procedural continuous assignment cannot be a bit-select of a variable (IEEE 1800-2023 Section 10.6.1)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.6.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the assign procedural continuous assignment writes the bit-select v[0]
:expected_stderr_regex: test_illegal_proc_assign_to_bit_select\.sv:28:
*/
// IEEE 1800-2023 §10.6.1: the left-hand side of an assign procedural
// continuous assignment shall be a singular variable reference or a
// concatenation of variables; it shall not be a bit-select or a part-select
// of a variable. The whole variable w is legal, v[0] is not.
// Icarus Verilog 13.0 stops there with a message that it cannot handle a
// procedural assign to a select (an unsupported construct, which does not
// count); the 5.052 release of Verilator accepts the design.

module test_illegal_proc_assign_to_bit_select;
  logic [3:0] v, w;
  logic a = 1'b1;

  initial begin
    assign w = {4{a}};
    assign v[0] = a;   // illegal: procedural assign to a bit-select
  end
endmodule
