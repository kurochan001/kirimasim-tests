/*
:name: test_time_functions_current_time
:description: $time, $stime and $realtime are called without arguments and return the current simulation time in the time unit of the module, as a 64-bit integer, a 32-bit unsigned integer and a real (IEEE 1800-2023 Section 20.3)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.3 20.3.1 20.3.2 20.3.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_time_functions_current_time.expected
*/
// IEEE 1800-2023 §20.3: the system functions $time, $stime and $realtime give
// the current simulation time; Syntax 20-2 has them without arguments. They
// return the time in the time unit of the module that calls them (20.3.1 to
// 20.3.3): $time a 64-bit integer, $stime a 32-bit unsigned integer and
// $realtime a real. The module has a time unit of 1 ns, and the delays are
// whole numbers of it, so all three give the same number of nanoseconds: 0 at
// the start, then 5 and 17.

`timescale 1ns/1ns

module test_time_functions_current_time;
  task automatic show();
    $display("$time=%0d $stime=%0d $realtime=%.1f", $time, $stime, $realtime);
  endtask

  initial begin
    $display("bits: $time %0d, $stime %0d", $bits($time), $bits($stime));
    show();
    #5 show();
    #12 show();
  end
endmodule
