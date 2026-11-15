/*
:name: test_specify_parallel_path_bit_to_bit
:description: A parallel module path between two 2-bit vectors connects each source bit only to the destination bit of the same position, and between two scalars => and *> set up the same path (IEEE 1800-2023 Section 30.4.5)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.4.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_parallel_path_bit_to_bit.expected
*/
// IEEE 1800-2023 §30.4.5: => sets up a parallel connection, in which each bit
// of the source connects to the one corresponding bit of a destination of the
// same width; *> connects every bit to every bit. Between two scalars both
// give the same bit-to-bit connection.
//
// The cell pc has y[0] = a[0] and y[1] = a[1] ^ a[0], the parallel path
// (a => y) with the delay 10 and the path (a[0] => y[1]) with the delay 30.
// A parallel connection of N bits is N paths, each from one source bit to
// one destination bit (Figure 30-2), so y[0] has one path, from a[0] (10),
// and y[1] has two, from a[1] (10) and from a[0] (30). Each change below is
// of one input bit, long after the one before, and every output bit that
// changes has a path from that bit. By the delay selection of §30.5.3 only
// the paths whose input bit changed last are active, so each delay is the
// delay of one path:
//   100: a[0] rises:  y[0] rises at 110, y[1] rises at 130;
//   200: a[1] rises:  y[1] falls at 210;
//   300: a[0] falls:  y[0] falls at 310, y[1] rises at 330.
// If => connected a[0] to y[1] as well, a[0] would have paths of 10 and 30 to
// y[1], the smaller would be chosen, and y[1] would change at 110 and 310.
// The scalar cells sp, with (a => y), and sf, with (a *> y), are buffers with
// the rise delay 20 and the fall delay 50 (30.5.1): s rises at 100 and both
// outputs rise at 120, s falls at 200 and both fall at 250.
// Every change is at a multiple of 10. The outputs are sampled 5 after each
// multiple of 10 from 105 on, and a sample that differs from the one before
// prints the time of the change, 5 earlier, and the outputs.
// The expected output follows the standard alone. Icarus Verilog 13.0 warns
// that it does not support bit-selects in path declarations and applies
// (a[0] => y[1]) to the whole vectors, so y[1] changes at 110 and 310 there.
// The 5.054 release of Verilator ignores module path delays.

`timescale 1ns/1ns

module test_specify_parallel_path_bit_to_bit_pc (input [1:0] a, output [1:0] y);
  assign y = {a[1] ^ a[0], a[0]};
  specify
    (a => y) = 10;
    (a[0] => y[1]) = 30;
  endspecify
endmodule

module test_specify_parallel_path_bit_to_bit_sp (input a, output y);
  buf g (y, a);
  specify
    (a => y) = (20, 50);
  endspecify
endmodule

module test_specify_parallel_path_bit_to_bit_sf (input a, output y);
  buf g (y, a);
  specify
    (a *> y) = (20, 50);
  endspecify
endmodule

module test_specify_parallel_path_bit_to_bit;
  reg [1:0] a;
  reg s;
  wire [1:0] y;
  wire sp, sf;
  logic [3:0] prev;

  test_specify_parallel_path_bit_to_bit_pc upc (a, y);
  test_specify_parallel_path_bit_to_bit_sp usp (s, sp);
  test_specify_parallel_path_bit_to_bit_sf usf (s, sf);

  initial begin
    a = 2'b00;
    s = 0;
    #100 a = 2'b01;
    s = 1;
    #100 a = 2'b11;
    s = 0;
    #100 a = 2'b10;
  end

  initial begin
    #95 prev = {y, sp, sf};
    repeat (30) begin
      #10 if ({y, sp, sf} != prev)
        $display("%0d: y=%b sp=%b sf=%b", $time - 5, y, sp, sf);
      prev = {y, sp, sf};
    end
    $finish;
  end
endmodule
