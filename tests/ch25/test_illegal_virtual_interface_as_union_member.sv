/*
:name: test_illegal_virtual_interface_as_union_member
:description: A virtual interface cannot be a member of a union, while it can be a member of a structure (IEEE 1800-2023 Section 25.9)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the union type vpu_union_t has the member vi of a virtual interface type
:expected_stderr_regex: test_illegal_virtual_interface_as_union_member\.sv:33:
*/
// IEEE 1800-2023 §25.9: virtual interfaces shall not be used as ports,
// interface items, or members of unions. The unpacked structure type
// vpu_struct_t has a virtual interface member, which the rule does not
// forbid; the unpacked union type vpu_union_t has one.
// Icarus Verilog 13.0 does not support virtual interfaces and reports
// syntax errors on their declarations, which do not count. The 5.052
// release of Verilator accepts the declaration and then fails to compile
// the C++ it generates.

interface vpu_if;
  logic d;
endinterface

typedef struct {
  virtual vpu_if vi;
  int n;
} vpu_struct_t;

typedef union {
  virtual vpu_if vi;   // illegal: a virtual interface as a union member
  int n;
} vpu_union_t;

module test_illegal_virtual_interface_as_union_member;
  vpu_if bus ();
  vpu_struct_t s;
  initial begin
    s.vi = bus;
    s.n = 1;
    $display("%0d", s.n);
  end
endmodule
