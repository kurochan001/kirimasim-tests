/*
:name: test_conflicting_expression_side_effect_order
:description: Compare separate increment and read statements and observe conflicting reads
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_conflicting_expression_side_effect_order.expected
*/
module test_conflicting_expression_side_effect_order;
  int separate = 7, left = 7, right = 13;
  int prior, stable_sum, result_left, result_right;

  initial begin
    prior = separate++;
    stable_sum = prior + separate;
    $display("separate prior=%0d now=%0d sum=%0d", prior, separate, stable_sum);

    // The other read can take place before or after the increment.
    if ($test$plusargs("observe_conflict")) begin
      result_left = left++ + left;
      result_right = right + right++;
      $display("conflicts left=%0d next=%0d right=%0d next=%0d",
               result_left, left, result_right, right);
    end
    $finish(0);
  end
endmodule
