/*
:name: test_specify_path_delay_preserves_large_integral_tick
:description: An integral specify path delay retains its last precision tick at a large time
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.5.1 30.5.2 3.14.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_specify_path_delay_preserves_large_integral_tick.expected
*/
module wide_specify_path(input wire source, output wire delayed);
  timeunit 1ps;
  timeprecision 1ps;

  assign delayed = source;
  specify
    specparam PROPAGATION = 64'd9007199254740993;
    (source => delayed) = PROPAGATION;
  endspecify
endmodule

module test_specify_path_delay_preserves_large_integral_tick;
  timeunit 1ps;
  timeprecision 1ps;

  logic source = 1'bx;
  wire delayed;
  time input_tick, output_tick;
  wide_specify_path dut(source, delayed);

  always @(source) if (source === 1'b1) input_tick = $time;
  always @(delayed) if (delayed === 1'b1) output_tick = $time;

  initial #4 $display("before input=%b output=%b", source, delayed);
  initial #5 source = 1'b1;

  initial begin
    #(64'd9007199254741010);
    $display("input=%0d output=%0d path=%0d", input_tick, output_tick, output_tick - input_tick);
  end
endmodule
