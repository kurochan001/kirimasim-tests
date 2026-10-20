/*
:name: test_specify_specparam_delays
:description: Path delays can be given by specify parameters, declared in the specify block or in the module before use, also as expressions of other specify parameters (IEEE 1800-2023 Section 6.20.5)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.5 30.3 30.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_specparam_delays.expected
*/
// IEEE 1800-2023 §6.20.5, §30.3: specparam declares specify parameters, meant
// for timing and delay values; one declared outside a specify block has to be
// declared before it is used, and one may be defined from others. tBase is
// declared in the module, tRise and tFall in the specify block, tFall as
// tBase + 2. The path from a to y uses them as its rise and fall delays
// (30.5.1): y rises 3 and falls 6 time units after a changes.

`timescale 1ns/1ns

module test_specify_specparam_delays_buf(output y, input a);
  specparam tBase = 4;

  buf (y, a);
  specify
    specparam tRise = 3, tFall = tBase + 2;
    (a => y) = (tRise, tFall);
  endspecify
endmodule

module test_specify_specparam_delays;
  reg a = 0;
  wire y;

  test_specify_specparam_delays_buf u(y, a);

  always @(y) if ($time >= 10) $display("%0d: y=%b", $time, y);

  initial begin
    #10 a = 1;              // y at 13
    #10 a = 0;              // y at 26
    #10 $finish;
  end
endmodule
