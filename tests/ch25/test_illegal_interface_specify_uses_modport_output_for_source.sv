/*
:name: test_illegal_interface_specify_uses_modport_output_for_source
:description: A modport output signal cannot be the input of a specify path
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the specify input descriptor denotes an output-only modport signal
:expected_stderr_regex: test_illegal_interface_specify_uses_modport_output_for_source\.sv:25:(?:\d+:)?[^\n]*(?i:(?:path|specify|terminal|descriptor)[^\n]*(?:direction|input|output|modport)|(?:input|output)[^\n]*(?:path|specify|terminal|descriptor))
*/
interface restricted_terminals;
  wire src, dst;
  modport outward(output src, dst);
endinterface

module test_illegal_interface_specify_uses_modport_output_for_source(
  restricted_terminals.outward pins
);
  assign pins.dst = pins.src;

  specify
    (pins.src => pins.dst) = 3;
  endspecify
endmodule
