/*
:name: test_illegal_handle_arithmetic
:description: an object handle does not support arithmetic operations such as increment
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the increment operator is applied to an object handle
:expected_stderr_regex: test_illegal_handle_arithmetic\.sv:27:
*/
// IEEE 1800-2023 8.4: object handles do not act as C pointers; only equality,
// inequality, case equality, case inequality, the conditional operator,
// assignment of a compatible object and assignment of null are valid on them.
// The marked increment of an object handle is illegal.

class counter_h;
endclass

module test_illegal_handle_arithmetic;
  counter_h c;

  initial begin
    c = new;
    c++; // illegal: arithmetic on an object handle
  end
endmodule
