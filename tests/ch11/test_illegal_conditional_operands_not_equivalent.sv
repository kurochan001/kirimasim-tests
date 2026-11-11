/*
:name: test_illegal_conditional_operands_not_equivalent
:description: when the operands of the conditional operator are neither integral, real nor class types, they have to be of equivalent types (IEEE 1800-2023 Section 11.4.11)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.4.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the second and third operands of the conditional operator are an unpacked array of int and an unpacked array of byte, which are not equivalent types
:expected_stderr_regex: test_illegal_conditional_operands_not_equivalent\.sv:39:
*/
// IEEE 1800-2023 §11.4.11: for operand types not covered by the rules for
// integral, real and class types, the types of the second and third operands
// shall be equivalent (6.22.2). Two arrays of three int, a real and an int,
// and a class handle and null are legal operand pairs; an array of three int
// and an array of three byte are not equivalent.
// Icarus Verilog 13.0 also rejects the legal conditional expression of two
// int arrays, and the 5.052 release of Verilator reports an unexpected
// operation instead of the types, so neither error counts.

class obj_c;
endclass

module test_illegal_conditional_operands_not_equivalent;
  int ia [3] = '{1, 2, 3};
  int ib [3] = '{4, 5, 6};
  byte ba [3] = '{7, 8, 9};
  int res [3];
  real r;
  obj_c h = new, g;
  bit sel = 1'b1;

  initial begin
    res = sel ? ia : ib;
    r = sel ? 2.5 : 3;
    g = sel ? h : null;
    res = sel ? ia : ba;   // illegal: int[3] and byte[3] are not equivalent
    $display("%p %0.1f", res, r);
  end
endmodule
