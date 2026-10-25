/*
:name: test_vpi_ansi_port_inheritance
:description: In ANSI port lists the first port defaults to inout and to the logic data type, a later port that omits direction, port kind and data type inherits all three but not unpacked dimensions, and a later port that gives only some of them inherits only the direction, as VPI shows by the direction, object kind and width of each port (IEEE 1800-2023 Section 23.2.2.3)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.2.2.3 37.14 37.16 37.17
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:vpi_c: @test_vpi_ansi_port_inheritance.c
:expected_stdout: @test_vpi_ansi_port_inheritance.expected
*/
// IEEE 1800-2023 §23.2.2.3: in an ANSI port list, the first port without a
// direction is inout, and without a data type it is logic. A later port
// that omits its direction, port kind and data type inherits all three from
// the port before it; a later port that gives any of them inherits only an
// omitted direction, gets an omitted port kind by the rules of the first
// port (an input or inout is a net, an output is a net with no or an
// implicit data type and a variable with an explicit one) and an omitted
// data type defaults to logic. Unpacked dimensions are never inherited.
// The expected kinds:
//   u1(wire a, b): a inout logic net; b inherits all, inout logic net;
//   u2([5:0] x, y, input z): x inout net of 6 bits (an implicit data type
//      makes the list ANSI); y the same; z input, logic, 1 bit;
//   u3(logic s, output t): s inout logic net; t output logic net, 1 bit;
//   u4(input var logic [3:0] p, q, wire r, logic g [1:0], h, output var
//      integer e, signed [2:0] f, logic k): q inherits all of p (input
//      variable of 4 bits); r input net of 1 bit; g input net array of 2;
//      h inherits the input direction, net kind and logic type of g but not
//      its unpacked dimension; e output integer variable; f output signed
//      net of 3 bits; k output logic variable of 1 bit; v (var [1:0]) output
//      variable of 2 bits, as var makes an implicit data type a variable;
//   u5(a5, b5): the first port has no direction, port kind or data type,
//      so the list is non-ANSI and the body declares a5 an input and b5 an
//      output of 3 bits.
// The VPI application prints the direction of each port (37.14) and the
// kind, width and signedness of its object (37.16, 37.17); the module prints
// three undriven inout ports, which as logic nets are z. Verilator 5.052
// rejects the first port without a direction, so this expected output is
// confirmed by Icarus Verilog 13.0 alone.

module vpi_ansi_port_inheritance_m1(wire a, b);
endmodule

module vpi_ansi_port_inheritance_m2([5:0] x, y, input z);
endmodule

module vpi_ansi_port_inheritance_m3(logic s, output t);
endmodule

module vpi_ansi_port_inheritance_m4(input var logic [3:0] p, q, wire r, logic g [1:0], h,
                                    output var integer e, signed [2:0] f, logic k,
                                    var [1:0] v);
endmodule

module vpi_ansi_port_inheritance_m5(a5, b5);
  input a5;
  output [2:0] b5;
endmodule

module test_vpi_ansi_port_inheritance;
  wire a, b, z, s, t, r, h, k, a5;
  wire [1:0] v;
  wire [2:0] b5;
  wire [5:0] x, y;
  wire [3:0] p, q;
  logic g [1:0];
  integer e;
  wire signed [2:0] f;

  vpi_ansi_port_inheritance_m1 u1(a, b);
  vpi_ansi_port_inheritance_m2 u2(x, y, z);
  vpi_ansi_port_inheritance_m3 u3(s, t);
  vpi_ansi_port_inheritance_m4 u4(p, q, r, g, h, e, f, k, v);
  vpi_ansi_port_inheritance_m5 u5(a5, b5);

  initial begin
    #1 $vt_ports;
    $display("u1.a=%b u2.x=%b u3.s=%b", u1.a, u2.x, u3.s);
  end
endmodule
