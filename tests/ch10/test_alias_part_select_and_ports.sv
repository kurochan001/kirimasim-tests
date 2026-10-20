/*
:name: test_alias_part_select_and_ports
:description: alias joins part-selects and concatenations of nets, and two inout ports of an instance, so the nets connected to them share their values (IEEE 1800-2023 Section 10.11)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_alias_part_select_and_ports.expected
*/
// IEEE 1800-2023 §10.11: an alias statement makes the bits of its operands
// one net; an operand can be a part-select of a net or a concatenation of
// part-selects, matched bit for bit. lo is joined to bus[11:8] and the
// concatenation of the nibbles of rev in reverse order to fwd, so they read
// what bus and fwd are driven with. An alias of two inout ports inside a
// module joins the nets connected to them outside.

module port_joiner (inout wire [7:0] p, inout wire [7:0] q);
  alias p = q;
endmodule

module test_alias_part_select_and_ports;
  wire [15:0] bus;
  wire [3:0] lo;
  wire [15:0] fwd, rev;
  wire [7:0] x, y;

  assign bus = 16'h5a3c;
  alias bus[11:8] = lo;

  assign fwd = 16'h1234;
  alias {rev[3:0], rev[7:4], rev[11:8], rev[15:12]} = fwd;

  assign x = 8'h96;
  port_joiner u (x, y);

  initial #1 $display("lo=%h rev=%h y=%h", lo, rev, y);
endmodule
