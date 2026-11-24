/*
:name: test_illegal_instance_target_bind_requires_instantiation_terminator
:description: An instance-target bind must terminate its bound instantiation with a semicolon
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.11 A.1.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the explicit instance-target bind omits its terminating semicolon
:expected_stderr_regex: test_illegal_instance_target_bind_requires_instantiation_terminator\.sv:(?:22|23):(?:\d+:)?[^\n]*(?i:(?:ExpectedToken|expect[^\n]*(?:semicolon|[\x27\x22];)|(?:semicolon|[\x27\x22];)[^\n]*expect))
*/
module probe(input wire sample);
endmodule
module bind_target;
  wire data = 1'b1;
endmodule
module test_illegal_instance_target_bind_requires_instantiation_terminator;
  bind_target nodes [2:0]();
  bind test_illegal_instance_target_bind_requires_instantiation_terminator.nodes[2]
      probe attached(.sample(data))
  initial $display("built"); // illegal
endmodule
