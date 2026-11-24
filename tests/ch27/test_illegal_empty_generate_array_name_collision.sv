/*
:name: test_illegal_empty_generate_array_name_collision
:description: A zero iteration generate loop reserves its named array in the enclosing scope
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.4
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the second loop reuses the array name declared by the empty loop
:expected_stderr_regex: test_illegal_empty_generate_array_name_collision\.sv:(?:17|20):(?:\d+:)?[^\n]*(?i:(?:duplicate|already|redefin|previous|conflict|same name)[^\n]*lanes|lanes[^\n]*(?:duplicate|already|redefin|previous|conflict|same name))
*/
// The first loop never elaborates an element. Its block-array name still
// conflicts with the second loop, which would elaborate one element.
module test_illegal_empty_generate_array_name_collision;
  for (genvar i = 0; i < 0; i++) begin : lanes
    wire value = 1'b0;
  end
  for (genvar j = 0; j < 1; j++) begin : lanes
    wire value = 1'b1;
  end
endmodule
