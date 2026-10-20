/*
:name: test_printtimescale_other_module
:description: $printtimescale with a hierarchical name reports the time unit and precision of that instance's module, which differ from the caller's (IEEE 1800-2023 Section 20.4.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.4.2 22.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_printtimescale_other_module.expected
*/
// IEEE 1800-2023 §20.4.2: without an argument $printtimescale reports the
// current scope, and with a hierarchical name the design element named; the
// line is "Time scale of (<name>) is <unit> / <precision>". The child module
// follows `timescale 10ns/1ns and the top module `timescale 1ns/1ps (22.7).

`timescale 10ns/1ns
module test_printtimescale_other_module_child;
endmodule

`timescale 1ns/1ps
module test_printtimescale_other_module;
  test_printtimescale_other_module_child c();

  initial begin
    $printtimescale;
    $printtimescale(test_printtimescale_other_module.c);
  end
endmodule
