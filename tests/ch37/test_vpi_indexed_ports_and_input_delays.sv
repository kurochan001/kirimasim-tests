/*
:name: test_vpi_indexed_ports_and_input_delays
:description: VPI indexes ordinary ports and reads and updates module input delays
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.14 37.3.4 38.10 38.19 38.20 38.32
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_vpi_indexed_ports_and_input_delays
:vpi_c: @test_vpi_indexed_ports_and_input_delays.c
:expected_stdout: @test_vpi_indexed_ports_and_input_delays.expected
*/
module indexed_delay_sink(input wire [7:4] single_index, input wire [2:1][5:4] multi_index,
                          input wire direct, adjacent, output wire seen, control);
  timeunit 1ns;
  timeprecision 1ns;
  assign seen = direct;
  assign control = adjacent;
endmodule

module test_vpi_indexed_ports_and_input_delays;
  timeunit 1ns;
  timeprecision 1ns;
  bit [7:4] single_index;
  bit [2:1][5:4] multi_index;
  bit drive;
  wire seen, control;
  time rise_tick, fall_tick;

  indexed_delay_sink sink(single_index, multi_index, drive, drive, seen, control);

  always @(posedge seen) rise_tick = $time;
  always @(negedge seen) fall_tick = $time;

  initial begin
    #10 drive = 1;
    #1 $display("rise before=%b peer=%b", seen, control);
    #3 $display("rise after=%b peer=%b", seen, control);
    #6 drive = 0;
    #1 $display("fall before=%b peer=%b", seen, control);
    #5 $display("fall after=%b peer=%b", seen, control);
    $display("edge ticks rise=%0d fall=%0d", rise_tick, fall_tick);
    $finish(0);
  end
endmodule
