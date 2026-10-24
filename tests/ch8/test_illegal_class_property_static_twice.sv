/*
:name: test_illegal_class_property_static_twice
:description: the static qualifier can appear only once in a class property declaration (IEEE 1800-2023 Section 8.3)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the property both of the class is declared with static twice
:expected_stderr_regex: test_illegal_class_property_static_twice\.sv:24:
*/
// IEEE 1800-2023 §8.3 (Syntax 8-1, footnote 10): in any one declaration only
// one of protected and local is allowed, only one of rand and randc is allowed,
// and static and virtual can each appear only once.
// The class declares the static property count once with static, and the legal
// design prints it through an object handle: 5. The property both is declared
// static static.
// Icarus Verilog 13.0 and the 5.052 release accept the design.

class test_illegal_class_property_static_twice_c;
  static int count = 5;
  static static int both;   // illegal: static twice
endclass

module test_illegal_class_property_static_twice;
  test_illegal_class_property_static_twice_c o;
  initial begin
    o = new;
    $display("%0d", o.count);
  end
endmodule
