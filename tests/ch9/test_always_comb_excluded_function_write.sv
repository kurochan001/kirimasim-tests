/*
:name: test_always_comb_excluded_function_write
:description: an expression that a function called by always_comb writes is excluded from the implicit sensitivity, so the block runs once per input change
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_comb_excluded_function_write.expected
*/
// IEEE 1800-2023 9.2.2.2.1: the implicit sensitivity of always_comb excludes
// an expression that is also written in the block or in a function it calls.
// The called function bump both reads and writes runs, and the block assigns
// its result to y. If runs contributed sensitivity, changing it would wake the
// block again in the same time step, and the block would not converge. With
// the exclusion it runs once at time zero and once for each change of a, so
// runs is 3 after the changes at 1 and 2 and y is the last value of a. The
// 5.052 release reports that its settle region does not converge; the expected
// output follows the clause.

`timescale 1ns/1ns

module test_always_comb_excluded_function_write;
  int runs = 0;
  logic a = 0, y;

  function automatic int bump();
    runs = runs + 1;
    return a;
  endfunction

  always_comb y = bump();

  initial begin
    #1 a = 1;
    #1 a = 0;
    #1 $display("runs=%0d y=%0d", runs, y);
  end
endmodule
