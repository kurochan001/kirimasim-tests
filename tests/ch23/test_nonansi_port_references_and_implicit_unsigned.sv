/*
:name: test_nonansi_port_references_and_implicit_unsigned
:description: A non-ANSI port reference may be a simple or escaped identifier, a bit-select, a part-select or a concatenation, and a net connected to a port without a net declaration is unsigned unless the port or its net declaration is signed (IEEE 1800-2023 Section 23.2.2.1)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.2.2.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_nonansi_port_references_and_implicit_unsigned.expected
*/
// IEEE 1800-2023 §23.2.2.1: the port reference of a non-ANSI port may be a
// simple or escaped identifier, a bit-select, a part-select, or a
// concatenation of these. A net connected to a port that has no explicit
// net declaration is unsigned, unless the port is declared signed, and
// signedness on either the port or the net declaration makes both signed.
// Other implicit nets are unsigned. In nr_refs the six ports are the
// bit-select v[3], the part-select v[7:4], the concatenation {p, q}, the
// explicitly named port .n(x), the simple identifier a and the escaped
// identifier \esc; the task prints the bits each port carried. In
// nr_signed the port a has no net declaration and no signed keyword, b is
// declared signed on the port, and c is declared signed only on the net;
// the values 4'hf are 15 for the unsigned a and -1 for the signed b and c,
// so a < 0 is false and b < 0 and c < 0 are true. In nr_implicit the port
// connection creates the implicit net imp, whose value 1 is not less than 0
// only while it is unsigned, as the standard requires.

module nr_refs (v[3], v[7:4], {p, q}, .n(x), a, \esc );
  input [7:0] v;
  input [1:0] p, q;
  input [7:0] x;
  input [3:0] a;
  input [3:0] \esc ;
  task show;
    $display("refs v3=%b v74=%h pq=%b n=%h a=%h esc=%h", v[3], v[7:4], {p, q}, x, a, \esc );
  endtask
endmodule

module nr_signed (a, b, c);
  input [3:0] a;
  input signed [3:0] b;
  input [3:0] c;
  wire signed [3:0] c;
  task show;
    $display("signed a=%0d neg=%0d b=%0d neg=%0d c=%0d neg=%0d",
             a, a < 0, b, b < 0, c, c < 0);
  endtask
endmodule

module nr_sub (output o);
  assign o = 1'b1;
endmodule

module nr_implicit;
  nr_sub u_sub (.o(imp));
  task show;
    $display("implicit imp=%b neg=%0d", imp, imp < 0);
  endtask
endmodule

module test_nonansi_port_references_and_implicit_unsigned;
  logic [7:0] v = 8'b1010_0110;
  logic [1:0] p = 2'b10, q = 2'b01;
  logic [7:0] x = 8'h5a;
  logic [3:0] a = 4'hc;
  logic [3:0] esc = 4'h9;
  logic [3:0] sa = 4'hf, sb = 4'hf, sc = 4'hf;
  nr_refs u_refs (v[3], v[7:4], {p, q}, x, a, esc);
  nr_signed u_signed (sa, sb, sc);
  nr_implicit u_implicit ();

  initial begin
    #1 u_refs.show();
    u_signed.show();
    u_implicit.show();
  end
endmodule
