/*
:name: test_syntax_module_instantiation_forms
:description: module instantiations without parameter values, with an ordered, a named (one empty) and an empty parameter list, two instances in one statement, and ordered (one empty, one with an attribute), named, empty named, implicit named and wildcard port connections (IEEE 1800-2023 Section 23.3.2)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.2 23.3.2.1 23.3.2.2 23.3.2.3 23.3.2.4 23.10.2.1 23.10.2.2 A.4.1.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_syntax_module_instantiation_forms.expected
*/
// IEEE 1800-2023 A.4.1.1: a module instantiation is the module name, an
// optional # ( ) with ordered or named parameter values, or none, one or
// more instances separated by commas, and a semicolon. Each instance has
// parentheses with ordered connections, each optionally empty and with
// attribute instances, or named connections: .port(expression),
// .port(), .port, or .*, each with optional attribute instances.
// §23.10.2.1 and §23.10.2.2: ordered values go to the parameters in order;
// a named value goes to the parameter of that name, and .W() keeps the
// default. §23.3.2.1 to §23.3.2.4: an empty ordered connection and .port()
// leave the port unconnected, so the input is z and a + z is x; .port
// connects the signal of the same name; .* connects every port not listed
// to the signal of its name.
//
// adder adds a and b into y and gives W * 10 + K on info. c1 and c2 share
// #(8, 2); c3 lists b before a by name; in c5, a, y and info come from .*.
// Icarus Verilog 13.0 rejects the attribute instance in front of .* (syntax
// error); without it, it gives the expected output.

module adder #(parameter int W = 4, parameter int K = 1)
  (input logic [W-1:0] a, input logic [W-1:0] b, output logic [W-1:0] y, output int info);
  assign y = a + b;
  assign info = W * 10 + K;
endmodule

module test_syntax_module_instantiation_forms;
  logic [3:0] a = 4'd3, b = 4'd5;
  wire [3:0] y;
  int info;
  logic [3:0] y0, y3, y4;
  logic [7:0] y1, y2;
  int i0, i1, i2, i3;

  adder c0 ((* note = "first" *) a, , y0, i0);
  adder #(8, 2) c1 (8'd100, 8'd27, y1, i1), c2 (.a(8'd200), .b(8'd100), .y(y2), .info(i2));
  adder #(.K(3), .W()) c3 ((* note = "implicit" *) .b, .a(4'd6), .y(y3), .info(i3));
  adder c4 (.a(a), .b(), .y(y4), .info());
  adder #() c5 (.b(4'd2), (* note = "rest" *) .*);

  initial begin
    #1;
    $display("c0: y0=%b i0=%0d", y0, i0);
    $display("c1: y1=%0d i1=%0d", y1, i1);
    $display("c2: y2=%0d i2=%0d", y2, i2);
    $display("c3: y3=%0d i3=%0d", y3, i3);
    $display("c4: y4=%b", y4);
    $display("c5: y=%0d info=%0d", y, info);
  end
endmodule
