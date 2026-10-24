/*
:name: test_illegal_parameter_in_specify_block
:description: A parameter cannot be declared inside a specify block, where only specparams are declared (IEEE 1800-2023 Section 6.20.5)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.5 30.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a parameter declaration appears inside a specify block
:expected_stderr_regex: test_illegal_parameter_in_specify_block\.sv:23:
*/
// IEEE 1800-2023 §6.20.5, Table 6-11: parameters are declared outside
// specify blocks; inside a specify block (§30.3) only specparams are
// declared. The path delay itself is legal.
// In Verilator 5.052 the construct is ignored with a warning that it is
// not supported.

module test_illegal_parameter_in_specify_block(output y, input a);
  buf (y, a);
  specify
    parameter tP = 2;    // illegal: parameter inside a specify block
    (a => y) = 1;
  endspecify
endmodule
