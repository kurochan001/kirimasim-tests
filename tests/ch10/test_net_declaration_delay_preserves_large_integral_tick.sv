/*
:name: test_net_declaration_delay_preserves_large_integral_tick
:description: A delay in a net declaration keeps the odd precision tick of a large integral delay
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3.3 3.14.2
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_declaration_delay_preserves_large_integral_tick.expected
*/
module test_net_declaration_delay_preserves_large_integral_tick;
  timeunit 1ps;
  timeprecision 1ps;

  localparam time DELAY = 64'd9007199254740993;
  logic source = 1'bx;
  wire #(DELAY) delayed;
  wire immediate = source;
  time immediate_tick, delayed_tick;
  assign delayed = source;

  always @(immediate) if (immediate === 1'b1) immediate_tick = $time;
  always @(delayed) if (delayed === 1'b1) delayed_tick = $time;

  initial #5 source = 1'b1;

  initial begin
    #(DELAY + 15);
    $display("immediate=%0d delayed=%0d gap=%0d",
             immediate_tick, delayed_tick, delayed_tick - immediate_tick);
  end
endmodule
