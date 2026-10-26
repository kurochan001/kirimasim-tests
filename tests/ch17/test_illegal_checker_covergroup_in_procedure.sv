/*
:name: test_illegal_checker_covergroup_in_procedure
:description: A covergroup declaration and an instance outside the procedures are permitted in a checker, but an instance inside a checker procedure is illegal (IEEE 1800-2023 Section 17.6)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the always_ff procedure of the checker creates the covergroup instance bad, and 17.6 forbids covergroup declarations and instances in any procedural block of a checker
:expected_stderr_regex: test_illegal_checker_covergroup_in_procedure\.sv:(31|32|43):
*/
// IEEE 1800-2023 §17.6: one or more covergroup declarations or instances are
// permitted within a checker, but they shall not appear in any procedural
// block in the checker. The checker declares cg and creates the instance
// good outside its procedures, which is legal, and the always_ff procedure
// creates the instance bad, which is illegal. The rest of the checker and the
// module are legal. Icarus Verilog 13.0 has no checkers, and Verilator 5.052
// does not support a covergroup instance in a checker, so the expected
// rejection follows the clause alone.

`timescale 1ns/1ns

checker cb_cg (input logic clk, input logic a, input logic b, output bit o);
  covergroup cg @(posedge clk);
    cp_a: coverpoint a;
    cp_b: coverpoint b;
  endgroup : cg
  cg good = new();   // legal: an instance outside the checker procedures
  always_ff @(posedge clk) begin
    cg bad = new();  // illegal: an instance in a checker procedure
    o <= a;
  end
endchecker : cb_cg

module test_illegal_checker_covergroup_in_procedure;
  logic clk = 1'b0;
  logic a = 1'b1;
  logic b = 1'b0;
  bit o;

  cb_cg u_cb (.clk(clk), .a(a), .b(b), .o(o));

  always #5 clk = ~clk;

  initial #20 $finish;
endmodule
