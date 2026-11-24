/*
:name: test_illegal_virtual_modport_cannot_reach_other_clocking_view
:description: A clocking view cannot reach a second clocking block omitted from its modport
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.9.2 25.5.5
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the target virtual modport lists exposed and does not list hidden
:expected_stderr_regex: test_illegal_virtual_modport_cannot_reach_other_clocking_view\.sv:35:(?:\d+:)?[^\n]*(?i:(?:modport|member|clocking|cannot|can.t find)[^\n]*hidden|hidden[^\n]*(?:modport|member|clocking|not found))
*/
`timescale 1ns/1ns
interface two_sampling_views(input bit tick);
  int value;
  clocking exposed @(posedge tick);
    input value;
  endclocking
  clocking hidden @(negedge tick);
    input value;
  endclocking
  modport first_view(clocking exposed);
  modport second_view(clocking hidden);
endinterface

module test_illegal_virtual_modport_cannot_reach_other_clocking_view;
  bit tick;
  two_sampling_views dut(tick);
  virtual two_sampling_views.first_view narrowed;

  initial begin
    narrowed = dut;
    #1 $display("allowed sampling view=%0d", narrowed.exposed.value);
    $display("unexpected hidden sampling view=%0d", narrowed.hidden.value);
  end
endmodule
