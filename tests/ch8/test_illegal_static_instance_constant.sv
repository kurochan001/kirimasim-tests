/*
:name: test_illegal_static_instance_constant
:description: An instance constant of a class cannot be declared static (IEEE 1800-2023 Section 8.19)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.19 8.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a const property without an initial value is declared static
:expected_stderr_regex: test_illegal_static_instance_constant\.sv:22:
*/
// IEEE 1800-2023 §8.19: an instance constant, a const property assigned in the
// constructor, cannot be declared static (§8.9), since a static property would
// allow no assignment in the constructor.
// Icarus Verilog 13.0 does not parse static const properties, so its syntax
// error on that line does not count. The design is accepted by Verilator
// 5.052 (docs/simulator-differences.md).

class test_illegal_static_instance_constant_c;
  static const int size;   // illegal: an instance constant declared static
  function new(int n);
    size = n;
  endfunction
endclass

module test_illegal_static_instance_constant;
  test_illegal_static_instance_constant_c c = new(4);
  initial $display("size=%0d", c.size);
endmodule
