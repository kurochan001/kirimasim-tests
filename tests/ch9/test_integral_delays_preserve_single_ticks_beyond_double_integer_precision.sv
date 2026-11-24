/*
:name: test_integral_delays_preserve_single_ticks_beyond_double_integer_precision
:description: Integral delays and time reads keep adjacent ticks distinct beyond the exact whole-number range of a double
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.1 3.14.2 20.3.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_integral_delays_preserve_single_ticks_beyond_double_integer_precision.expected
*/
module test_integral_delays_preserve_single_ticks_beyond_double_integer_precision;
  timeunit 1ps;
  timeprecision 1ps;

  localparam time EPOCH = 64'd9007199254740992;
  time first_tick, next_tick, third_tick;
  time direct_next, direct_third;

  initial begin
    #(EPOCH);
    first_tick = $time;
    #1 next_tick = $time;
    #1 third_tick = $time;
  end

  initial #(EPOCH + 1) direct_next = $time;
  initial #(EPOCH + 2) direct_third = $time;

  initial begin
    #(EPOCH + 6);
    $display("sequential=%0d %0d %0d", first_tick, next_tick, third_tick);
    $display("absolute=%0d %0d gaps=%0d %0d",
             direct_next, direct_third, next_tick - first_tick, third_tick - next_tick);
  end
endmodule
