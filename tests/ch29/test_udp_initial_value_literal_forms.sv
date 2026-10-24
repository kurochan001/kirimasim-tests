/*
:name: test_udp_initial_value_literal_forms
:description: the initial statement of a sequential UDP accepts each literal form 1'b0, 1'b1, 1'bx, 1'bX, 1'B0, 1'B1, 1'Bx, 1'BX, 1 and 0 and sets the output to that value when simulation starts (IEEE 1800-2023 Section 29.3.3)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.3 29.3.3 29.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_initial_value_literal_forms.expected
*/
// IEEE 1800-2023 §29.3.3 and §29.7: the initial statement of a sequential
// UDP is one assignment of a single-bit literal to the output, which sets
// its value at the start of the simulation; Syntax 29-1 (29.3) allows the
// values 1'b0, 1'b1, 1'bx, 1'bX, 1'B0, 1'B1, 1'Bx, 1'BX, 1 and 0. Each
// UDP below has one input, which stays x because nothing assigns it, and
// a table whose only entry keeps the state for any input value, so that
// the output keeps its initial value; the outputs are printed after one
// time unit.

primitive init_0(q, c);
  output q;
  reg q;
  input c;
  initial q = 1'b0;
  table
    ? : ? : -;
  endtable
endprimitive

primitive init_1(q, c);
  output q;
  reg q;
  input c;
  initial q = 1'b1;
  table
    ? : ? : -;
  endtable
endprimitive

primitive init_2(q, c);
  output q;
  reg q;
  input c;
  initial q = 1'bx;
  table
    ? : ? : -;
  endtable
endprimitive

primitive init_3(q, c);
  output q;
  reg q;
  input c;
  initial q = 1'bX;
  table
    ? : ? : -;
  endtable
endprimitive

primitive init_4(q, c);
  output q;
  reg q;
  input c;
  initial q = 1'B0;
  table
    ? : ? : -;
  endtable
endprimitive

primitive init_5(q, c);
  output q;
  reg q;
  input c;
  initial q = 1'B1;
  table
    ? : ? : -;
  endtable
endprimitive

primitive init_6(q, c);
  output q;
  reg q;
  input c;
  initial q = 1'Bx;
  table
    ? : ? : -;
  endtable
endprimitive

primitive init_7(q, c);
  output q;
  reg q;
  input c;
  initial q = 1'BX;
  table
    ? : ? : -;
  endtable
endprimitive

primitive init_8(q, c);
  output q;
  reg q;
  input c;
  initial q = 1;
  table
    ? : ? : -;
  endtable
endprimitive

primitive init_9(q, c);
  output q;
  reg q;
  input c;
  initial q = 0;
  table
    ? : ? : -;
  endtable
endprimitive

module test_udp_initial_value_literal_forms;
  logic c;
  wire q0, q1, q2, q3, q4, q5, q6, q7, q8, q9;
  init_0 u0(q0, c);
  init_1 u1(q1, c);
  init_2 u2(q2, c);
  init_3 u3(q3, c);
  init_4 u4(q4, c);
  init_5 u5(q5, c);
  init_6 u6(q6, c);
  init_7 u7(q7, c);
  init_8 u8(q8, c);
  init_9 u9(q9, c);

  initial begin
    #1;
    $display("initial q = 1'b0: %b", q0);
    $display("initial q = 1'b1: %b", q1);
    $display("initial q = 1'bx: %b", q2);
    $display("initial q = 1'bX: %b", q3);
    $display("initial q = 1'B0: %b", q4);
    $display("initial q = 1'B1: %b", q5);
    $display("initial q = 1'Bx: %b", q6);
    $display("initial q = 1'BX: %b", q7);
    $display("initial q = 1: %b", q8);
    $display("initial q = 0: %b", q9);
  end
endmodule
