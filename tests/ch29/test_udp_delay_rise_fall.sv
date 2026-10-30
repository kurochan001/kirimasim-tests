/*
:name: test_udp_delay_rise_fall
:description: A combinational UDP instance with two delays uses the first for a change to 1 and the second for a change to 0, and an input change that keeps the output does not start a delay (IEEE 1800-2023 Section 29.8)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.8 29.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_delay_rise_fall.expected
*/
// IEEE 1800-2023 §29.8: the first of two delays of a UDP instance is for a
// change of the output to 1 and the second for a change to 0. The output is x
// at the start, so the first change, to 0 after the inputs become known, takes
// the fall delay 5. Setting a = 1 at 6 keeps the output 0, so nothing is
// scheduled; b = 1 at 8 makes it 1 after the rise delay 2, and a = 0 at 12
// makes it 0 after the fall delay 5. The test samples half a nanosecond
// before and after each due time: a sample in the time step of a change could
// run before or after the change (4.7).

`timescale 1ns/100ps

primitive udp_and_rf (y, a, b);
  output y;
  input a, b;
  table
  // a b : y
    0 ? : 0;
    ? 0 : 0;
    1 1 : 1;
  endtable
endprimitive

module test_udp_delay_rise_fall;
  reg a, b;
  wire y;

  udp_and_rf #(2, 5) u (y, a, b);

  initial begin
    a = 0;
    b = 0;
    #4.5 $display("t=%0.1f: y=%b", $realtime, y);
    #1 $display("t=%0.1f: y=%b", $realtime, y);
    #0.5 a = 1;
    #2 b = 1;
    #1.5 $display("t=%0.1f: y=%b", $realtime, y);
    #1 $display("t=%0.1f: y=%b", $realtime, y);
    #1.5 a = 0;
    #4.5 $display("t=%0.1f: y=%b", $realtime, y);
    #1 $display("t=%0.1f: y=%b", $realtime, y);
  end
endmodule
