/*
:name: test_illegal_upward_name_search_stops_at_struct_member_path
:description: A nearer structure prevents upward lookup from continuing past its missing member
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the structure record matched in the parent has no member value
:expected_stderr_regex: test_illegal_upward_name_search_stops_at_struct_member_path\.sv:15:(?:\d+:)?[^\n]*(?i:(?:member[^\n]*(?:value|record)|(?:value|record)[^\n]*member))
*/
module upward_leaf;
  initial #1 $display("result=%0d", route.record.value); // illegal
endmodule

module upward_middle;
  if (1) begin : route
    struct packed { bit other; } record = '0;
  end
  upward_leaf node();
endmodule

module test_illegal_upward_name_search_stops_at_struct_member_path;
  if (1) begin : route
    if (1) begin : record
      int value = 57;
    end
  end
  upward_middle child();
endmodule
