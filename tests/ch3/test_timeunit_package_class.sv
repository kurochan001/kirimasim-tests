/*
:name: test_timeunit_package_class
:description: A delay in a class method is in the time unit of the package that declares the class, not in that of the module that calls it (IEEE 1800-2023 Section 3.14.2.3)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.2.3 3.14.2.2 3.14.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timeunit_package_class.expected
*/
// IEEE 1800-2023 §3.14.2.3: a design element takes the time unit and precision
// of the scope that encloses it. The package tp_pkg declares 10 ns and 1 ns,
// so the class waiter in it takes that unit, and #1 in its task waits 10 ns.
// The module declares 1 ns and 1 ps after the package (§3.14.2.2), so its
// $realtime, which is in its own unit (§3.14.1), prints the wait as 10.000.

package tp_pkg;
  timeunit 10ns;
  timeprecision 1ns;

  class waiter;
    task automatic wait_one();
      #1;
    endtask
  endclass
endpackage

`timescale 1ns/1ps

module test_timeunit_package_class;
  tp_pkg::waiter w;

  initial begin
    w = new;
    w.wait_one();
    $display("%0.3f", $realtime);
    $finish;
  end
endmodule
