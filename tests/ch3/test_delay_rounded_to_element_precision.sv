/*
:name: test_delay_rounded_to_element_precision
:description: A delay is rounded to the time precision of its own design element before it is scheduled: with 1ns / 100ps, 2.75 becomes 2.8 and 2.74 becomes 2.7, and with 1ns / 1ns, 2.75 becomes 3 and 2.4 becomes 2, although another module has a precision of 1ps (IEEE 1800-2023 Section 3.14.1)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.1 3.14.2.2 20.3.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_delay_rounded_to_element_precision.expected
*/
// IEEE 1800-2023 §3.14.1: the time precision of a design element says how its
// delay values are rounded before they are used. A precision one tenth of the
// time unit rounds to one decimal place, so with 1ns / 100ps a delay of 2.75
// waits 2.8 ns; a precision equal to the unit rounds to whole units. The
// rounding uses the precision of the element itself, even though the top
// module declares a finer one (1ps), which makes the simulation time fine
// enough to show an unrounded delay.
// round_tenth (1ns / 100ps, §3.14.2.2) waits 2.75 (rounded up to 2.8, the
// halfway case), 2.74 (down to 2.7) and 2.76 (up to 2.8): it is at 2.8, 5.5
// and 8.3 ns. round_whole (1ns / 1ns) first waits 10, then 2.75 (to 3) and
// 2.4 (to 2): it is at 13 and 15 ns. Each prints $realtime (§20.3.3) in its
// own unit, 1 ns, and the two modules never print at the same time.
// Release 5.052 of Verilator does not round the delays of round_tenth to its
// precision (it prints 2.750 after #2.75).

module round_tenth;
  timeunit 1ns;
  timeprecision 100ps;
  initial begin
    #2.75 $display("tenth: after #2.75 at %.3f", $realtime);
    #2.74 $display("tenth: after #2.74 at %.3f", $realtime);
    #2.76 $display("tenth: after #2.76 at %.3f", $realtime);
  end
endmodule

module round_whole;
  timeunit 1ns;
  timeprecision 1ns;
  initial begin
    #10;
    #2.75 $display("whole: after #10 and #2.75 at %.3f", $realtime);
    #2.4 $display("whole: after #2.4 at %.3f", $realtime);
  end
endmodule

module test_delay_rounded_to_element_precision;
  timeunit 1ns;
  timeprecision 1ps;
  round_tenth t();
  round_whole w();
endmodule
