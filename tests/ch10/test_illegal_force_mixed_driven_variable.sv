/*
:name: test_illegal_force_mixed_driven_variable
:description: a force or release cannot be applied to a variable that is assigned by a mixture of continuous and procedural assignments (IEEE 1800-2023 Section 10.6.2)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable mix, whose bit 0 is continuously assigned and whose bit 1 is procedurally assigned, is the target of a force
:expected_stderr_regex: test_illegal_force_mixed_driven_variable\.sv:35:
*/
// IEEE 1800-2023 §10.6.2: a force or release statement shall not be applied to
// a variable that is assigned by a mixture of continuous and procedural
// assignments. The bits of a packed variable are independent elements (6.5),
// so mix can have bit 0 driven by a continuous assignment and bit 1 written
// procedurally. The forces of c, driven only by a continuous assignment, and
// of p, written only procedurally, are legal; the force of mix is not.
// Icarus Verilog 13.0 and Verilator 5.052 accept the design.

module test_illegal_force_mixed_driven_variable;
  logic a = 1'b1;
  logic [1:0] c, p, mix;

  assign c = {a, a};
  assign mix[0] = a;

  initial begin
    p = 2'b01;
    mix[1] = 1'b0;
    #1;
    force c = 2'b00;
    force p = 2'b10;
    force mix = 2'b11;   // illegal: mix is driven both continuously and procedurally
    #1 $display("%b %b", c, p);
  end
endmodule
