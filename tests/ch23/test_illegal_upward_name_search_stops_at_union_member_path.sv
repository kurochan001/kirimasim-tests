/*
:name: test_illegal_upward_name_search_stops_at_union_member_path
:description: A nearer union object stops upward lookup when its member is missing
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: after matching a union object in the parent the remaining member is absent
:expected_stderr_regex: test_illegal_upward_name_search_stops_at_union_member_path\.sv:15:(?:\d+:)?[^\n]*(?i:(?:member[^\n]*(?:value|record)|(?:value|record)[^\n]*member))
*/
module searched_leaf;
  initial #1 $display("result=%0d", route.record.value); // illegal
endmodule

module searched_middle;
  if (1) begin : route
    union packed { bit [7:0] other; } record = '0;
  end
  searched_leaf leaf();
endmodule

module test_illegal_upward_name_search_stops_at_union_member_path;
  if (1) begin : route
    if (1) begin : record
      int value = 57;
    end
  end
  searched_middle child();
endmodule
