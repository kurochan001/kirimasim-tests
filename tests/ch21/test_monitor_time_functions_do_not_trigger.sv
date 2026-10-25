/*
:name: test_monitor_time_functions_do_not_trigger
:description: $monitor prints its whole argument list at the end of a time step in which an argument changed, but not when only $time, $stime or $realtime in the list change (IEEE 1800-2023 Section 21.2.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_monitor_time_functions_do_not_trigger.expected
*/
// IEEE 1800-2023 §21.2.3: after $monitor is called, the whole argument list
// is printed, as by $display, at the end of each time step in which a
// variable or expression of the list changed value; a change of $time,
// $stime or $realtime alone does not cause a print.
// The list holds $time, $stime, $realtime and a. a changes at times 0, 5, 8
// and 10 and is left alone at the other times up to 15, so there are only
// four prints although time advances. At time 5 a $display after #0 runs
// before the print, which waits for the end of the step; at time 8 a is set
// by a nonblocking assignment and the $display before it shows the old value;
// at time 10 a is changed twice and the print shows the last value.
// Release 5.052 of Verilator prints the monitor line of time 5 before the
// $display that runs after #0 in the same time step.

`timescale 1ns/1ns

module test_monitor_time_functions_do_not_trigger;
  int a = 0;

  initial begin
    $monitor("[%0t][%0t][%0t] a=%0d", $time, $stime, $realtime, a);
    a = 1;
    #5;
    a = 2;
    #0 $display("t5 display");
    #3;
    a <= 3;
    $display("t8 a=%0d", a);
    #2;
    a = 4;
    #0 a = 5;
    #5 $display("t15 end");
  end
endmodule
