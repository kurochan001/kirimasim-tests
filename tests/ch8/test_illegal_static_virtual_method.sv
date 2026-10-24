/*
:name: test_illegal_static_virtual_method
:description: a static class method cannot be declared virtual (IEEE 1800-2023 Section 8.10)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the static method count is also declared virtual
:expected_stderr_regex: test_illegal_static_virtual_method\.sv:28:
*/
// IEEE 1800-2023 §8.10: a method can be static or virtual, but static methods
// cannot be virtual. The class has a legal static method and a legal virtual
// method, and one method that is declared both.
// Icarus Verilog 13.0 reports a syntax error on that line, although the
// grammar allows the two qualifiers together, so its error does not count.

class test_illegal_static_virtual_method_c;
  static int n = 0;
  static function int next();
    return ++n;
  endfunction
  virtual function int get();
    return n;
  endfunction
  static virtual function int count();   // illegal: static and virtual
    return n;
  endfunction
endclass

module test_illegal_static_virtual_method;
  initial $display("next=%0d", test_illegal_static_virtual_method_c::next());
endmodule
