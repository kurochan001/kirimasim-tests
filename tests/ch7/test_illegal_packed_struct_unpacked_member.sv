/*
:name: test_illegal_packed_struct_unpacked_member
:description: A packed structure cannot have a member that is an unpacked array (IEEE 1800-2023 Section 7.2.1)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.2.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the packed structure has an unpacked array member
:expected_stderr_regex: test_illegal_packed_struct_unpacked_member\.sv:(19|21):
*/
// IEEE 1800-2023 §7.2.1: the members of a packed structure can only be of
// packed types and the integer types; an unpacked array is neither. A tool can
// report the member or the structure that holds it.

module test_illegal_packed_struct_unpacked_member;
  typedef struct packed {   // illegal: (the struct that holds it)
    logic [3:0] tag;
    byte data [2];     // illegal: an unpacked array in a packed struct
  } frame_t;
  frame_t f;
endmodule
