/*
:name: test_locator_with_side_effect_observation
:description: A pure locator provides a control for a with expression with side effects
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_locator_with_side_effect_observation.expected
*/
module test_locator_with_side_effect_observation;
  int calls = 0;
  int source[$] = '{3,8,5,2};
  int selected[$];

  function automatic bit counted_select(int value);
    calls++;
    return value >= 5;
  endfunction

  initial begin
    selected = source.find with (item >= 5);
    selected.sort();
    $display("pure locator values=%0d,%0d count=%0d", selected[0], selected[1], selected.size());
    if ($test$plusargs("observe_effect")) begin
      selected = source.find with (counted_select(item));
      $display("impure locator calls=%0d count=%0d", calls, selected.size());
    end
    $finish(0);
  end
endmodule
