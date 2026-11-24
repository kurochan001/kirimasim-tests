/*
:name: test_reactive_order_preserves_process_order_after_module_nba
:description: Independent Reactive processes preserve their own order and observe the module NBA
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.6 4.7 24.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_reactive_order_preserves_process_order_after_module_nba.expected
:expected_exit: 0
*/
`timescale 1ns/1ns
program ordered_reactive_observer(input int from_module);
  bit left_ready, right_ready;
  bit left_saw_right, right_saw_left;
  int left_sample, right_sample;

  initial begin
    #3;
    left_sample = from_module;
    left_ready = 1;
    left_saw_right = right_ready;
  end

  initial begin
    #3;
    right_sample = from_module;
    right_ready = 1;
    right_saw_left = left_ready;
  end

  initial begin
    #4;
    $display("reactive writes=%0d sees module nba=%0d valid observations=%0d",
             left_ready && right_ready, left_sample == 37 && right_sample == 37,
             left_saw_right || right_saw_left);
  end
endprogram

module test_reactive_order_preserves_process_order_after_module_nba;
  int from_module;
  ordered_reactive_observer observer(from_module);

  initial #3 from_module <= 37;
endmodule
