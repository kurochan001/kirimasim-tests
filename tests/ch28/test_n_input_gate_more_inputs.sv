/*
:name: test_n_input_gate_more_inputs
:description: gates with three or four inputs extend the two-input truth tables, also for x and z inputs, and have the same delay as the two-input gate (IEEE 1800-2023 Section 28.4)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_n_input_gate_more_inputs.expected
*/
// IEEE 1800-2023 §28.4: an and, nand, or, nor, xor or xnor gate with more
// than two inputs extends the two-input function in the natural way: and,
// or and xor of all the inputs, inverted for nand, nor and xnor, with a
// controlling 0 (and) or 1 (or) deciding the result even next to x or z,
// and any x or z that does not meet such a value giving x. The number of
// inputs does not change the propagation delay.
// The first part drives three-input gates of all six kinds with patterns
// of 0, 1, x and z. The second part compares a two-input and a four-input
// and gate, both #4, and a two-input and a four-input xor gate, both
// #(2, 6), when input p falls at time 20 and rises at time 30 while the
// other inputs stay 1: the outputs of each pair have to change together.

`timescale 1ns/1ns

module test_n_input_gate_more_inputs;
  logic a, b, c;
  wire y_and, y_nand, y_or, y_nor, y_xor, y_xnor;
  logic [2:0] pat[10] = '{3'b111, 3'b11x, 3'b1z0, 3'b0x0, 3'b00z,
                          3'b000, 3'b110, 3'b0z1, 3'b1x1, 3'b100};

  and  (y_and, a, b, c);
  nand (y_nand, a, b, c);
  or   (y_or, a, b, c);
  nor  (y_nor, a, b, c);
  xor  (y_xor, a, b, c);
  xnor (y_xnor, a, b, c);

  logic p, q, r, s;
  wire e2, e4, f2, f4;

  and #4      d2 (e2, p, q);
  and #4      d4 (e4, p, q, r, s);
  xor #(2, 6) x2 (f2, p, q);
  xor #(2, 6) x4 (f4, p, q, r, s);

  initial begin
    for (int i = 0; i < 10; i++) begin
      {a, b, c} = pat[i];
      #1 $display("abc=%b%b%b and=%b nand=%b or=%b nor=%b xor=%b xnor=%b",
                  a, b, c, y_and, y_nand, y_or, y_nor, y_xor, y_xnor);
    end
  end

  initial begin
    p = 1; q = 1; r = 1; s = 1;
    #20 p = 0;
    #10 p = 1;
  end

  initial begin
    #21 $display("t=%0t and2=%b and4=%b xor2=%b xor4=%b", $time, e2, e4, f2, f4);
    #2  $display("t=%0t and2=%b and4=%b xor2=%b xor4=%b", $time, e2, e4, f2, f4);
    #2  $display("t=%0t and2=%b and4=%b xor2=%b xor4=%b", $time, e2, e4, f2, f4);
    #6  $display("t=%0t and2=%b and4=%b xor2=%b xor4=%b", $time, e2, e4, f2, f4);
    #2  $display("t=%0t and2=%b and4=%b xor2=%b xor4=%b", $time, e2, e4, f2, f4);
    #2  $display("t=%0t and2=%b and4=%b xor2=%b xor4=%b", $time, e2, e4, f2, f4);
    #2  $display("t=%0t and2=%b and4=%b xor2=%b xor4=%b", $time, e2, e4, f2, f4);
  end
endmodule
