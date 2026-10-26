/*
:name: test_illegal_checker_covergroup_reference
:description: A checker covergroup may reference a formal or a checker variable, but a formal referenced by the covergroup shall not have a const actual argument (IEEE 1800-2023 Section 17.6)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance bad passes const'(v) to the formal a, which the covergroup of the checker references in cp_a
:expected_stderr_regex: test_illegal_checker_covergroup_reference\.sv:(31|32|46):
*/
// IEEE 1800-2023 §17.6: a covergroup in a checker may reference any variable
// visible in its scope, including checker formal arguments and checker
// variables, but it is an error if a formal argument referenced by a
// covergroup has a const actual argument. The covergroup cg references the
// formal a and the checker variable seen. The instance ok passes the variable
// v to a and is legal; the instance bad passes const'(v) to a, so its
// covergroup reference is the error. The checker uses a nowhere else, so the
// design has no other error. Icarus Verilog 13.0 has no checkers and the
// 5.052 release does not support a covergroup instance in a checker, so the
// expected rejection follows the clause alone.

`timescale 1ns/1ns

checker cb_cgref (input logic clk, input logic a, input logic b,
                  output bit o);
  bit seen = 1'b0;

  covergroup cg @(posedge clk);
    cp_a: coverpoint a;
    cp_seen: coverpoint seen;
  endgroup : cg
  cg inst = new();

  always_comb o = b;
endchecker : cb_cgref

module test_illegal_checker_covergroup_reference;
  logic clk = 1'b0;
  logic v = 1'b1;
  bit o_ok, o_bad;

  cb_cgref ok (.clk(clk), .a(v), .b(v), .o(o_ok));
  cb_cgref bad (.clk(clk), .a(const'(v)), .b(v), .o(o_bad));

  always #5 clk = ~clk;

  initial #20 $finish;
endmodule
