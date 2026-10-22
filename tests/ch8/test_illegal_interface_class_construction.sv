/*
:name: test_illegal_interface_class_construction
:description: An interface class handle cannot construct an interface class object (IEEE 1800-2023 Section 8.26.5)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: new attempts to construct an interface class object
:expected_stderr_regex: test_illegal_interface_class_construction\.sv:(?:21)(?::|\s)
*/
// IEEE 1800-2023 8.26.5: Interface classes describe required methods but have
// no constructible objects, even when they contain no methods.
// Oracle checks: Icarus Verilog 13.0 rejects at a different error site.

module test_illegal_interface_class_construction;
  interface class api; endclass
  api handle;
  initial handle = new; // illegal
endmodule
