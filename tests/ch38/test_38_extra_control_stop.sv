/*
:name: test_38_extra_control_stop
:description: vpi_control(vpiStop, level) returns 1 and lets the calling routine go on to its end, since the built-in $stop runs only when the routine returns (IEEE 1800-2023 Section 38.4)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.4 20.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_38_extra_control_stop.c
:expected_stdout: @test_38_extra_control_stop.expected
*/
// IEEE 1800-2023 §38.4: vpi_control(vpiStop, level) takes one integer, the
// diagnostic level, and executes the built-in $stop after the application
// routine returns (20.4). The application task $vt_stop prints the time, calls
// vpi_control, prints its return, and prints one more line to show that the
// routine itself goes on, so the stop is not executed inside the routine. The
// level is 0, for which $stop prints nothing (20.2, Table 20-1). $stop
// suspends the simulation (20.2); whether a run without interaction then goes
// on, ends, and with which exit status, is left to the tool, so the design
// prints nothing after the call and the test does not check the exit status.
// vvp in batch mode prints a report of the stop, which level 0 does not
// allow, and goes on (docs/simulator-differences.md).

`timescale 1ns/1ns

module test_38_extra_control_stop;
  initial begin
    #5 $display("5: design before the call");
    $vt_stop;
  end
endmodule
