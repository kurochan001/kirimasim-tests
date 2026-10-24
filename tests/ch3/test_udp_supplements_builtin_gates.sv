/*
:name: test_udp_supplements_builtin_gates
:description: A combinational, a level-sensitive and an edge-sensitive user-defined primitive, each between primitive and endprimitive, work in one netlist with built-in and and not gates and give the outputs of their tables (IEEE 1800-2023 Section 3.7)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.7 29.3 29.4 29.5 29.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_supplements_builtin_gates.expected
*/
// IEEE 1800-2023 §3.7: user-defined primitives (UDPs), each enclosed between
// primitive and endprimitive, supplement the built-in primitives. §29.3 to
// §29.6: a UDP gives the output of the table row that matches its inputs,
// where ? matches 0, 1 and x and - keeps the current state.
// - ud_mux is combinational: s = 0 selects a, s = 1 selects b, and with
//   s = x the rows with ? give 1 when a and b are both 1. Its input a is the
//   output of a built-in and gate.
// - ud_latch is level-sensitive: q follows d while en is 1 and holds while
//   en is 0.
// - ud_dff is edge-sensitive: q takes d on a rising edge of clk and holds on
//   a falling edge and when d changes; a built-in not gate inverts q.
// The inputs change at times 0, 2, 4, 5 and 7, and the outputs are printed
// at times 1, 3, 6 and 8, when no input changes. The flip-flop is printed
// only after its first rising edge (time 2).

`timescale 1ns/1ns

primitive ud_mux (output y, input s, input a, input b);
  table
  // s a b : y
     0 0 ? : 0;
     0 1 ? : 1;
     1 ? 0 : 0;
     1 ? 1 : 1;
     ? 0 0 : 0;
     ? 1 1 : 1;
  endtable
endprimitive

primitive ud_latch (output reg q, input en, input d);
  table
  // en d : q : q+
     1  0 : ? : 0;
     1  1 : ? : 1;
     0  ? : ? : -;
  endtable
endprimitive

primitive ud_dff (output reg q, input clk, input d);
  table
  // clk  d : q : q+
     (01) 0 : ? : 0;
     (01) 1 : ? : 1;
     (?0) ? : ? : -;
     ?  (??) : ? : -;
  endtable
endprimitive

module test_udp_supplements_builtin_gates;
  logic s, a, b, en, d, clk, dd;
  wire and_ab, y_mux, q_latch, q_dff, nq;

  and g_and (and_ab, a, b);
  ud_mux u_mux (y_mux, s, and_ab, b);
  ud_latch u_latch (q_latch, en, d);
  ud_dff u_dff (q_dff, clk, dd);
  not g_not (nq, q_dff);

  initial begin
    s = 0; a = 1; b = 1; en = 1; d = 1; clk = 0; dd = 1;
    #1 $display("t=%0t mux=%b latch=%b", $time, y_mux, q_latch);
    #1 s = 1; b = 0; d = 0; clk = 1;
    #1 $display("t=%0t mux=%b latch=%b dff=%b not=%b", $time, y_mux, q_latch, q_dff, nq);
    #1 en = 0;
    #1 d = 1; s = 1'bx; b = 1; clk = 0; dd = 0;
    #1 $display("t=%0t mux=%b latch=%b dff=%b not=%b", $time, y_mux, q_latch, q_dff, nq);
    #1 clk = 1;
    #1 $display("t=%0t mux=%b latch=%b dff=%b not=%b", $time, y_mux, q_latch, q_dff, nq);
  end
endmodule
