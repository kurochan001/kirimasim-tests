/*
:name: test_illegal_specify_ref_port_terminal
:description: A ref port cannot be a terminal of a module path in a specify block (IEEE 1800-2023 Section 25.6)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.6 30.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module path starts at the ref port r
:expected_stderr_regex: test_illegal_specify_ref_port_terminal\.sv:21:
*/
// IEEE 1800-2023 §25.6: a ref port cannot be used as a terminal in a specify
// block. Icarus Verilog 13.0 does not support ref ports, so the errors it
// reports do not count.

module ref_path_cell (ref logic r, output wire o);
  assign o = r;
  specify
    (r => o) = 1;   // illegal: a ref port as a terminal
  endspecify
endmodule

module test_illegal_specify_ref_port_terminal;
  logic v;
  wire o;
  ref_path_cell c(v, o);
endmodule
