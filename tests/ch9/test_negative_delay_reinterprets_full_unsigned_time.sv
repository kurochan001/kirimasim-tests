/*
:name: test_negative_delay_reinterprets_full_unsigned_time
:description: A negative signed delay and its unsigned interpretation select the same tick and preserve the next tick
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.1 20.3.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_negative_delay_reinterprets_full_unsigned_time.expected
*/
module test_negative_delay_reinterprets_full_unsigned_time;
  timeunit 1ps;
  timeprecision 1ps;

  localparam longint NEGATIVE_DELAY = -64'sd9223372036854775807;
  localparam time UNSIGNED_DELAY = 64'd9223372036854775809;
  time negative_arrival, positive_arrival, following_tick;

  initial begin
    #(NEGATIVE_DELAY);
    negative_arrival = $time;
    #1 following_tick = $time;
  end

  initial #(UNSIGNED_DELAY) positive_arrival = $time;

  initial begin
    #(UNSIGNED_DELAY + 7);
    $display("negative=%0d positive=%0d following=%0d",
             negative_arrival, positive_arrival, following_tick);
  end
endmodule
