/*
:name: test_illegal_interface_specify_uses_ref_modport_terminal
:description: A ref modport signal is ineligible as a specify terminal
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a ref signal exposed by the modport is used as a specify terminal
:expected_stderr_regex: test_illegal_interface_specify_uses_ref_modport_terminal\.sv:25:(?:\d+:)?[^\n]*(?i:InvalidSpecifySource|(?:specify|terminal|descriptor|path)[^\n]*(?:ref|input|inout)|ref[^\n]*(?:specify|terminal|descriptor|path))
*/
interface reference_terminal_bus;
  logic source;
  wire sink;
  modport model(ref source, output sink);
endinterface

module test_illegal_interface_specify_uses_ref_modport_terminal(
  reference_terminal_bus.model pins
);
  assign pins.sink = pins.source;
  specify
    (pins.source => pins.sink) = 2;
  endspecify
endmodule
