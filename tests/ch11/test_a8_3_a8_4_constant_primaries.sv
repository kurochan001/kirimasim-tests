/*
:name: test_a8_3_a8_4_constant_primaries
:description: A constant expression is built from a constant cast, a package-scoped parameter with a bit select and a part select, a package-scoped enum identifier, and operators with attribute instances before and after them, and each localparam takes the value the rules give (IEEE 1800-2023 Sections 6.20, 6.24.1 and 11.2.1, A.8.3 and A.8.4)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.2.1 6.24.1 6.20 A.8.3 A.8.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_a8_3_a8_4_constant_primaries.expected
*/
// IEEE 1800-2023 A.8.4: a constant primary is a literal, a package-scoped
// parameter identifier with a constant select, a scoped enum identifier, a
// parenthesized constant mintypmax expression, a constant cast, and others.
// A.8.3: a constant expression is a constant primary, a unary operator with
// attribute instances and a constant primary, two constant expressions with a
// binary operator and attribute instances, or a conditional one with
// attribute instances after the question mark. §6.24.1: a cast returns the
// value a variable of the casting type would hold after the assignment, so
// int'(3.9) rounds to 4.
//
// cxp::NIB is the four-bit parameter 1010 and cxp::RED is 1. The bit select
// NIB[1] is 1 and the part select NIB[3:2] is 2. The attribute instances in
// 1 + (* keep *) 2 and after the question mark of the conditional expression
// leave the values 3 and 1, and the unary minus in -(* keep *) 4 gives -4.
// Printed: 4, 1, 2, 1, 3, -4 and 1.

`timescale 1ns/1ns
package cxp;
  parameter logic [3:0] NIB = 4'b1010;
  typedef enum logic [1:0] {RED = 1, GREEN = 2} color_t;
endpackage

module test_a8_3_a8_4_constant_primaries;
  localparam int CASTED = int'(3.9);
  localparam int SELECTED = cxp::NIB[1];
  localparam logic [1:0] SLICE = cxp::NIB[3:2];
  localparam int ENUMED = cxp::RED;
  localparam int ATTR = 1 + (* keep = "true" *) 2;
  localparam int NEG = -(* keep = "true" *) 4;
  localparam int COND = (CASTED == 4) ? (* keep *) SELECTED : 0;

  initial $display("%0d %0d %0d %0d %0d %0d %0d",
                   CASTED, SELECTED, SLICE, ENUMED, ATTR, NEG, COND);
endmodule
