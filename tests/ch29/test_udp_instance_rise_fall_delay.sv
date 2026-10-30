/*
:name: test_udp_instance_rise_fall_delay
:description: An instance of a sequential UDP with two delays uses the first for a change to 1 and the second for a change to 0 (IEEE 1800-2023 Section 29.8)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.8 29.6 29.3.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_instance_rise_fall_delay.expected
*/
// IEEE 1800-2023 §29.8: the two delays of a sequential UDP instance are its
// rise and fall delays. §29.6: the table makes q follow d at a rising clock
// edge, and keep its value otherwise. The edge at 2 schedules q to 1 after
// the rise delay 2, so q is still x at 3.5 and is 1 at 4.5; the edge at 7
// schedules q to 0 after the fall delay 3, so q is still 1 at 9.5 and is 0 at
// 10.5. The samples are half a nanosecond away from the changes at 4 and 10:
// a sample in the time step of a change could run before or after it (4.7).
// The 5.052 release changes q at the clock edge and ignores the delays.

`timescale 1ns/100ps

primitive udp_dff(q, clk, d);
  output q;
  reg q;
  input clk, d;
  table
    (01) 0 : ? : 0;
    (01) 1 : ? : 1;
    (0x) 0 : ? : 0;
    (0x) 1 : ? : 1;
    (x1) 0 : ? : 0;
    (x1) 1 : ? : 1;
    (?0) ? : ? : -;
    ? (??) : ? : -;
  endtable
endprimitive

module test_udp_instance_rise_fall_delay;
  reg clk = 0;
  reg d = 0;
  wire q;

  udp_dff #(2, 3) u(q, clk, d);

  initial begin
    #1 d = 1;
    #1 clk = 1;
    #1.5 $display("%0.1f: q=%b", $realtime, q);
    #1 $display("%0.1f: q=%b", $realtime, q);
    #0.5 d = 0;
    #1 clk = 0;
    #1 clk = 1;
    #2.5 $display("%0.1f: q=%b", $realtime, q);
    #1 $display("%0.1f: q=%b", $realtime, q);
    $finish;
  end
endmodule
