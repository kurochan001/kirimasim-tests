/*
:name: test_udp_identifier_and_combinational_table
:description: A user-defined primitive is named by an identifier, and the name is used to instantiate it; its state table gives a combinational output of 0 when an input is 0, of 1 when both inputs are 1 and x when an input is x (IEEE 1800-2023 Sections 29.3, 29.3.1 and 29.4)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.3 29.3.1 29.4 A.9.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_identifier_and_combinational_table.expected
*/
// IEEE 1800-2023 A.9.3: a UDP identifier is an identifier. §29.3 and
// §29.3.1: a primitive declaration names the UDP and its terminals, and an
// instance of the UDP is the name followed by the terminal connections.
// §29.4: the rows of a combinational UDP state table give the output for the
// input values; a row with a 0 input gives 0, the row for two 1 inputs gives
// 1, and an input x matches only the ? rows, which give 0 only when the other
// input is 0. Here a is x and b is 1, so the second row matches and the output
// is 0 when a row matches; when no row matches, as for a = x with b = 1, the
// output is x. With both inputs 1 the output is 1 and with a 0 input it is 0.
//
// Icarus Verilog 13.0 produces this output. Verilator 5.052 gives 0 instead
// of x when no row matches, so :oracle: does not list it.

`timescale 1ns/1ns

primitive udp_and (out, a, b);
  output out;
  input a, b;
  table
    0 ? : 0;
    ? 0 : 0;
    1 1 : 1;
  endtable
endprimitive

module test_udp_identifier_and_combinational_table;
  logic a = 1, b = 1;
  logic xa = 1'bx;
  wire w1, w2, w3;

  udp_and u1 (w1, a, b);
  udp_and u2 (w2, xa, b);
  udp_and u3 (w3, a, 1'b0);

  initial begin
    #1 $display("udp %b %b %b", w1, w2, w3);
    a = 0;
    #1 $display("udp %b %b %b", w1, w2, w3);
  end
endmodule
