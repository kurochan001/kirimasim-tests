/*
:name: test_illegal_user_drive_strength_on_supply_net
:description: A supply net does not allow a user-selected continuous-drive strength
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.3.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the strength-qualified continuous assignment targets a supply1 net
:expected_stderr_regex: test_illegal_user_drive_strength_on_supply_net\.sv:17:(?:\d+:)?[^\n]*(?i:(?:strength|assign)[^\n]*(?:supply|rail)|(?:supply|rail)[^\n]*(?:strength|assign))
*/
module test_illegal_user_drive_strength_on_supply_net;
  logic source;
  supply1 supply_rail;
  assign (weak0, pull1) supply_rail = source;
  initial begin
    source = 1;
    #1 $display("unexpected strength selection=%b", supply_rail);
  end
endmodule
