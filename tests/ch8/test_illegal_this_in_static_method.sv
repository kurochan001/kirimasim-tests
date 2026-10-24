/*
:name: test_illegal_this_in_static_method
:description: the this handle cannot be used in a static class method (IEEE 1800-2023 Section 8.11)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.11 8.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the static method is_set uses the this handle
:expected_stderr_regex: test_illegal_this_in_static_method\.sv:29:
*/
// IEEE 1800-2023 §8.11: this may only be used as type(this) or within
// non-static class methods, constraints, inlined constraint methods and
// covergroups embedded in classes; elsewhere it is an error. §8.10: a static
// method has no this handle. The non-static method uses this legally; the
// static method compares this with null, which touches no property, so the
// only error is the use of this.
// Icarus Verilog 13.0 does not parse the call of a static method through the
// class scope.

class test_illegal_this_in_static_method_c;
  int x;
  function bit me_set();
    return this != null;
  endfunction
  static function bit is_set();
    return this != null;   // illegal: this in a static method
  endfunction
endclass

module test_illegal_this_in_static_method;
  initial $display("set=%0d", test_illegal_this_in_static_method_c::is_set());
endmodule
