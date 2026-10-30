/*
:name: test_udp_delay_single_value
:description: A combinational UDP instance with one delay changes its output that much later for a change to 1, to 0 and to x, and not at all when the output keeps its value (IEEE 1800-2023 Section 29.8)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.8 29.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_delay_single_value.expected
*/
// IEEE 1800-2023 §29.8: the single delay of a UDP instance is the time
// between a change of an input and the change of the output that it causes.
// The AND here is x until the delay after its inputs become known, then 0.
// Setting a = 1 at 4 leaves the output 0, so nothing is scheduled; setting
// b = 1 at 6 makes the output 1 at 9, and setting b = x at 10 makes it x at
// 13. The test samples the output half a nanosecond before and after each
// due change: a sample in the time step of a change could run before or
// after the change (4.7).

`timescale 1ns/100ps

primitive udp_and_d (y, a, b);
  output y;
  input a, b;
  table
  // a b : y
    0 ? : 0;
    ? 0 : 0;
    1 1 : 1;
  endtable
endprimitive

module test_udp_delay_single_value;
  reg a, b;
  wire y;

  udp_and_d #(3) u (y, a, b);

  initial begin
    a = 0;
    b = 0;
    #2.5 $display("t=%0.1f: y=%b", $realtime, y);
    #1 $display("t=%0.1f: y=%b", $realtime, y);
    #0.5 a = 1;
    #1 $display("t=%0.1f: y=%b", $realtime, y);
    #1 b = 1;
    #2.5 $display("t=%0.1f: y=%b", $realtime, y);
    #1 $display("t=%0.1f: y=%b", $realtime, y);
    #0.5 b = 1'bx;
    #2.5 $display("t=%0.1f: y=%b", $realtime, y);
    #1 $display("t=%0.1f: y=%b", $realtime, y);
  end
endmodule
