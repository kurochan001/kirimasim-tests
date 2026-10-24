/*
:name: test_illegal_class_method_static_lifetime
:description: a class method cannot be declared with a static lifetime, unlike a static method (IEEE 1800-2023 Section 8.6)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.6 8.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the method bad_count of counter_c is declared with the static lifetime
:expected_stderr_regex: test_illegal_class_method_static_lifetime\.sv:34:
*/
// IEEE 1800-2023 §8.6: the methods of a class have automatic lifetime, and a
// class method declared with a static lifetime is illegal. A static method
// (8.10), declared with static before function, is another thing and is
// legal; so is a method declared with the automatic lifetime. bad_count has
// static between function and its return type, the lifetime.
// Icarus Verilog 13.0 reports this error without a file and line, so the runner
// cannot match it.

class counter_c;
  int n;

  static function int unit();
    return 1;
  endfunction

  function automatic int bump();
    n = n + unit();
    return n;
  endfunction

  function static int bad_count();   // illegal: static lifetime of a method
    return 2;
  endfunction
endclass

module test_illegal_class_method_static_lifetime;
  counter_c c = new;
  initial $display("%0d", c.bump());
endmodule
