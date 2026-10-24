/*
:name: test_illegal_packed_struct_member_default
:description: a member of a packed structure cannot have an individual default member value, while a member of an unpacked structure can (IEEE 1800-2023 Section 7.2.2)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.2.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the member count of the packed structure bad_t has the default value 4'd3
:expected_stderr_regex: test_illegal_packed_struct_member_default\.sv:27:
*/
// IEEE 1800-2023 §7.2.2: members of a structure type can be given default
// values with an initial assignment in their declaration, but members of
// packed structures, and of unpacked structures that contain a union, shall
// not. The unpacked structure ok_t gives its member a a default, which the
// legal design prints for a variable without an initializer; the packed
// structure bad_t gives its member count a default.
// Icarus Verilog 13.0 does not support unpacked structures and reports that
// as not supported.

module test_illegal_packed_struct_member_default;
  typedef struct { int a = 7; int b; } ok_t;
  ok_t o;
  initial $display("%0d", o.a);
  typedef struct packed { bit [3:0] count = 4'd3; bit [3:0] flags; } bad_t;   // illegal: default
endmodule
