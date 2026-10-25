/*
:name: test_illegal_weak_reference_non_class
:description: The parameter of weak_reference has to be a class type (IEEE 1800-2023 Section 8.30.1)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.30.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: weak_reference is specialized with int
:expected_stderr_regex: test_illegal_weak_reference_non_class\.sv:20:
*/
// IEEE 1800-2023 §8.30.1: the type parameter T of weak_reference#(T) shall be a
// class type; any other type is a compile error. The errors that Icarus Verilog
// 13.0 and Verilator 5.052 report at this line do not count: they come from not
// knowing weak_reference.

module test_illegal_weak_reference_non_class;
  weak_reference #(int) w;   // illegal: int is no class type
endmodule
