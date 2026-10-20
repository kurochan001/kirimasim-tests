/*
:name: test_illegal_packed_struct_real_member
:description: A packed structure cannot have a real member (IEEE 1800-2023 Section 7.2.1)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.2.1 6.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the packed structure has a member of type real
:expected_stderr_regex: test_illegal_packed_struct_real_member\.sv:(19|21):
*/
// IEEE 1800-2023 §7.2.1: only packed types and the integer types can be members
// of a packed structure, and real is neither (6.12). A tool can report the
// member or the structure that holds it.

module test_illegal_packed_struct_real_member;
  typedef struct packed {   // illegal: (the struct that holds it)
    logic [7:0] id;
    real value;        // illegal: a real in a packed struct
  } sample_t;
  sample_t s;
endmodule
