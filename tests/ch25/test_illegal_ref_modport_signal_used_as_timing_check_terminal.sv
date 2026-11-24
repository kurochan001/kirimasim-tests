/*
:name: test_illegal_ref_modport_signal_used_as_timing_check_terminal
:description: A ref signal in a modport cannot be a setup timing check terminal
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.6 31.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the data terminal is a ref signal in the selected interface modport
:expected_stderr_regex: test_illegal_ref_modport_signal_used_as_timing_check_terminal\.sv:21:(?:\d+:)?[^\n]*(?i:(?:\bref\b[^\n]*(?:terminal|timing|specify)|(?:terminal|timing|specify)[^\n]*\bref\b))
*/
interface sampled_channel;
  logic clk, shared_data;
  modport model(input clk, ref shared_data);
endinterface
module checked_path(sampled_channel.model channel);
  reg notifier = 0;
  specify
    $setup(channel.shared_data, posedge channel.clk, 3, notifier); // illegal
  endspecify
endmodule
module test_illegal_ref_modport_signal_used_as_timing_check_terminal;
  sampled_channel channel();
  checked_path instance_under_test(channel);
  initial begin
    channel.clk = 0;
    channel.shared_data = 1;
    #2 channel.clk = 1;
  end
endmodule
