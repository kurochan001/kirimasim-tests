/*
:name: test_illegal_data_address_operator_does_not_create_chandle
:description: A reduction of a SystemVerilog variable cannot be assigned to a foreign handle
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: unary ampersand yields an integral reduction and cannot obtain the address of source
:expected_stderr_regex: test_illegal_data_address_operator_does_not_create_chandle\.sv:21:(?:\d+:)?[^\n]*(?i:chandle|(?:assign|convert|operator|type)[^\n]*handle)
*/
module test_illegal_data_address_operator_does_not_create_chandle;
  logic [3:0] source = 4'hf;
  chandle foreign_address;
  bit reduction_result;

  initial begin
    reduction_result = &source;
    foreign_address = &source;
    $display("unexpected handle with reduction=%0b", reduction_result);
  end
endmodule
