/*
:name: test_udp_header_forms_and_input_field_order
:description: UDPs are defined with a list of port names followed by port declarations or with port declarations in the header, combinational and sequential, with or without an end label, and the input fields of their tables follow the order of the header, not of the input declarations (IEEE 1800-2023 Section 29.3.1)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.3.1 29.3 29.3.2 29.3.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_udp_header_forms_and_input_field_order.expected
*/
// IEEE 1800-2023 §29.3.1: a UDP definition starts with primitive and its
// name, followed either by a list of port names, the output first, and then
// port declarations (29.3.2), or by the port declarations themselves; then
// comes the state table and endprimitive, optionally followed by a colon and
// the name (29.3). The output is declared with output, alone or as output
// reg in a sequential UDP, the reg also in a declaration of its own, and the
// inputs with input and a list of names. §29.3.4: the input fields of a
// table row are in the order of the port list in the header, whatever the
// order of the input declarations. mux_nonansi has the header (y, s, a, b)
// but declares b, a and then s; its rows read s a b, so y is a when s is 0
// and b when s is 1. mux_ansi declares the same ports in its header. The
// two latches, one with a separate reg declaration and one with output reg
// in the header, pass d while en is 1 and hold it while en is 0.
// Icarus Verilog 13.0 rejects the input declaration "input a, b" with two
// names in the header of mux_ansi (a syntax error); the grammar of 29.3
// allows a list of names there.

primitive mux_nonansi(y, s, a, b);
  input b, a;
  input s;
  output y;
  table
  // s a b : y
     0 0 ? : 0;
     0 1 ? : 1;
     1 ? 0 : 0;
     1 ? 1 : 1;
  endtable
endprimitive : mux_nonansi

primitive mux_ansi(output y, input s, input a, b);
  table
  // s a b : y
     0 0 ? : 0;
     0 1 ? : 1;
     1 ? 0 : 0;
     1 ? 1 : 1;
  endtable
endprimitive

primitive latch_nonansi(q, en, d);
  output q;
  reg q;
  input en, d;
  table
  // en d : q : q+
     1  0 : ? : 0;
     1  1 : ? : 1;
     0  ? : ? : -;
  endtable
endprimitive

primitive latch_ansi(output reg q, input en, input d);
  table
  // en d : q : q+
     1  0 : ? : 0;
     1  1 : ? : 1;
     0  ? : ? : -;
  endtable
endprimitive : latch_ansi

module test_udp_header_forms_and_input_field_order;
  logic s, a, b, en, d;
  wire y1, y2, q1, q2;
  mux_nonansi m1(y1, s, a, b);
  mux_ansi m2(y2, s, a, b);
  latch_nonansi l1(q1, en, d);
  latch_ansi l2(q2, en, d);

  initial begin
    for (int i = 0; i < 8; i++) begin
      {s, a, b} = i[2:0];
      #1 $display("s=%b a=%b b=%b: mux_nonansi=%b mux_ansi=%b", s, a, b, y1, y2);
    end
    en = 1'b1; d = 1'b1;
    #1 $display("en=1 d=1: latch_nonansi=%b latch_ansi=%b", q1, q2);
    en = 1'b0;
    #1 d = 1'b0;
    #1 $display("en=0 d=0: latch_nonansi=%b latch_ansi=%b", q1, q2);
    en = 1'b1;
    #1 $display("en=1 d=0: latch_nonansi=%b latch_ansi=%b", q1, q2);
  end
endmodule
