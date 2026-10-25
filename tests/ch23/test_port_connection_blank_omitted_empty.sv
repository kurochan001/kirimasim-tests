/*
:name: test_port_connection_blank_omitted_empty
:description: Ordered connections take variables, nets, expressions or blanks, and named connections take an expression or nothing in their parentheses; a blank or omitted connection leaves an input without a default unconnected and gives a defaulted input its default, while an empty named connection leaves even a defaulted input unconnected (IEEE 1800-2023 Section 23.3.2.1)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.2.1 23.3.2.2 23.2.2.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_port_connection_blank_omitted_empty.expected
*/
// IEEE 1800-2023 §23.3.2.1: an ordered connection is a reference to a
// variable or a net, an expression (for an input), or a blank. A blank
// leaves the port unconnected, except that an input with a default value
// (§23.2.2.4) that has no argument in the list gets its default. §23.3.2.2:
// a named connection has parentheses, which hold an expression or nothing;
// .port() leaves the port unconnected even if it has a default, and a port
// left out of the named list is unconnected unless it has a default.
// The module has the outputs yd and yn, the input n without a default and
// the input d with the default 4'h7; yd and yn show d and n, and an
// unconnected input net is z. v is a variable (4'h3), w a net (4'h5).
//   p1 (yd1, yn1, w, v): a net and a variable: n = 5, d = 3;
//   p2 (yd2, yn2, ~w, v + 4'h1): expressions: n = a, d = 4;
//   p3 (yd3, yn3, , ): blanks: n unconnected (z), d its default 7;
//   p4 (yd4, yn4, w): d has no argument at the end of the list: d = 7;
//   p5 named, without n and d: n unconnected (z), d = 7;
//   p6 named with .n() and .d(): both unconnected (z), d despite its
//      default;
//   p7 named with .n(w + 4'h1) and .d(v ^ 4'hf): n = 6, d = c.
// Icarus Verilog 13.0 gives d its default for .d() in p6 (d=7). The
// two-state Verilator 5.052 shows 0 for the unconnected inputs and does not
// pass the connected values of d through (d=7 in p1).

module port_connection_blank_m(output logic [3:0] yd, output logic [3:0] yn,
                               input logic [3:0] n, input logic [3:0] d = 4'h7);
  assign yd = d;
  assign yn = n;
endmodule

module test_port_connection_blank_omitted_empty;
  logic [3:0] v = 4'h3;
  wire [3:0] w = 4'h5;
  logic [3:0] yd1, yn1, yd2, yn2, yd3, yn3, yd4, yn4, yd5, yn5, yd6, yn6, yd7, yn7;

  port_connection_blank_m p1(yd1, yn1, w, v);
  port_connection_blank_m p2(yd2, yn2, ~w, v + 4'h1);
  port_connection_blank_m p3(yd3, yn3, , );
  port_connection_blank_m p4(yd4, yn4, w);
  port_connection_blank_m p5(.yd(yd5), .yn(yn5));
  port_connection_blank_m p6(.yd(yd6), .yn(yn6), .n(), .d());
  port_connection_blank_m p7(.d(v ^ 4'hf), .n(w + 4'h1), .yn(yn7), .yd(yd7));

  initial begin
    #1;
    $display("p1: n=%h d=%h", yn1, yd1);
    $display("p2: n=%h d=%h", yn2, yd2);
    $display("p3: n=%h d=%h", yn3, yd3);
    $display("p4: n=%h d=%h", yn4, yd4);
    $display("p5: n=%h d=%h", yn5, yd5);
    $display("p6: n=%h d=%h", yn6, yd6);
    $display("p7: n=%h d=%h", yn7, yd7);
  end
endmodule
