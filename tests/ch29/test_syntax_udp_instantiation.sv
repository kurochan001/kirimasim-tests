/*
:name: test_syntax_udp_instantiation
:description: UDP instances declared with and without a drive strength and two delays, several per declaration, named and unnamed, with the output terminal first and one or more input terminals (IEEE 1800-2023 Section 29.8)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.8 28.3 28.3.2 28.16 A.5.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_syntax_udp_instantiation.expected
*/
// IEEE 1800-2023 §29.8, A.5.4: a UDP instantiation is the UDP name, an
// optional drive strength, an optional delay of at most two values and one
// or more instances separated by commas; an instance has an optional name
// and lists the output terminal and then the input terminals in the order of
// the UDP's port list. As for gates (28.3.2, 28.16), the strength applies to
// the driven 0 and 1, and with two delays the first is the rise delay and
// the second the fall delay.
//
// u_and has two instances with (pull0, strong1) and #(2, 4); their outputs
// are printed with %v between the delays of a rise and a fall. u_buf has one
// input and two instances, the first unnamed. u_mux has three inputs and
// selects its second input when the first is 0, so a wrong terminal order
// changes its output.
//
// Icarus Verilog 13.0 does not accept a drive strength on a UDP instance,
// and Verilator 5.052 does not accept an unnamed UDP instance; both stop
// with a syntax error at the u_and line.

`timescale 1ns/1ns

primitive u_and (y, a, b);
  output y;
  input a, b;
  table
     1 1 : 1;
     0 ? : 0;
     ? 0 : 0;
  endtable
endprimitive

primitive u_buf (y, a);
  output y;
  input a;
  table
     0 : 0;
     1 : 1;
  endtable
endprimitive

primitive u_mux (y, s, a, b);
  output y;
  input s, a, b;
  table
  // s a b : y
     0 0 ? : 0;
     0 1 ? : 1;
     1 ? 0 : 0;
     1 ? 1 : 1;
  endtable
endprimitive

module test_syntax_udp_instantiation;
  reg a, b, c, s;
  wire y1, y2, b1, b2, m;

  u_and (pull0, strong1) #(2, 4) g1 (y1, a, b), (y2, a, c);
  u_buf (b1, a), g_b (b2, c);
  u_mux g_m (m, s, a, c);

  initial begin
    a = 1; b = 1; c = 0; s = 0;
    #5 $display("t=%0t y1=%v y2=%v buf=%b%b mux=%b", $time, y1, y2, b1, b2, m);
    b = 0; c = 1;     // y1 falls at 9, y2 rises at 7
    #1 $display("t=%0t y1=%v y2=%v", $time, y1, y2);
    #2 $display("t=%0t y1=%v y2=%v", $time, y1, y2);
    #2 $display("t=%0t y1=%v y2=%v buf=%b%b mux=%b", $time, y1, y2, b1, b2, m);
    s = 1; a = 0;
    #1 $display("t=%0t buf=%b%b mux=%b", $time, b1, b2, m);
  end
endmodule
