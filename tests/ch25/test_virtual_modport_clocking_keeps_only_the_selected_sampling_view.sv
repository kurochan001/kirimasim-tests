/*
:name: test_virtual_modport_clocking_keeps_only_the_selected_sampling_view
:description: An unqualified virtual interface and its clocking modport sample the same declared signal
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.9.2 25.5.5
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_modport_clocking_keeps_only_the_selected_sampling_view.expected
*/
`timescale 1ns/1ns
interface sampling_views(input bit tick);
  int payload;
  clocking observed @(posedge tick);
    input payload;
  endclocking
  modport synchronous(clocking observed);
  modport asynchronous(input payload);
endinterface

module test_virtual_modport_clocking_keeps_only_the_selected_sampling_view;
  bit tick;
  sampling_views dut(tick);
  virtual sampling_views full_view;
  virtual sampling_views.synchronous restricted_view;

  initial begin
    full_view = dut;
    restricted_view = dut;
    dut.payload = 9;
    #2 tick = 1;
    #1 $display("first sample=%0d/%0d", full_view.observed.payload,
                restricted_view.observed.payload);
    dut.payload = 6;
    tick = 0;
    #2 tick = 1;
    #1 $display("second sample=%0d/%0d", full_view.observed.payload,
                restricted_view.observed.payload);
  end
endmodule
