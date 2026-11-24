/*
:name: test_virtual_interface_clocking_access_with_and_without_modport
:description: A selected clocking member is usable through a virtual modport and an unrestricted virtual interface
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.9.2 25.5.5
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_interface_clocking_access_with_and_without_modport.expected
*/
`timescale 1ns/1ns
interface sampled_bus(input bit clk);
  bit sample = 1;
  clocking selected @(posedge clk);
    input sample;
  endclocking
  modport synchronous_view(clocking selected);
  modport direct_view(input sample);
endinterface
module test_virtual_interface_clocking_access_with_and_without_modport;
  bit clk;
  sampled_bus bus(clk);
  virtual sampled_bus.synchronous_view restricted;
  virtual sampled_bus unrestricted;

  initial begin
    #5 clk = 1;
    #1 clk = 0;
    bus.sample = 0;
    #4 clk = 1;
  end

  initial begin
    restricted = bus;
    unrestricted = bus;
    @(restricted.selected);
    $display("restricted=%b unrestricted=%b",
             restricted.selected.sample, unrestricted.selected.sample);
    @(unrestricted.selected);
    $display("restricted=%b unrestricted=%b",
             restricted.selected.sample, unrestricted.selected.sample);
  end
endmodule
