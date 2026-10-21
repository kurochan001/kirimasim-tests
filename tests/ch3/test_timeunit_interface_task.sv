/*
:name: test_timeunit_interface_task
:description: A delay in a task of an interface is in the time unit of the interface, not in that of the module that calls it (IEEE 1800-2023 Section 3.14.2.3)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.2.3 3.14.2.2 3.14.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timeunit_interface_task.expected
*/
// IEEE 1800-2023 §3.14.2.3: a design element takes the time unit and precision
// of the scope that encloses it. The interface ifc_time declares 10 ns and
// 1 ns, so #1 in its task waits 10 ns. The module declares 1 ns and 1 ps
// after the interface (§3.14.2.2), so its $realtime, which is in its own unit
// (§3.14.1), prints the wait as 10.000.

interface ifc_time;
  timeunit 10ns;
  timeprecision 1ns;

  task automatic wait_one();
    #1;
  endtask
endinterface

`timescale 1ns/1ps

module test_timeunit_interface_task;
  ifc_time u();

  initial begin
    u.wait_one();
    $display("%0.3f", $realtime);
    $finish;
  end
endmodule
