/*
:name: test_illegal_randc_real
:description: The solver supports singular variables of any integral or real type, but a real variable shall not be declared randc (IEEE 1800-2023 Section 18.4)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the real variable r is declared randc
:expected_stderr_regex: test_illegal_randc_real\.sv:21:
*/
// IEEE 1800-2023 §18.4: real variables can be declared rand, but real
// variables shall not be declared randc because a real range has no finite
// permutation. The declaration of r is illegal. Verilator 5.052 stops
// on the 64-bit width of a randc variable, not on its real type, so its
// error does not show the rule.

class c_randc_real;
  randc real r;   // illegal: randc real
endclass

module test_illegal_randc_real;
  c_randc_real o = new;
  initial $display("randomize=%0d", o.randomize());
endmodule
