/*
:name: test_timeunit_precision_order
:description: timeprecision may come before timeunit in the compilation-unit scope, and both apply to a module that declares neither (IEEE 1800-2023 Section 3.14.2.2)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.2.2 3.14.2.3 3.14.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timeunit_precision_order.expected
*/
// IEEE 1800-2023 §3.14.2.2: the timeunit and timeprecision declarations may
// come in either order, as long as both come before the other items of their
// time scope. §3.14.2.3: a module that declares neither takes both from the
// compilation-unit scope. §3.14.1: a delay is rounded to the time precision,
// so #1.0006 is 1.001 ns with a precision of 1 ps, and $realtime, in the time
// unit of the module, 1 ns, prints that.

timeprecision 1ps;
timeunit 1ns;

module test_timeunit_precision_order;
  initial #1.0006 $display("%0.3f", $realtime);
endmodule
