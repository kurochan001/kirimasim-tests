/*
:name: test_illegal_const_static_instance_constant
:description: an instance constant, a const class property without an initial value, cannot be declared static, written here as const static (IEEE 1800-2023 Section 8.19)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.19 8.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the const property limit has no initial value, so it is an instance constant, and it is declared static
:expected_stderr_regex: test_illegal_const_static_instance_constant\.sv:(24|25|28):
*/
// IEEE 1800-2023 §8.19: a global constant has its value in its declaration
// and may be static, as unit is; an instance constant has no initial value
// and is assigned in the constructor, so it cannot be static. limit is such a
// constant declared static. A tool can report the declaration, the
// assignment in the constructor, or the class that holds them.
// Icarus Verilog 13.0 reports the class as missing the initialization of its
// const properties, but it does so for every const static property, also the
// legal unit, so its error does not count. The release Verilator 5.052
// accepts the design.

class test_illegal_const_static_instance_constant_c;
  const static int limit;   // illegal: an instance constant declared static
  const static int unit = 4;
  function new(int n);
    limit = n;
  endfunction
endclass

module test_illegal_const_static_instance_constant;
  test_illegal_const_static_instance_constant_c c = new(4);
  initial $display("limit=%0d unit=%0d", c.limit, c.unit);
endmodule
