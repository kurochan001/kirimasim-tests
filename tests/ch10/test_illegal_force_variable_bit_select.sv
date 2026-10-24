/*
:name: test_illegal_force_variable_bit_select
:description: the left-hand side of a force can be a singular variable, a net, a constant bit-select or part-select of a vector net, or a concatenation of these, but not a bit-select of a variable (IEEE 1800-2023 Section 10.6.2)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the force statement writes v[1], a bit-select of the variable v
:expected_stderr_regex: test_illegal_force_variable_bit_select\.sv:34:
*/
// IEEE 1800-2023 §10.6.2: a force can be applied to a singular variable, a
// net, a constant bit-select or part-select of a vector net, or a
// concatenation of these, but not to a bit-select or part-select of a
// variable. The forces of v, w[1], w[3:2] and {w[0], u} are legal; the force
// of v[1] is not.
// Icarus Verilog 13.0 says it cannot force a bit-select also for the legal
// force of w[1] (an unsupported construct), so its error does not count;
// The design is accepted by Verilator 5.052.

module test_illegal_force_variable_bit_select;
  logic a = 1'b1;
  logic [3:0] v;
  logic u;
  wire [3:0] w = 4'h0;

  initial begin
    force v = 4'h5;
    force w[1] = a;
    force w[3:2] = 2'b10;
    force {w[0], u} = 2'b11;
    force v[1] = a;   // illegal: bit-select of a variable
    #1 $display("%h %h %b", v, w, u);
  end
endmodule
