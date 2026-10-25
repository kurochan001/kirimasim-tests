/*
:name: test_syntax_n_input_n_output_gates
:description: n-input gates (and, nand, or, nor, xor, xnor) and n-output gates (buf, not) declared with and without drive strength and two delays, with several named and unnamed instances per declaration (IEEE 1800-2023 Section 28.4)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.4 28.5 28.3 28.3.2 28.3.4 A.3.1 A.3.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_syntax_n_input_n_output_gates.expected
*/
// IEEE 1800-2023 §28.4, A.3.1, A.3.4: the six n-input gate keywords take an
// optional drive strength and at most two delays, then one or more instances
// separated by commas; each instance has an optional name and lists its
// output first and then one or more inputs. §28.5: buf and not list one or
// more outputs and then their single input. With two delays the first is the
// rise delay and the second the fall delay (28.4, 28.5); a strength
// specification sets the strength of the driven 0 and 1 (28.3.2).
//
// The logic part applies four input combinations and prints every gate, so
// each keyword is told apart by its truth table, the three-input and gate by
// a & b & c and the one-input nand by ~a. The timed part drives the nor and
// buf instances that have a strength and #(rise, fall) and prints them with
// %v between the rise and fall delays, so swapped delays or a lost strength
// change a line.

`timescale 1ns/1ns

module test_syntax_n_input_n_output_gates;
  reg a, b, c, p, q, r;
  wire y_and, y_nand, y_or, y_nor, y_xor, y_xnor, y_and3, y_one;
  wire n1, n2, n3;
  wire d1, d2, o1, o2, o3;

  and  g_and (y_and, a, b), (y_and3, a, b, c);
  nand (y_nand, a, b), g_one (y_one, a);
  or   g_or (y_or, a, b);
  nor  g_nor (y_nor, a, b);
  xor  (y_xor, a, b);
  xnor g_xnor (y_xnor, a, b);
  not  g_not (n1, n2, b), (n3, c);

  nor (pull0, weak1) #(3, 6) g_d1 (d1, p, q), (d2, p, q, q);
  buf (strong0, pull1) #(2, 5) g_buf (o1, o2, r), (o3, r);

  task show;
    $display("abc=%b%b%b and=%b nand=%b or=%b nor=%b xor=%b xnor=%b and3=%b one=%b not=%b%b%b",
             a, b, c, y_and, y_nand, y_or, y_nor, y_xor, y_xnor, y_and3, y_one, n1, n2, n3);
  endtask

  task timed;
    $display("t=%0t d1=%v d2=%v o1=%v o2=%v o3=%v", $time, d1, d2, o1, o2, o3);
  endtask

  initial begin
    a = 0; b = 0; c = 0;
    p = 0; q = 0; r = 0;
    #1 show;
    b = 1; c = 1;
    #1 show;
    a = 1; c = 0;
    #1 show;
    c = 1;
    #1 show;
    #6 timed;          // t=10
    p = 1; r = 1;      // nor falls at 16, buf rises at 12
    #1 timed;          // t=11
    #2 timed;          // t=13
    #4 timed;          // t=17
    p = 0; r = 0;      // nor rises at 20, buf falls at 22
    #4 timed;          // t=21
    #2 timed;          // t=23
  end
endmodule
