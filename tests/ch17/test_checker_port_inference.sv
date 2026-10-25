/*
:name: test_checker_port_inference
:description: A checker port without a direction takes the direction of the previous port, with input for the first, and a port without a type takes the type of the previous one, with the first untyped (IEEE 1800-2023 Section 17.2)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.2 17.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_port_inference.expected
*/
// IEEE 1800-2023 17.2: a checker port may be input or output. A port that
// omits the direction takes the direction of the previous port, and the first
// port defaults to input. The type of a port without a type is the type of the
// previous port by the sequence and property rules (16.8, 16.12), and a first
// port without a type is untyped, so the actual argument stands in for it with
// its own type. In the first checker only a, y and z name a direction and only
// a names a type, so b is an input logic [3:0] and z an output logic [3:0]:
// the four-bit and and or of 1010 and 1100 are 1000 and 1110. In the second
// checker the first port w has neither a direction nor a type, so it is an
// input untyped and the complement of the 8-bit actual 16 is 239 on 8 bits.

`timescale 1ns/1ns

checker inherit_pair(input logic [3:0] a, b, output logic [3:0] y, z);
  assign y = a & b;
  assign z = a | b;
endchecker : inherit_pair

checker first_untyped(w, output logic [7:0] y);
  assign y = ~w;
endchecker : first_untyped

module test_checker_port_inference;
  logic [3:0] a = 4'b1010, b = 4'b1100;
  logic [3:0] y_and, y_or;
  logic [7:0] w = 8'd16;
  logic [7:0] y_not;

  inherit_pair u_pair(.a(a), .b(b), .y(y_and), .z(y_or));
  first_untyped u_first(w, y_not);

  initial #1 $display("and=%b or=%b not=%0d", y_and, y_or, y_not);
endmodule
