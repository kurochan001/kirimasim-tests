/*
:name: test_illegal_function_in_continuous_assign_output
:description: A function with an output argument cannot be called in a continuous assignment (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4 10.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a function with an output argument is called on the right of a continuous assignment
:expected_stderr_regex: test_illegal_function_in_continuous_assign_output\.sv:26:
*/
// IEEE 1800-2023 §13.4: a function with output, inout or ref arguments cannot
// be called in an event expression, in a continuous assignment and in some
// other contexts. The continuous assignment below calls one.

module test_illegal_function_in_continuous_assign_output;
  int extra;
  function int twice(input int x, output int y);
    y = x;
    return 2 * x;
  endfunction
  logic [7:0] a = 8'd3;
  wire [31:0] w;
  assign w = twice(a, extra);   // illegal: a function with an output
endmodule
