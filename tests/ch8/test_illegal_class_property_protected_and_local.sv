/*
:name: test_illegal_class_property_protected_and_local
:description: a class property declaration cannot have both the protected and the local qualifier (IEEE 1800-2023 Section 8.3)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the property both of the class is declared with both protected and local
:expected_stderr_regex: test_illegal_class_property_protected_and_local\.sv:29:
*/
// IEEE 1800-2023 §8.3 (Syntax 8-1, footnote 10): in any one declaration only
// one of protected and local is allowed, only one of rand and randc is allowed,
// and static and virtual can each appear only once.
// The class declares a protected, a local and a static protected property, each
// with one access qualifier, and a method that adds them; the legal design
// prints the sum: 6. The property both is declared protected local.
// Icarus Verilog 13.0 and the 5.052 release accept the design.

class test_illegal_class_property_protected_and_local_c;
  protected int p = 1;
  local int l = 2;
  static protected int sp = 3;
  function int sum();
    return p + l + sp;
  endfunction
  protected local int both;   // illegal: protected and local together
endclass

module test_illegal_class_property_protected_and_local;
  test_illegal_class_property_protected_and_local_c o;
  initial begin
    o = new;
    $display("%0d", o.sum());
  end
endmodule
