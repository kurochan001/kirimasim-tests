/*
:name: test_conditional_predicate_and_integral_branch
:description: A conditional predicate combines expression and matches-pattern terms with &&&, and an integral branch paired with an enum branch is converted and combined with integral conditional semantics under an ambiguous predicate (IEEE 1800-2023 Section 11.4.11)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_conditional_predicate_and_integral_branch.expected
*/
// IEEE 1800-2023 §11.4.11: the cond_predicate is a list of expression or
// matches-pattern terms joined by &&&. The first two conditionals use a
// matches pattern term and an expression term together. The last one pairs
// the integral branch 8'd5 with an enum branch, which is implicitly
// convertible to integral, so the enum is converted and the ambiguous
// predicate combines the two integral values bit by bit with Table 11-20.
//
// Neither release compiles the &&& predicate here, so the expectation
// follows 11.4.11.

typedef enum logic [7:0] {
  red = 8'd0,
  green = 8'd1,
  blue = 8'd2
} color_t;

module test_conditional_predicate_and_integral_branch;
  logic [3:0] x = 4'b1x01;
  logic [3:0] y;
  logic [7:0] r8;
  logic c;
  int r;

  initial begin
    y = ((x matches 4'b1?01) &&& (2 > 1)) ? 4'd7 : 4'd8;
    $display("match=%0d", y);
    y = ((x matches 4'b0?01) &&& (2 > 1)) ? 4'd7 : 4'd8;
    $display("nomatch=%0d", y);
    r = ((1 == 1) &&& (2 == 2)) ? 10 : 20;
    $display("andand=%0d", r);
    c = 1'bx;
    r8 = c ? 8'd5 : green;
    $display("conv=%b", r8);
  end
endmodule
