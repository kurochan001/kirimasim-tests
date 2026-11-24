/*
:name: test_illegal_interconnect_scalar_connects_to_primitive_array
:description: An interconnect port connected to a primitive instance array must match the array width
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.3.6 6.6.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a one-bit interconnect is connected to a two-instance primitive array
:expected_stderr_regex: test_illegal_interconnect_scalar_connects_to_primitive_array\.sv:15:(?:\d+:)?[^\n]*(?i:(?:interconnect[^\n]*(?:array|width)|(?:array|width)[^\n]*interconnect))
*/
module selected_buffer(input interconnect data, output wire [1:0] observed);
  buf g[1:0](observed, data); // illegal
endmodule

module test_illegal_interconnect_scalar_connects_to_primitive_array;
  wire data = 1'b1;
  wire [1:0] result;
  selected_buffer instance_under_test(data, result);
  initial #1 $display("result=%b", result);
endmodule
