/*
:name: test_illegal_class_method_virtual_twice
:description: the virtual qualifier can appear only once in a class method declaration (IEEE 1800-2023 Section 8.3)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the method g of the class is declared with virtual twice
:expected_stderr_regex: test_illegal_class_method_virtual_twice\.sv:27:
*/
// IEEE 1800-2023 §8.3 (Syntax 8-1, footnote 10): in any one declaration only
// one of protected and local is allowed, only one of rand and randc is allowed,
// and static and virtual can each appear only once.
// The class declares the virtual method f with virtual once, and the legal
// design prints what it returns: 1. The method g is declared virtual virtual.
// Icarus Verilog 13.0 does not accept two method qualifiers in one declaration,
// the legal protected virtual included, so its syntax error on the line of g
// does not count. The 5.052 release accepts the design.

class test_illegal_class_method_virtual_twice_c;
  virtual function int f();
    return 1;
  endfunction
  virtual virtual function int g();   // illegal: virtual twice
    return 2;
  endfunction
endclass

module test_illegal_class_method_virtual_twice;
  test_illegal_class_method_virtual_twice_c o;
  initial begin
    o = new;
    $display("%0d", o.f());
  end
endmodule
