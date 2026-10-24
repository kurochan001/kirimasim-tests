/*
:name: test_illegal_instance_constant_assigned_twice
:description: an instance constant may be assigned only once in the constructor, so a second assignment there is illegal (IEEE 1800-2023 Section 8.19)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.19
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance constant k is assigned a second time in the constructor
:expected_stderr_regex: test_illegal_instance_constant_assigned_twice\.sv:24:
*/
// IEEE 1800-2023 §8.19: an instance constant, a const property without an
// initial value, can be assigned at run time, but only once, in the
// constructor of its class. The first assignment to k in new is legal; the
// second one is not.
// The release Verilator 5.052 accepts the design.

class test_illegal_instance_constant_assigned_twice_c;
  const int k;
  function new(int n);
    k = n;
    k = n + 1;   // illegal: second assignment to the instance constant
  endfunction
endclass

module test_illegal_instance_constant_assigned_twice;
  test_illegal_instance_constant_assigned_twice_c c = new(3);
  initial $display("k=%0d", c.k);
endmodule
