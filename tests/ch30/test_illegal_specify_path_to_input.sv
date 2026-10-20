/*
:name: test_illegal_specify_path_to_input
:description: The destination of a module path cannot be an input port (IEEE 1800-2023 Section 30.4.1)
:tags: ch30
:type: elaboration
:lrm: 1800-2023 30.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module path ends at the input port b
:expected_stderr_regex: test_illegal_specify_path_to_input\.sv:21:
*/
// IEEE 1800-2023 §30.4.1: the destination of a module path is a net or variable
// connected to an output or inout port. b is an input, so (a => b) is illegal.

module sub(output y, input a, input b);
  and (y, a, b);
  specify
    (a => y) = 2;
    (a => b) = 3;      // illegal: b is an input port
  endspecify
endmodule

module test_illegal_specify_path_to_input;
  reg a = 0, b = 0;
  wire y;
  sub u(y, a, b);
endmodule
