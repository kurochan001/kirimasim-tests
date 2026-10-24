/*
:name: test_illegal_union_holding_struct_member_default
:description: a member of an unpacked structure that contains a union cannot have an individual default member value (IEEE 1800-2023 Section 7.2.2)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the member a of the unpacked structure bad_t, which also has a union member, has the default value 1
:expected_stderr_regex: test_illegal_union_holding_struct_member_default\.sv:28:
*/
// IEEE 1800-2023 §7.2.2: members of a structure type can be given default
// values with an initial assignment in their declaration, but members of
// unpacked structures that contain a union, and of packed structures, shall
// not. The unpacked structure ok_t, which has no union, gives its member a
// a default; bad_t has the same members plus a packed union member, and
// gives a the same default.
// Icarus Verilog 13.0 does not support unpacked structures and reports that
// as not supported. The 5.052 release accepts the default in bad_t.

module test_illegal_union_holding_struct_member_default;
  typedef union packed { bit [3:0] p; bit [3:0] q; } u_t;
  typedef struct { int a = 1; int b; } ok_t;
  ok_t o;
  initial $display("%0d", o.a);
  typedef struct { u_t u; int a = 1; int b; } bad_t;   // illegal: default with a union
endmodule
