/*
:name: test_illegal_generate_block_parameter_defparam
:description: A parameter declared in a generate block is treated as a localparam, so a defparam cannot change it, while a defparam can change a parameter of the module (IEEE 1800-2023 Section 27.2)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a defparam assigns the parameter K of the generate block g, which is a localparam
:expected_stderr_regex: test_illegal_generate_block_parameter_defparam\.sv:33:
*/
// IEEE 1800-2023 §27.2: parameters declared in generate blocks shall be
// treated as localparams (6.20.4), and a local parameter cannot be changed by
// a defparam statement (23.10). gbp_cell declares the parameter W in the
// module and the parameter K in its generate block. The defparam of u.W is
// legal; the defparam of u.g.K is not.
// The 5.052 release of Verilator stops with an internal error (V3Ast.h:1115)
// on the parameter of the generate block.

module gbp_cell;
  parameter int W = 1;
  if (1) begin : g
    parameter int K = 2;
  end
  initial #1 $display("%0d %0d", W, g.K);
endmodule

module test_illegal_generate_block_parameter_defparam;
  gbp_cell u ();
  defparam u.W = 3;
  defparam u.g.K = 4;   // illegal: K is a localparam
endmodule
