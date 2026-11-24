/*
:name: test_illegal_modport_excludes_signal_from_interface_port_view
:description: An interface port with a selected modport rejects an unlisted signal
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.10
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: hidden_data is not in the reader modport
:expected_stderr_regex: test_illegal_modport_excludes_signal_from_interface_port_view\.sv:22:(?:\d+:)?[^\n]*(?=[^\n]*hidden_data)(?i:(?:modport|not found|unknown|undeclared|not a member|cannot|could not|can't find))
*/
interface selective_bus;
  bit visible_data, hidden_data;
  modport reader(input visible_data);
endinterface

module consumer(selective_bus.reader bus);
  initial begin
    $display("visible=%b", bus.visible_data);
    $display("hidden=%b", bus.hidden_data); // illegal
  end
endmodule

module test_illegal_modport_excludes_signal_from_interface_port_view;
  selective_bus bus();
  consumer inst(bus);
endmodule
