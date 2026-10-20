/*
:name: test_illegal_localparam_instance_override
:description: A parameter value assignment of an instance cannot name a local parameter (IEEE 1800-2023 Section 6.20.4)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.4 23.10.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance u assigns a value to the local parameter W by name
:expected_stderr_regex: test_illegal_localparam_instance_override\.sv:23:
*/
// IEEE 1800-2023 §6.20.4: a local parameter cannot be changed by the parameter
// value assignment of an instance (23.10.2). The instance below names W, which
// sub declares with localparam.

module sub;
  localparam int W = 4;
endmodule

module test_illegal_localparam_instance_override;
  sub #(.W(8)) u();    // illegal: W is a local parameter
endmodule
