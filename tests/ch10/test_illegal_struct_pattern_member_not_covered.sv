/*
:name: test_illegal_struct_pattern_member_not_covered
:description: every member of a structure has to be covered by a member key, a type key, a default key or a position of a structure assignment pattern (IEEE 1800-2023 Section 10.9.2)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.9.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the structure assignment pattern names the members a and b but gives no value for the member c
:expected_stderr_regex: test_illegal_struct_pattern_member_not_covered\.sv:34:
*/
// IEEE 1800-2023 §10.9.2: every member of the structure shall be covered by
// one of the matching rules (member name, type key, default). The patterns
// with a default, with a type key that matches all three int members, and
// with one value per position are legal; the last pattern leaves c without a
// value.
// Icarus Verilog 13.0 does not support unpacked structures, so its errors do
// not count.

module test_illegal_struct_pattern_member_not_covered;
  typedef struct {
    int a;
    int b;
    int c;
  } abc_t;
  abc_t s;

  initial begin
    s = '{a:1, default:0};
    s = '{int:4};
    s = '{1, 2, 3};
    s = '{a:1, b:2};   // illegal: no value for the member c
    $display("%p", s);
  end
endmodule
