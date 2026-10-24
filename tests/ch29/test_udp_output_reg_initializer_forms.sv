/*
:name: test_udp_output_reg_initializer_forms
:description: the output reg declaration of a sequential UDP can give the initial value of the output with = and a constant, both in an ANSI header and in a port declaration after a list of port names (IEEE 1800-2023 Section 29.3)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.3 29.3.2 29.3.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_udp_output_reg_initializer_forms.expected
*/
// IEEE 1800-2023 §29.3, Syntax 29-1: a UDP output can be declared output
// reg with = and a constant expression, in the port declarations of an ANSI
// header or in a port declaration that follows a list of port names; the
// value is the output value at the start of the simulation, as from an
// initial statement (29.3.3), and the reg declaration that a sequential UDP
// needs is part of that output declaration (29.3.2). Each UDP below has one
// input, which nothing assigns, and a table whose only entry keeps the state
// for any input value, so that the outputs keep their initial values,
// printed after one time unit.
// Icarus Verilog 13.0 stops on an internal assertion for an output reg with
// a value in an ANSI UDP header.

primitive init_ansi_1(output reg q = 1'b1, input c);
  table
    ? : ? : -;
  endtable
endprimitive

primitive init_ansi_0(output reg q = 0, input c);
  table
    ? : ? : -;
  endtable
endprimitive

primitive init_decl_1(q, c);
  output reg q = 1'b1;
  input c;
  table
    ? : ? : -;
  endtable
endprimitive

primitive init_decl_0(q, c);
  output reg q = 0;
  input c;
  table
    ? : ? : -;
  endtable
endprimitive

module test_udp_output_reg_initializer_forms;
  logic c;
  wire a1, a0, d1, d0;
  init_ansi_1 u1(a1, c);
  init_ansi_0 u2(a0, c);
  init_decl_1 u3(d1, c);
  init_decl_0 u4(d0, c);

  initial begin
    #1;
    $display("header output reg q = 1'b1: %b", a1);
    $display("header output reg q = 0: %b", a0);
    $display("declaration output reg q = 1'b1: %b", d1);
    $display("declaration output reg q = 0: %b", d0);
  end
endmodule
