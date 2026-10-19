/*
:name: test_checker_always_comb_output
:description: A checker drives its output arguments from an always_comb procedure, which uses current values, and from a continuous assignment (IEEE 1800-2023 Section 17.2)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.2 17.5 17.7.1 17.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_always_comb_output.expected
*/
// IEEE 1800-2023 §17.2: a checker can have output arguments, which may be given
// an initial value like a variable. §17.5: an always_comb procedure of a
// checker uses the current values of its expressions, not sampled ones.
// §17.7.1: a checker variable can also be written by a continuous assignment.
// §17.3: the actual argument of an output is written by the checker instance,
// so the module sees y follow a && b and z follow a || b.

`timescale 1ns/1ns

checker and_or_outputs(input logic a, input logic b, output logic y = 1'b0, output logic z = 1'b0);
  always_comb y = a && b;
  assign z = a || b;
endchecker

module test_checker_always_comb_output;
  logic a = 0, b = 0;
  logic y, z;

  and_or_outputs c1(a, b, y, z);

  initial begin
    #1 $display("a=0 b=0: y=%b z=%b", y, z);
    a = 1;
    #1 $display("a=1 b=0: y=%b z=%b", y, z);
    b = 1;
    #1 $display("a=1 b=1: y=%b z=%b", y, z);
    a = 0;
    b = 0;
    #1 $display("a=0 b=0: y=%b z=%b", y, z);
  end
endmodule
