/*
:name: test_illegal_static_method_uses_property
:description: A static method cannot use a non-static property of its class (IEEE 1800-2023 Section 8.10)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the static function get reads the non-static property count
:expected_stderr_regex: test_illegal_static_method_uses_property\.sv:21:
*/
// IEEE 1800-2023 §8.10: the body of a static method cannot refer to non-static
// members or to this, since it runs without an object.

module test_illegal_static_method_uses_property;
  class counter;
    int count;
    static function int get();
      return count;    // illegal: count is not static
    endfunction
  endclass
endmodule
