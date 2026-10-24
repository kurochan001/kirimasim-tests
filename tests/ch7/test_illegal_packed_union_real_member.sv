/*
:name: test_illegal_packed_union_real_member
:description: a packed union cannot have a member of a non-integral type such as real (IEEE 1800-2023 Section 7.3.1)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.3.1 6.11.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a packed union has a member of type real, which is not an integral type
:expected_stderr_regex: test_illegal_packed_union_real_member\.sv:(20|22):
*/
// IEEE 1800-2023 §7.3.1: the members of a packed union shall all be of
// integral data types, and real is not one (§6.11.1). The other member is a
// 64-bit vector, so the union breaks no other rule. A tool can report the
// member or the union that holds it.

module test_illegal_packed_union_real_member;
  typedef union packed {   // illegal: (the union that holds it)
    logic [63:0] raw;
    real value;   // illegal: a real member in a packed union
  } u_t;
  u_t u;
endmodule
