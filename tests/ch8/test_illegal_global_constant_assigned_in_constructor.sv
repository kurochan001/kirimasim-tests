/*
:name: test_illegal_global_constant_assigned_in_constructor
:description: A class constant with an initial value cannot be assigned, not even in the constructor (IEEE 1800-2023 Section 8.19)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.19
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the constructor assigns a const property that has an initial value
:expected_stderr_regex: test_illegal_global_constant_assigned_in_constructor\.sv:22:
*/
// IEEE 1800-2023 §8.19: a global constant, a const property with an initial
// value in its declaration, cannot be assigned anywhere other than in that
// declaration; only an instance constant is assigned in the constructor.
// The design is accepted by Verilator 5.052 (docs/simulator-differences.md).

class test_illegal_global_constant_assigned_in_constructor_c;
  const int limit = 16;
  function new(int n);
    limit = n;   // illegal: a global constant is assigned
  endfunction
endclass

module test_illegal_global_constant_assigned_in_constructor;
  test_illegal_global_constant_assigned_in_constructor_c c = new(4);
  initial $display("limit=%0d", c.limit);
endmodule
