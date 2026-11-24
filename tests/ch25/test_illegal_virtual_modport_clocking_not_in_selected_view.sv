/*
:name: test_illegal_virtual_modport_clocking_not_in_selected_view
:description: A virtual interface narrowed to a modport cannot name an excluded clocking block
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.9.2 25.5.5
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the direct_view modport allows sample but excludes the clocking block selected
:expected_stderr_regex: test_illegal_virtual_modport_clocking_not_in_selected_view\.sv:31:(?:\d+:)?[^\n]*(?i:(?:modport|member|clocking|cannot|can.t find)[^\n]*selected|selected[^\n]*(?:modport|member|clocking|not found))
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
module test_illegal_virtual_modport_clocking_not_in_selected_view;
  bit clk;
  sampled_bus bus(clk);
  virtual sampled_bus.direct_view restricted;

  initial begin
    restricted = bus;
    #1 $display("direct=%b", restricted.sample);
    $display("sampled=%b", restricted.selected.sample); // illegal
  end
endmodule
