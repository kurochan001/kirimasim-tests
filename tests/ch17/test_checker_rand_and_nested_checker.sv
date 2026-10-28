/*
:name: test_checker_rand_and_nested_checker
:description: A checker body may hold a rand data declaration whose constant free variable keeps its initial value, and a nested checker declaration with an instance of it (IEEE 1800-2023 Sections 17.2 and 17.7)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.2 17.7 A.1.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_rand_and_nested_checker.expected
*/
// IEEE 1800-2023 17.2 and A.1.8: a checker_or_generate_item_declaration is
// an optional rand followed by a data declaration. 17.7: a rand declaration
// declares a free variable, and a free variable with the const qualifier
// that is initialized keeps its initial value forever. The body of cb_free
// declares rand const int rf = 3, so rf stays 3 and rf_out carries it
// through a continuous assignment. 17.7.1 forbids assigning a checker
// variable in an initial procedure, so rf_out is not assigned there.
// The same body declares the checker cb_inner and instantiates it; the
// instance computes fv = 1 + 1 = 2 from a constant actual, so the nested
// declaration and the instance exist and carry their value.
//
// Icarus Verilog 13.0 has no checkers. Verilator 5.052 does not support a
// rand variable in a checker or a checker inside a checker.

checker cb_free (
  input  logic clk,
  output int rf_out,
  output int fv
);
  rand const int rf = 3;

  checker cb_inner (input logic x, output int y);
    always_comb y = x + 1;
  endchecker

  cb_inner u_inner (.x(1'b1), .y(fv));

  assign rf_out = rf;
endchecker

module test_checker_rand_and_nested_checker;
  logic clk = 1'b0;
  int rf, fv;

  cb_free u_cb (.clk(clk), .rf_out(rf), .fv(fv));

  initial #1 $display("rf=%0d fv=%0d", rf, fv);
endmodule
