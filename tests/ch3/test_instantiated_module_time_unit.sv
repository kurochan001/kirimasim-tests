/*
:name: test_instantiated_module_time_unit
:description: A module takes the `timescale in effect where it is declared, not where it is instantiated, so its delays are in that unit (IEEE 1800-2023 Sections 3.14.2.3, 3.14.2.1)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.2.3 3.14.2.1 20.3.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_instantiated_module_time_unit.expected
*/
// IEEE 1800-2023 §3.14.2.1: a `timescale applies to the design elements that
// are declared after it, and §3.14.2.3: an instantiated module keeps the time
// unit of its own declaration, not the one of the module that instantiates
// it. child is declared under a timescale of 10ns and the module around its
// instance under one of 1ns, so the #2 of child is 20ns while the #3 of the
// top is 3ns. §20.3.3: the report task of the top prints both $realtime
// values in its own unit of 1ns.

`timescale 10ns / 1ns

module child;
  initial #2 test_instantiated_module_time_unit.report("child, #2 in units of 10ns");
endmodule

`timescale 1ns / 1ps

module test_instantiated_module_time_unit;
  task report(string what);
    $display("%0.1f ns: %s", $realtime, what);
  endtask

  child c();

  initial #3 report("top, #3 in units of 1ns");
endmodule
