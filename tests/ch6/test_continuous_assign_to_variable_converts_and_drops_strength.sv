/*
:name: test_continuous_assign_to_variable_converts_and_drops_strength
:description: A continuous assignment to a variable, written with assign, by a primitive output or by a module output port, converts the value to the type of the variable and does not keep the strength of the source (IEEE 1800-2023 Section 6.5)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.5 10.3.2 23.3.3 6.11.2 6.12.1 10.3.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_continuous_assign_to_variable_converts_and_drops_strength.expected
*/
// IEEE 1800-2023 §6.5: when a continuous assignment writes a variable, the
// value is converted to the type of the variable and its strength is lost.
// Strength: w_weak is driven 1 with (weak0, weak1) and shows We1. v_cont gets
// it through assign, v_gate from a buf with (weak0, weak1), v_port from the
// output port of a child that drives (weak0, weak1) 1 (a variable on an output
// port is written by a continuous assignment, 6.5, 23.3.3). Each variable then
// drives the input port net i of a monitor instance through a continuous
// assignment of the default strength (strong, 10.3.4, 23.3.3), so i shows St1;
// if the weak strength had been kept in the variable, i would show We1.
// Conversion: w8 = 8'b0110_1x0z. The 2-state bit [7:0] and int get 0 for the
// x and z bits (6.11.2): 01101000 = 104, and so does real (6.12.1): 104.0.
// The 4-state logic [3:0] keeps the low bits 1x0z after the truncation of the
// high bits. byte from w12 = 12'h1c8 keeps 8'hc8, which is -56 as a signed
// byte. int from the real -2.5 rounds away from zero to -3 (6.12.1). b8p gets
// w8's value through the output port of a child and is converted the same way.
// Oracle checks: Icarus Verilog 13.0 rejects the buf whose output is the
// variable v_gate (6.5 and 10.3.2 allow one primitive output to drive a
// variable), and without it shows port=We1: it keeps the weak strength in
// v_port. The 5.052 release does not model strengths (w_weak shows St1).

module test_continuous_assign_to_variable_converts_and_drops_strength_weak (output wire o);
  assign (weak0, weak1) o = 1'b1;
endmodule

module test_continuous_assign_to_variable_converts_and_drops_strength_drv8 (
  output wire [7:0] o
);
  assign o = 8'b0110_1x0z;
endmodule

module test_continuous_assign_to_variable_converts_and_drops_strength_mon (input wire i);
endmodule

module test_continuous_assign_to_variable_converts_and_drops_strength;
  wire w_weak;
  assign (weak0, weak1) w_weak = 1'b1;

  logic v_cont;
  bit v_gate;
  logic v_port;
  assign v_cont = w_weak;
  buf (weak0, weak1) g(v_gate, 1'b1);
  test_continuous_assign_to_variable_converts_and_drops_strength_weak d_w(.o(v_port));

  test_continuous_assign_to_variable_converts_and_drops_strength_mon m_cont(.i(v_cont));
  test_continuous_assign_to_variable_converts_and_drops_strength_mon m_gate(.i(v_gate));
  test_continuous_assign_to_variable_converts_and_drops_strength_mon m_port(.i(v_port));

  wire [7:0] w8 = 8'b0110_1x0z;
  wire [11:0] w12 = 12'h1c8;
  real rr = -2.5;
  bit [7:0] b8;
  int i32;
  real r;
  logic [3:0] l4;
  byte s8;
  int from_real;
  bit [7:0] b8p;
  assign b8 = w8;
  assign i32 = w8;
  assign r = w8;
  assign l4 = w8;
  assign s8 = w12;
  assign from_real = rr;
  test_continuous_assign_to_variable_converts_and_drops_strength_drv8 d_8(.o(b8p));

  initial begin
    #1;
    $display("source: w_weak=%v", w_weak);
    $display("values: v_cont=%b v_gate=%b v_port=%b", v_cont, v_gate, v_port);
    $display("strength after variable: assign=%v gate=%v port=%v", m_cont.i, m_gate.i,
             m_port.i);
    $display("convert: b8=%b i32=%0d r=%0.1f l4=%b s8=%0d from_real=%0d b8p=%b", b8, i32, r,
             l4, s8, from_real, b8p);
  end
endmodule
