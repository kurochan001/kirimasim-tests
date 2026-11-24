/*
:name: test_continuous_and_gate_delays_preserve_large_integral_tick
:description: Continuous assignments and gate instances retain an odd large integral delay
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3.3 28.16 3.14.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_continuous_and_gate_delays_preserve_large_integral_tick.expected
*/
module test_continuous_and_gate_delays_preserve_large_integral_tick;
  timeunit 1ps;
  timeprecision 1ps;

  localparam time LARGE_DELAY = 64'd9007199254740993;
  logic source = 1'bx;
  wire continuous_out, gate_out;

  assign #(LARGE_DELAY) continuous_out = source;
  buf #(LARGE_DELAY) gate_delay(gate_out, source);

  time continuous_tick, gate_tick;
  always @(continuous_out) if (continuous_out === 1'b1) continuous_tick = $time;
  always @(gate_out) if (gate_out === 1'b1) gate_tick = $time;

  initial #5 source = 1'b1;

  initial begin
    #(LARGE_DELAY + 15);
    $display("continuous=%0d gate=%0d",
             continuous_tick, gate_tick);
  end
endmodule
