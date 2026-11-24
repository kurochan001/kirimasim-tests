/*
:name: test_blocking_evaluates_target_and_value_once_in_either_order
:description: Untimed blocking assignment evaluates its target and value once in either order
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.1
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_blocking_evaluates_target_and_value_once_in_either_order.expected
:expected_exit: 0
*/
`timescale 1ns/1ns
module test_blocking_evaluates_target_and_value_once_in_either_order;
  int slots[3];
  int marker, index_evaluations, value_evaluations;
  int payload = 9;

  function automatic int choose_index();
    index_evaluations++;
    return marker;
  endfunction

  function automatic int evaluate_value();
    value_evaluations++;
    marker = 1;
    return payload;
  endfunction

  initial begin
    slots[0] = -1;
    slots[1] = -2;
    slots[2] = -3;
    slots[choose_index()] = evaluate_value();
    $display("allowed target=%0d evaluations=%0d side effect=%0d guard=%0d",
             (slots[0] == 9 && slots[1] == -2) || (slots[0] == -1 && slots[1] == 9),
             index_evaluations == 1 && value_evaluations == 1,
             marker == 1, slots[2] == -3);
  end
endmodule
