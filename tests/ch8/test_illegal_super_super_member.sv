/*
:name: test_illegal_super_super_member
:description: super reaches only the class one level up; super.super to reach the class above it is illegal (IEEE 1800-2023 Section 8.15)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.15
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the method far of c_c uses super.super.count to reach the class two levels up
:expected_stderr_regex: test_illegal_super_super_member\.sv:34:
*/
// IEEE 1800-2023 §8.15: super accesses members declared in, or inherited by,
// the class one level up; there is no way to reach higher, so super.super is
// not allowed. near uses super.count legally; far uses super.super.count.
// The grammar has no super.super, so a syntax error on that line is a right
// rejection.

class a_c;
  int count = 1;
endclass

class b_c extends a_c;
  int count = 2;
endclass

class c_c extends b_c;
  int count = 3;
  function int near();
    return super.count;
  endfunction
  function int far();
    return super.super.count;   // illegal: super.super
  endfunction
endclass

module test_illegal_super_super_member;
  c_c c = new;
  initial $display("near=%0d", c.near());
endmodule
