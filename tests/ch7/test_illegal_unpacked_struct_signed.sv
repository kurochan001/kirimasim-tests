/*
:name: test_illegal_unpacked_struct_signed
:description: an unpacked structure cannot have a signing qualifier
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.2.1 7.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the unpacked structure is declared signed
:expected_stderr_regex: test_illegal_unpacked_struct_signed\.sv:18:
*/
// IEEE 1800-2023 7.2.1: the signing of unpacked structures is not allowed; a
// signing qualifier may follow struct only with packed. The marked declaration
// gives an unpacked structure signed, which a tool has to reject.

typedef struct signed { // illegal: signing on an unpacked structure
  int f1;
  logic f2;
} bad_unpacked_t;
