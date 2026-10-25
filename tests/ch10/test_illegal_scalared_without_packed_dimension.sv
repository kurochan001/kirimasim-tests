/*
:name: test_illegal_scalared_without_packed_dimension
:description: A net declared scalared needs at least one packed dimension (IEEE 1800-2023 Section 10.3)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the net s is declared scalared without any packed dimension
:expected_stderr_regex: test_illegal_scalared_without_packed_dimension\.sv:22:
*/
// IEEE 1800-2023 §10.3 (Syntax 10-1, footnote 16): when the vectored or
// scalared keyword is used in a net declaration, the declaration shall have
// at least one packed dimension. s below is scalared and scalar; ok is the
// legal form.
// The 5.052 release of Verilator accepts the design.

module test_illegal_scalared_without_packed_dimension;
  wire scalared [3:0] ok;
  wire scalared s;   // illegal: scalared without a packed dimension
endmodule
