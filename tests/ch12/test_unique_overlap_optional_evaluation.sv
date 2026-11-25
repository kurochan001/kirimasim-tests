/*
:name: test_unique_overlap_optional_evaluation
:description: Observe which conditions are visited before and after a uniqueness violation
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4.2 12.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unique_overlap_optional_evaluation.expected
*/
module test_unique_overlap_optional_evaluation;
  bit [2:0] if_seen, case_seen;
  bit overlapping;
  int if_selected, case_selected;

  function automatic bit condition(int slot, bit hit);
    if_seen[slot] = 1;
    return hit;
  endfunction

  function automatic int item(int slot, int value);
    case_seen[slot] = 1;
    return value;
  endfunction

  initial begin
    overlapping = $test$plusargs("overlap_if");
    unique if (condition(0, 1'b1))
      if_selected = 10;
    else if (condition(1, overlapping))
      if_selected = 20;
    else if (condition(2, 1'b0))
      if_selected = 30;
    else
      if_selected = 40;
    $display("if selected=%0d visited=%b", if_selected, if_seen);

    overlapping = $test$plusargs("overlap_case");
    unique case (5)
      item(0, 5): case_selected = 10;
      item(1, overlapping ? 5 : 7): case_selected = 20;
      item(2, 9): case_selected = 30;
      default: case_selected = 40;
    endcase
    $display("case selected=%0d visited=%b", case_selected, case_seen);
    $finish(0);
  end
endmodule
