/*
:name: test_illegal_uwire_overlapping_bit_drivers
:description: Two continuous assignments to parts of a uwire vector that share one bit are an error, as every bit of a uwire can have only one driver (IEEE 1800-2023 Section 6.6.2)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: bit 1 of the uwire w is driven by both continuous assignments
:expected_stderr_regex: test_illegal_uwire_overlapping_bit_drivers\.sv:(25|26):
*/
// IEEE 1800-2023 §6.6.2: a uwire is an unresolved net; it is an error to
// connect any bit of it to more than one driver. The two assignments below
// drive w[1:0] and w[3:1]: bits 0, 2 and 3 have one driver each, which would
// be legal on its own, but bit 1 has two, so the design is illegal. A tool can
// report either assignment.
// Oracle checks: the 5.052 release accepts the design.

module test_illegal_uwire_overlapping_bit_drivers;
  logic [1:0] a = 2'b01;
  logic [2:0] b = 3'b101;
  uwire [3:0] w;
  assign w[1:0] = a;   // illegal: drives bits 1 and 0 of w
  assign w[3:1] = b;   // illegal: and bit 1 again
endmodule
