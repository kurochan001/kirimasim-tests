/*
:name: test_illegal_user_drive_strength_on_full_vector_net
:description: An explicit continuous-drive strength cannot qualify an entire vector net
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.3.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the explicit drive strength applies to a vector assignment instead of a scalar net
:expected_stderr_regex: test_illegal_user_drive_strength_on_full_vector_net\.sv:17:(?:\d+:)?[^\n]*(?i:(?:strength|assign)[^\n]*(?:vector|scalar)|(?:vector|scalar)[^\n]*(?:strength|assign))
*/
module test_illegal_user_drive_strength_on_full_vector_net;
  logic [2:0] source;
  wire [2:0] bus;
  assign (weak0, pull1) bus = source;
  initial begin
    source = 3'b011;
    #1 $display("unexpected strength selection=%b", bus);
  end
endmodule
