/*
:name: test_illegal_assoc_union_real_key
:description: an associative index type cannot be an unpacked union that contains a real member
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.8.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the associative index type is an unpacked union with a real member
:expected_stderr_regex: test_illegal_assoc_union_real_key\.sv:26:
*/
// IEEE 1800-2023 7.8.5: an associative index type cannot be real or
// shortreal, and a type that contains either is also forbidden. The union
// key_t has one int and one real member, so it contains a real and cannot be
// the index type of entries. Neither recorded release rejects the declaration
// for this reason; the expected result follows the clause.

typedef union {
  int i;
  real r;
} key_t;

module test_illegal_assoc_union_real_key;
  int entries[key_t];   // illegal: the index type contains a real
endmodule
