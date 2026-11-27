/*
:name: test_illegal_virtual_interface_component_in_always_comb
:description: An always_comb sensitivity list cannot include a component read through a virtual interface
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.9 9.2.2.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the implicit sensitivity of always_comb includes selected.payload through a virtual interface
:expected_stderr_regex: test_illegal_virtual_interface_component_in_always_comb\.sv:24:(?:\d+:)?[^\n]*(?i:(?:sensitivity|always_comb)[^\n]*virtual interface|virtual interface[^\n]*(?:sensitivity|always_comb))
*/
interface implicit_sensitivity_bus;
  int payload;
endinterface

module test_illegal_virtual_interface_component_in_always_comb;
  implicit_sensitivity_bus bus();
  virtual implicit_sensitivity_bus selected = bus;
  int observed;

  // The read contributes to the implicit sensitivity list (§9.2.2.2.1).
  always_comb observed = selected.payload;

  initial begin
    #1 bus.payload = 47;
    #1;
    $display("observed=%0d", observed);
    $finish(0);
  end
endmodule
