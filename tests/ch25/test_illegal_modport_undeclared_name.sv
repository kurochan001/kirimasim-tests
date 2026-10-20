/*
:name: test_illegal_modport_undeclared_name
:description: A modport can name only signals declared in its own interface (IEEE 1800-2023 Section 25.5)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the modport names e, which the interface does not declare
:expected_stderr_regex: test_illegal_modport_undeclared_name\.sv:20:
*/
// IEEE 1800-2023 §25.5: the names in a modport are declared by the same
// interface, and a modport does not declare new ports implicitly. The interface
// declares d but not e.

interface link;
  logic d;
  modport m(input d, output e);   // illegal: e is not declared
endinterface

module test_illegal_modport_undeclared_name;
  link l();
endmodule
