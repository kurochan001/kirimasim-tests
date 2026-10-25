/*
:name: test_illegal_vectored_without_packed_dimension
:description: A net declared vectored needs at least one packed dimension (IEEE 1800-2023 Section 10.3)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the net v is declared vectored without any packed dimension
:expected_stderr_regex: test_illegal_vectored_without_packed_dimension\.sv:22:
*/
// IEEE 1800-2023 §10.3 (Syntax 10-1, footnote 16): when the vectored or
// scalared keyword is used in a net declaration, the declaration shall have
// at least one packed dimension. v below is vectored and scalar; ok is the
// legal form.
// The 5.052 release of Verilator accepts the design.

module test_illegal_vectored_without_packed_dimension;
  wire vectored [3:0] ok;
  wire vectored v;   // illegal: vectored without a packed dimension
endmodule
