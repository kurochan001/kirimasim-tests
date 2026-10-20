/*
:name: test_two_state_operations
:description: Operators on 2-state values, or a mix of 2-state and 4-state values, give what 4-state operands would give, so all-2-state operands give a 2-state result except where the operator itself gives x, as for a division by zero (IEEE 1800-2023 Section 11.3.4)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.4 11.4.2 6.11.2 20.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_two_state_operations.expected
*/
// IEEE 1800-2023 §11.3.4: an operator on 2-state values, or on a mix of
// 2-state and 4-state values, gives the result for 4-state values. A 4-state
// or-mask with an x and a z bit or-ed with an int gives 111x, which becomes
// 1110 when stored in a 2-state int (6.11.2). With only 2-state operands the
// result is 2-state, except where an operator gives x for 2-state values: n /
// zero is x (11.4.2), which $isunknown (20.9) shows, which an integer keeps and
// an int stores as 0.

module test_two_state_operations;
  int n = 6, zero = 0;
  int mix, d2;
  integer d4;

  initial begin
    mix = 4'b1x0z | n;
    d2 = n / zero;
    d4 = n / zero;
    $display("mix=%0d sum unknown: %0d quotient unknown: %0d", mix, $isunknown(n + n),
             $isunknown(n / zero));
    $display("into int: %0d, into integer: %0d", d2, d4);
  end
endmodule
