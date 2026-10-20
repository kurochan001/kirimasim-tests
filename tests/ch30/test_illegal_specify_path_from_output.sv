/*
:name: test_illegal_specify_path_from_output
:description: The source of a module path cannot be an output port (IEEE 1800-2023 Section 30.4.1)
:tags: ch30
:type: elaboration
:lrm: 1800-2023 30.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module path starts at the output port y
:expected_stderr_regex: test_illegal_specify_path_from_output\.sv:23:
*/
// IEEE 1800-2023 §30.4.1: the source of a module path is a net connected to an
// input or inout port. y is an output, so (y => z) is illegal; the path from a
// to y is fine.

module sub(output y, output z, input a);
  buf (y, a);
  buf (z, y);
  specify
    (a => y) = 2;
    (y => z) = 3;      // illegal: y is an output port
  endspecify
endmodule

module test_illegal_specify_path_from_output;
  reg a = 0;
  wire y, z;
  sub u(y, z, a);
endmodule
