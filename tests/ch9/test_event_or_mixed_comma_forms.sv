/*
:name: test_event_or_mixed_comma_forms
:description: Mixed comma and or sensitivity forms wake on the same separate input transitions (IEEE 1800-2023 Section 9.4.2.1)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_event_or_mixed_comma_forms.expected
*/
// IEEE 1800-2023 9.4.2.1: Sensitivity syntax is equivalent for comma and event
// or; transitions occur in distinct time steps so counts do not depend on
// scheduler ordering.
// Oracle checks: The 5.052 release does not reproduce the clause-derived
// output.

module test_event_or_mixed_comma_forms;
  bit a, b, c;
  int comma_count, mixed_count;
  always @(a, b, c) comma_count++;
  always @(a or b, c) mixed_count++;
  initial begin
    #1 a = 1; #1 b = 1; #1 c = 1;
    #1 a = 0;
    #1 $display("counts=%0d,%0d", comma_count, mixed_count);
    $finish;
  end
endmodule
