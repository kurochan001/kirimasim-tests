/*
:name: test_illegal_interconnect_explicit_type
:description: an interconnect declaration with an explicit data type is illegal
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.7.1 6.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an interconnect net shall have no data type
:expected_stderr_regex: test_illegal_interconnect_explicit_type\.sv:20:
*/
// IEEE 1800-2023 6.7.1: a net declared as interconnect shall have no data
// type, although packed and unpacked dimensions are allowed. This design
// gives the interconnect an explicit logic type on the marked line, which a
// tool has to reject.

module test_illegal_interconnect_explicit_type;
  interconnect logic [3:0] w; // illegal: explicit data type
  initial $display("unreachable %0d", $bits(w));
endmodule
