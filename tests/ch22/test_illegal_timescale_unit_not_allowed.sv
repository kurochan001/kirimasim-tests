/*
:name: test_illegal_timescale_unit_not_allowed
:description: The unit strings of `timescale can only be s, ms, us, ns, ps and fs, so a precision written with the unit xs is an error (IEEE 1800-2023 Section 22.7)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.7
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the time precision of the `timescale directive uses the unit string xs, which is not s, ms, us, ns, ps or fs
:expected_stderr_regex: test_illegal_timescale_unit_not_allowed\.sv:19:
*/
// IEEE 1800-2023 §22.7: the character strings in the arguments of
// `timescale are units of measurement, and the only valid ones are s, ms,
// us, ns, ps and fs. The precision below has the factor 1, which is valid,
// and the unit xs, which is not.

`timescale 1ns / 1xs  // illegal: xs is not a valid unit

module test_illegal_timescale_unit_not_allowed;
  initial #1 $display("done");
endmodule
