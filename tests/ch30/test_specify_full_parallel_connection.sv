/*
:name: test_specify_full_parallel_connection
:description: A full connection path connects every bit of the source to every bit of the destination, and a parallel one connects bit to bit (IEEE 1800-2023 Section 30.4.5)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.4.5 30.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_full_parallel_connection.expected
*/
// IEEE 1800-2023 §30.4.5: (a *> yf) is a full connection: every bit of a has a
// path to every bit of yf, so a change of a[1] that changes yf[0], or of a[0]
// that changes yf[1], is delayed by the path delay of 3. (b => yp) is a
// parallel connection of two vectors of the same width, bit to bit, with a
// delay of 5. Transitions before time 10 are not printed.

`timescale 1ns/1ns

module specify_full_parallel(output [1:0] yf, output [1:0] yp, input [1:0] a, input [1:0] b);
  assign yf = {a[1] & a[0], a[1] | a[0]};
  assign yp = b;
  specify
    (a *> yf) = 3;
    (b => yp) = 5;
  endspecify
endmodule

module test_specify_full_parallel_connection;
  reg [1:0] a = 2'b00, b = 2'b00;
  wire [1:0] yf, yp;

  specify_full_parallel u(yf, yp, a, b);

  always @(yf or yp) if ($time >= 10) $display("%0d: yf=%b yp=%b", $time, yf, yp);

  initial begin
    #10 a = 2'b10;   // a[1] changes yf[0]: yf at 13
    #10 a = 2'b11;   // a[0] changes yf[1]: yf at 23
    #10 b = 2'b10;   // yp[1] at 35
    #10 $finish;
  end
endmodule
