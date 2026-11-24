/*
:name: test_upward_name_search_continues_past_missing_generate_member
:description: A nearer generate scope with a missing member allows lookup to continue upward
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_upward_name_search_continues_past_missing_generate_member.expected
*/
module upward_leaf;
  initial #1 $display("result=%0d", route.record.value);
endmodule

module upward_middle;
  if (1) begin : route
    if (1) begin : record
      int other = 13;
    end
  end
  upward_leaf node();
endmodule

module test_upward_name_search_continues_past_missing_generate_member;
  if (1) begin : route
    if (1) begin : record
      int value = 57;
    end
  end
  upward_middle child();
endmodule
