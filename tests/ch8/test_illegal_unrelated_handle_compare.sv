/*
:name: test_illegal_unrelated_handle_compare
:description: object handles of unrelated classes cannot be compared for equality
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the equality operands are handles of unrelated classes
:expected_stderr_regex: test_illegal_unrelated_handle_compare\.sv:32:
*/
// IEEE 1800-2023 8.4: equality and inequality on object handles require the
// other operand to be another object or null, and one object type shall be
// assignment compatible with the other. The two classes in this design are
// unrelated, so the marked comparison is illegal.

class handle_a;
endclass

class handle_b;
endclass

module test_illegal_unrelated_handle_compare;
  handle_a a;
  handle_b b;

  initial begin
    a = new;
    b = new;
    if (a == b) $display("equal"); // illegal: unrelated object types
  end
endmodule
