/*
:name: test_illegal_overlapping_continuous_assigns
:description: Two continuous assignments to overlapping bits of a variable are illegal, even when other bits are written once (IEEE 1800-2023 Section 6.5)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.5 11.5.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: two continuous assignments write bit 1 of the variable v
:expected_stderr_regex: test_illegal_overlapping_continuous_assigns\.sv:(20|21):
*/
// IEEE 1800-2023 §6.5: a variable can have only one continuous assignment to
// each of its bits. The two assignments below write v[1:0] and v[1], which
// share bit 1, so the design is illegal; a tool can report either.

module test_illegal_overlapping_continuous_assigns;
  logic [3:0] v;
  assign v[1:0] = 2'b01;   // illegal: writes bits 1 and 0 of v
  assign v[1] = 1'b0;      // illegal: and bit 1 again
  assign v[3:2] = 2'b10;
endmodule
