/*
:name: test_specify_inout_paths
:description: An inout port can be the destination and the source of module paths, and its path delays apply in both directions (IEEE 1800-2023 Section 30.4.1)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.4.1 30.4.2 30.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_inout_paths.expected
*/
// IEEE 1800-2023 §30.4.1: the source of a module path is a net connected to an
// input or inout port, and the destination a net or variable connected to an
// output or inout port. The module drives its inout port io from a, through a
// path with delay 3, and copies io to its output y through a path with delay
// 5 (30.4.2), so io is the destination of one path and the source of the
// other. a rises at 10 and falls at 30: io follows 3 later, y 5 after io.

`timescale 1ns/1ns

module test_specify_inout_paths_port(inout io, output y, input a);
  buf (io, a);
  buf (y, io);
  specify
    (a => io) = 3;
    (io => y) = 5;
  endspecify
endmodule

module test_specify_inout_paths;
  reg a = 0;
  wire io, y;

  test_specify_inout_paths_port u(io, y, a);

  always @(io) if ($time >= 10) $display("%0d: io=%b", $time, io);
  always @(y) if ($time >= 10) $display("%0d: y=%b", $time, y);

  initial begin
    #10 a = 1;              // io at 13, y at 18
    #20 a = 0;              // 30: io at 33, y at 38
    #20 $finish;
  end
endmodule
