/*
:name: test_unique_if_rechecks_overlapping_predicates_after_false_guard
:description: Unique if reports overlapping predicates only when the enclosing branch is enabled
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unique_if_rechecks_overlapping_predicates_after_false_guard.expected
:expected_stderr_regex: (?im)^(?=[^\n]*\b(?:warning|error|fatal)\b)(?=[^\n]*\bunique\b)(?=[^\n]*(?:overlap|multiple|violation))[^\n]+
*/
module test_unique_if_rechecks_overlapping_predicates_after_false_guard;
  bit choose_even;
  int value;

  initial begin
    value = 4;
    choose_even = 0;
    if (choose_even)
      unique if (value > 2) begin end
        else if (value % 2 == 0) begin end
        else begin end
    $display("disabled branch completed");

    choose_even = 1;
    if (choose_even)
      unique if (value > 2) $display("first branch");
        else if (value % 2 == 0) $display("second branch");
        else $display("fallback branch");
  end
endmodule
