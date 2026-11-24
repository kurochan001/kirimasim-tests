/*
:name: test_illegal_pla_async_rejects_net_member_in_output_concatenation
:description: An asynchronous PLA output concatenation rejects a net bit even when the other output is a variable
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the second output terminal is a bit-select of a net
:expected_stderr_regex: test_illegal_pla_async_rejects_net_member_in_output_concatenation\.sv:24:(?:\d+:)?[^\n]*(?i:(?:outputs?|argument|lvalue)[^\n]*(?:variable|net|not assignable)|net[^\n]*output)
*/
module test_illegal_pla_async_rejects_net_member_in_output_concatenation;
  logic [0:1] personality[0:1];
  logic input_a, input_b, variable_output;
  wire [0:1] net_outputs;

  initial begin
    personality[0] = 2'b10;
    personality[1] = 2'b11;
    input_a = 1;
    input_b = 0;
    $async$and$array(personality, {input_a, input_b}, {variable_output, net_outputs[1]}); // illegal
  end
endmodule
