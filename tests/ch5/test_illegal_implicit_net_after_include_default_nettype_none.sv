/*
:name: test_illegal_implicit_net_after_include_default_nettype_none
:description: A default net type directive from an include still suppresses implicit declarations in the including file
:tags: ch5
:type: elaboration
:lrm: 1800-2023 5.6.4 22.2 22.8
:oracle: spec iverilog@13.0
:spec_check: ai
:files: directive_extent/extent_none.svh
:fourstate: no
:nondeterministic: no
:should_fail_because: the net connected to the second instance is undeclared after default_nettype none
:expected_stderr_regex: test_illegal_implicit_net_after_include_default_nettype_none\.sv:28:(?:\d+:)?[^\n]*(?i:(?:implicit|declared|undefined|no net|identifier))
*/
`default_nettype wire
module extent_explicit_out(output wire y);
  assign y = 1'b0;
endmodule

module extent_implicit_before;
  extent_explicit_out u(allowed_implicit_net);
endmodule

`include "extent_none.svh"
module test_illegal_implicit_net_after_include_default_nettype_none;
  wire explicit_net;
  extent_explicit_out legal_control(explicit_net);
  extent_explicit_out forbidden(implicit_net_with_default_disabled);
endmodule

`default_nettype wire
module extent_implicit_after_reset;
  extent_explicit_out u(restored_implicit_net);
endmodule
