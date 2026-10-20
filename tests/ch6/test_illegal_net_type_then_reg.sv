/*
:name: test_illegal_net_type_then_reg
:description: A net type keyword cannot be followed directly by the keyword reg in a declaration (IEEE 1800-2023 Section 6.7.1)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the declaration writes reg right after the net type wire
:expected_stderr_regex: test_illegal_net_type_then_reg\.sv:19:
*/
// IEEE 1800-2023 §6.7.1: in a net or port declaration, a net type keyword shall
// not be followed directly by reg; with other words in between, such as a
// range, the declaration is fine.

module test_illegal_net_type_then_reg;
  wire reg flag;       // illegal: reg right after wire
endmodule
