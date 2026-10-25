/*
:name: test_port_expression_assignment_rules
:description: The signedness of a port does not cross the port, and an expression connected to a port is typed, sized and evaluated like the right-hand side of an assignment to the object on the other side, so it is extended by its own signedness to the width of the port (IEEE 1800-2023 Section 23.3.3.8)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.8 11.8.2 10.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_port_expression_assignment_rules.expected
*/
// IEEE 1800-2023 §23.3.3.8: the sign attribute does not cross a port; each
// side is signed only if its own declaration says so. An expression on a
// port is treated as an expression in an assignment: it is typed, sized and
// evaluated, and its value is assigned to the object on the other side by
// the rules of an assignment (§10.7, §11.8.2): the expression is evaluated
// at the width of the target, and an operand is sign-extended only if the
// expression is signed.
// a = 4'hf, b = 4'h1, s = -4'sd3 (4'b1101, signed), u = 4'b1101 (13).
//   u1: a + b into an unsigned 8-bit input: evaluated at 8 bits, 16 (in 4
//       bits it would be 0);
//   u2: s into an unsigned 8-bit input: sign-extended because s is signed,
//       8'hfd, read as unsigned inside: 253;
//   u3: s into a signed 8-bit input: 8'hfd, read as signed: -3;
//   u4: u into a signed 8-bit input: zero-extended because u is unsigned,
//       8'h0d, 13 (the signed port does not make it -3);
//   u5: a + b into a signed 8-bit input: 16;
//   u6: s + u into a signed 8-bit input: the expression is unsigned, so s
//       is zero-extended: 13 + 13 = 26 (sign-extending s would give 10);
//   o7, o8: a signed 4-bit output -3 drives an unsigned and a signed 8-bit
//       net: sign-extended to 8'hfd, which the nets show as 253 and -3.
// Icarus Verilog 13.0 evaluates the input expressions at their own width
// and zero-extends them (u1=0 u2=13 u3=13 u5=0 u6=10).

module port_expression_rules_u8(input logic [7:0] i, output int v);
  assign v = i;
endmodule

module port_expression_rules_s8(input logic signed [7:0] i, output int v);
  assign v = i;
endmodule

module port_expression_rules_out_s4(output logic signed [3:0] o);
  assign o = -4'sd3;
endmodule

module test_port_expression_assignment_rules;
  logic [3:0] a = 4'hf, b = 4'h1, u = 4'b1101;
  logic signed [3:0] s = -4'sd3;
  int v1, v2, v3, v4, v5, v6;
  wire [7:0] n7;
  wire signed [7:0] n8;

  port_expression_rules_u8 u1(.i(a + b), .v(v1));
  port_expression_rules_u8 u2(.i(s), .v(v2));
  port_expression_rules_s8 u3(.i(s), .v(v3));
  port_expression_rules_s8 u4(.i(u), .v(v4));
  port_expression_rules_s8 u5(.i(a + b), .v(v5));
  port_expression_rules_s8 u6(.i(s + u), .v(v6));
  port_expression_rules_out_s4 o7(.o(n7));
  port_expression_rules_out_s4 o8(.o(n8));

  initial begin
    #1;
    $display("u1=%0d u2=%0d u3=%0d u4=%0d u5=%0d u6=%0d", v1, v2, v3, v4, v5, v6);
    $display("o7=%0d o8=%0d", n7, n8);
  end
endmodule
