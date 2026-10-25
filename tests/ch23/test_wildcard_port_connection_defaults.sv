/*
:name: test_wildcard_port_connection_defaults
:description: A .* connection connects each port to the declaration of the same name, gives a defaulted input whose name is not declared its default, and can be mixed with named connections that give another expression or leave a port open (IEEE 1800-2023 Section 23.3.2.4)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.2.4 23.3.2.3 23.2.2.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_wildcard_port_connection_defaults.expected
*/
// IEEE 1800-2023 §23.3.2.4: .* connects every port of the instance as an
// implicit .name connection (§23.3.2.3) to the declaration of the same name
// and an equivalent type, except that an input with a default value
// (§23.2.2.4) gets its default when no such name exists in the instantiating
// scope. Named connections mixed with .* connect a port to another
// expression, or leave it unconnected with .port(), which also overrides the
// default.
// The leaf has the inputs a, e, and b and c with the defaults 6 and 9. The
// top module declares a (4'h1) and e (4'h2) but no b or c:
//   w1 (.*): a = 1, b = 6, c = 9 (defaults), e = 2;
//   w2 (.*, .c()): c unconnected (z) instead of its default;
//   w3 (.*, .a(4'hf)): a = f from the named connection;
//   wb.w4 (.*) in the module with_b, which declares a, b (4'h4) and e:
//      b = 4, not the default.
// Icarus Verilog 13.0 gives c its default for .c() in w2 (c=9), and the
// 5.052 release of Verilator stops with an error at the .* of an instance
// whose defaulted input c has no declaration of that name.

module wildcard_port_connection_defaults_leaf(input logic [3:0] a, input logic [3:0] b = 4'h6,
                                              input logic [3:0] c = 4'h9, input logic [3:0] e,
                                              output logic [3:0] y);
  assign y = a ^ b ^ c ^ e;
endmodule

module wildcard_port_connection_defaults_with_b;
  logic [3:0] a = 4'h1, b = 4'h4, e = 4'h2;
  logic [3:0] y;
  wildcard_port_connection_defaults_leaf w4(.*);
endmodule

module test_wildcard_port_connection_defaults;
  logic [3:0] a = 4'h1, e = 4'h2;
  logic [3:0] y1, y2, y3;

  wildcard_port_connection_defaults_leaf w1(.*, .y(y1));
  wildcard_port_connection_defaults_leaf w2(.*, .c(), .y(y2));
  wildcard_port_connection_defaults_leaf w3(.*, .a(4'hf), .y(y3));
  wildcard_port_connection_defaults_with_b wb();

  initial begin
    #1;
    $display("w1: a=%h b=%h c=%h e=%h", w1.a, w1.b, w1.c, w1.e);
    $display("w2: a=%h b=%h c=%h e=%h", w2.a, w2.b, w2.c, w2.e);
    $display("w3: a=%h b=%h c=%h e=%h", w3.a, w3.b, w3.c, w3.e);
    $display("wb.w4: a=%h b=%h c=%h e=%h", wb.w4.a, wb.w4.b, wb.w4.c, wb.w4.e);
  end
endmodule
