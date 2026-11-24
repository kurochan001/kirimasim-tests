/*
:name: test_active_order_preserves_each_process_write_before_read
:description: Independent Active processes preserve their own write-before-read order
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.2 4.7
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_active_order_preserves_each_process_write_before_read.expected
:expected_exit: 0
*/
`timescale 1ns/1ns
module test_active_order_preserves_each_process_write_before_read;
  bit left_ready, right_ready;
  bit left_saw_right, right_saw_left;
  int left_time, right_time;

  initial begin
    #3;
    left_time = int'($time);
    left_ready = 1;
    left_saw_right = right_ready;
  end

  initial begin
    #3;
    right_time = int'($time);
    right_ready = 1;
    right_saw_left = left_ready;
  end

  initial begin
    #4;
    // Both reads cannot precede the other write when each process writes first.
    $display("active writes=%0d both at three=%0d valid observations=%0d",
             left_ready && right_ready, left_time == 3 && right_time == 3,
             left_saw_right || right_saw_left);
  end
endmodule
