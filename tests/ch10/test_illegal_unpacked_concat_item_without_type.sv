/*
:name: test_illegal_unpacked_concat_item_without_type
:description: an item of an unpacked array concatenation needs a self-determined type, so an assignment pattern without a type cannot be one (IEEE 1800-2023 Section 10.10)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the assignment pattern '{b, c}, which has no self-determined type, is an item of an unpacked array concatenation
:expected_stderr_regex: test_illegal_unpacked_concat_item_without_type\.sv:30:
*/
// IEEE 1800-2023 §10.10: an unpacked array concatenation shall not have an
// item that has no self-determined type. An assignment pattern has no
// self-determined type (10.9), while an assignment pattern expression with a
// type prefix has one. {a2, pair_t'{b, c}} is legal; {a2, '{b, c}} is not.
// Icarus Verilog 13.0 gives a syntax error, as its parser takes no assignment
// pattern inside braces (the grammar allows one there), and the 5.052
// release of Verilator stops with an internal error, so neither counts.

module test_illegal_unpacked_concat_item_without_type;
  typedef int pair_t [2];
  int a2 [2] = '{1, 2};
  int a4 [4];
  int b = 3, c = 4;

  initial begin
    a4 = {a2, pair_t'{b, c}};
    a4 = {a2, '{b, c}};   // illegal: the item '{b, c} has no self-determined type
    $display("%p", a4);
  end
endmodule
