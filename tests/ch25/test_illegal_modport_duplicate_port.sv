/*
:name: test_illegal_modport_duplicate_port
:description: one modport list defines the same port identifier twice (IEEE 1800-2023 Section 25.5.4)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.5.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the modport list mp defines the port identifier P twice
:expected_stderr_regex: test_illegal_modport_duplicate_port\.sv:21:
*/
// Port identifiers of a modport list have their own namespace, and once
// a port identifier is defined there shall not be another port
// definition with the same name. The list defines P twice.

interface i;
  logic [7:0] r;
  modport mp (input .P(r[3:0]),
              output .P(r[7:4]));   // illegal: P defined twice
endinterface

module t;
  i u();
endmodule
