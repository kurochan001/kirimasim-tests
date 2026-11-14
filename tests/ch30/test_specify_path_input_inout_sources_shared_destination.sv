/*
:name: test_specify_path_input_inout_sources_shared_destination
:description: Module paths run from input and inout ports to output and inout ports, and several sources with paths to one destination each delay the changes they cause by their own path delay (IEEE 1800-2023 Sections 30.3 and 30.4)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.3 30.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_path_input_inout_sources_shared_destination.expected
*/
// IEEE 1800-2023 §30.3: a module path pairs a source, an input or an inout
// port, with a destination, an output or an inout port. §30.4: more than one
// source can have a path to the same destination, each with its own delay.
//
// The cell has the input ports a and c, the inout port b, the output port y
// and the inout port z. y = a ^ b ^ c has paths from a (20), from the inout
// b (40) and from c (60); z = a & b has paths from a (30), an input to an
// inout, and from b (50), an inout to an inout. The inputs change one at a
// time, 100 apart, so the source that changed last is the only one whose
// path is active (30.5.3) and each change of y or z comes that source's
// delay later:
//   100 a rises: y rises at 120
//   200 b rises: y falls at 240, z rises at 250
//   300 a falls: y rises at 320, z falls at 330
//   400 c rises: y falls at 460
//   500 a rises: y rises at 520, z rises at 530
//   600 b falls: y falls at 640, z falls at 650
// Every change is at a multiple of 10. The outputs are sampled 5 after each
// multiple of 10 from 105 on, and a sample that differs from the one before
// prints the time of the change, 5 earlier, and both outputs. The 5.054
// release of Verilator ignores module path delays, so its outputs change at
// once.

`timescale 1ns/1ns

module test_specify_path_input_inout_sources_shared_destination_cell
  (input a, inout b, input c, output y, inout z);
  xor gy (y, a, b, c);
  and gz (z, a, b);
  specify
    (a => y) = 20;
    (b => y) = 40;
    (c => y) = 60;
    (a => z) = 30;
    (b => z) = 50;
  endspecify
endmodule

module test_specify_path_input_inout_sources_shared_destination;
  reg a = 0, bv = 0, c = 0;
  wire b, y, z;
  logic [1:0] prev;

  assign b = bv;

  test_specify_path_input_inout_sources_shared_destination_cell u
    (.a(a), .b(b), .c(c), .y(y), .z(z));

  initial begin
    #100 a = 1;
    #100 bv = 1;
    #100 a = 0;
    #100 c = 1;
    #100 a = 1;
    #100 bv = 0;
  end

  initial begin
    #95 prev = {y, z};
    repeat (60) begin
      #10 if ({y, z} != prev) $display("%0d: y=%b z=%b", $time - 5, y, z);
      prev = {y, z};
    end
    $finish;
  end
endmodule
