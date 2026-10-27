/*
:name: test_ch9_extra_specparam_delay
:description: a procedural delay control may take its value from a specparam, and the delay advances time by that value (IEEE 1800-2023 Section 9.4.1)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ch9_extra_specparam_delay.expected
*/
// IEEE 1800-2023 §9.4.1: the delay_value of a procedural delay control may be
// a specparam. D is 3 in this module, so #(D) suspends the initial procedure
// until time 3, and $time then reads 3. A tool that evaluated D as 0 would
// print delay_honored=0; a tool that did not accept a specparam in a delay
// would not compile the design.
//
// The second sentence of 9.4.1, that an SDF annotation overrides the value
// and makes the delay expression be reevaluated, needs an SDF file and is
// not exercised here.

`timescale 1ns/1ns

module test_ch9_extra_specparam_delay;
  specparam D = 3;
  int at = -1;

  initial begin
    #(D) at = $time;
    $display("delay_honored=%0d", at == 3);
    $finish;
  end
endmodule
