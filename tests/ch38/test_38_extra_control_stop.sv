/*
:name: test_38_extra_control_stop
:description: vpi_control(vpiStop, level) returns 1, lets the calling routine return, and then executes the built-in $stop, whose message comes after the routine's last line (IEEE 1800-2023 Section 38.4)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.4 20.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_38_extra_control_stop.c
:expected_stdout: @test_38_extra_control_stop.expected
:expected_exit: 0
*/
// IEEE 1800-2023 §38.4: vpi_control(vpiStop, level) takes one integer, the
// diagnostic level, and executes the built-in $stop after the application
// routine returns (20.4). The application task $vt_stop prints the time, calls
// vpi_control, prints its return, and prints one more line to show that the
// routine itself goes on. The design prints before the call and after it. The
// tool's $stop message appears between the routine's last line and the design
// line that follows the call, so the stop is executed after the return and not
// inside the routine. vvp in batch mode treats $stop as a stop that the user
// continues; its message is the tool's report of the built-in $stop.

`timescale 1ns/1ns

module test_38_extra_control_stop;
  initial begin
    #5 $display("5: design before the call");
    $vt_stop;
    $display("5: design after the call");
  end
endmodule
