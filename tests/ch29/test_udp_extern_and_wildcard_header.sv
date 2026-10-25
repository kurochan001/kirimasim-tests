/*
:name: test_udp_extern_and_wildcard_header
:description: A UDP declared with extern and a non-ANSI or ANSI header is defined with the wildcard header ( .* ), which takes its ports from the extern declaration and allows port declarations to be omitted (IEEE 1800-2023 Section 29.3)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.3 29.2 A.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_udp_extern_and_wildcard_header.expected
*/
// IEEE 1800-2023 §29.3 with A.5.1: a UDP may be declared with extern and
// either the non-ANSI header, which lists the port names, or the ANSI header,
// which lists the port declarations. The definition then uses primitive name
// ( .* ) and has the ports of that extern declaration (23.5 gives the same
// form for modules); with a non-ANSI extern header the definition still has
// the port declarations, and with an ANSI extern header it has none. The
// definition may carry attributes on the wildcard header and may end with a
// label.
//
// u_and and u_xor are declared with a non-ANSI extern header and defined with
// the wildcard header and their port directions; u_mux is declared with an
// ANSI extern header and defined with the wildcard header alone. The module
// drives every input pair and prints the three outputs. A definition that
// took another port order would show in the mux output for s=0.
// Icarus Verilog 13.0 and Verilator 5.052 reject extern primitive
// declarations, so the expected output follows the standard.

extern primitive u_and(y, a, b);
(* form = "wildcard" *) primitive u_and(.*);
  output y;
  input a, b;
  table
  // a b : y
     1 1 : 1;
     0 ? : 0;
     ? 0 : 0;
  endtable
endprimitive : u_and

extern primitive u_xor(y, a, b);
primitive u_xor(.*);
  output y;
  input a, b;
  table
  // a b : y
     0 0 : 0;
     0 1 : 1;
     1 0 : 1;
     1 1 : 0;
  endtable
endprimitive

extern primitive u_mux(output y, input s, input a, input b);
primitive u_mux(.*);
  table
  // s a b : y
     0 0 ? : 0;
     0 1 ? : 1;
     1 ? 0 : 0;
     1 ? 1 : 1;
  endtable
endprimitive : u_mux

module test_udp_extern_and_wildcard_header;
  reg a, b, s;
  wire y_and, y_xor, y_mux;

  u_and g1(y_and, a, b);
  u_xor g2(y_xor, a, b);
  u_mux g3(y_mux, s, a, b);

  initial begin
    for (int i = 0; i < 4; i++) begin
      {a, b} = i[1:0];
      #1 $display("a=%b b=%b: and=%b xor=%b", a, b, y_and, y_xor);
    end
    s = 0; a = 1; b = 0;
    #1 $display("s=%b a=%b b=%b: mux=%b", s, a, b, y_mux);
    s = 1; b = 1;
    #1 $display("s=%b a=%b b=%b: mux=%b", s, a, b, y_mux);
  end
endmodule
