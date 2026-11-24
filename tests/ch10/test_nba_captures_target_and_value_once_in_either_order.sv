/*
:name: test_nba_captures_target_and_value_once_in_either_order
:description: Nonblocking assignment captures its target and value once before the update
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nba_captures_target_and_value_once_in_either_order.expected
:expected_exit: 0
*/
`timescale 1ns/1ns
module test_nba_captures_target_and_value_once_in_either_order;
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
    bit remained_pending;
    slots[0] = -1;
    slots[1] = -2;
    slots[2] = -3;
    #1;
    slots[choose_index()] <= evaluate_value();
    remained_pending = slots[0] == -1 && slots[1] == -2 && slots[2] == -3;
    marker = 2;
    payload = 23;
    #1;
    $display("pending=%0d captured pair=%0d evaluations=%0d guard=%0d",
             remained_pending,
             (slots[0] == 9 && slots[1] == -2) || (slots[0] == -1 && slots[1] == 9),
             index_evaluations == 1 && value_evaluations == 1, slots[2] == -3);
  end
endmodule
