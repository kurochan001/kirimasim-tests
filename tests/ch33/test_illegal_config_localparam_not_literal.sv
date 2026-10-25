/*
:name: test_illegal_config_localparam_not_literal
:description: A localparam of a config is set to a literal value only (IEEE 1800-2023 Section 33.4.3)
:tags: ch33
:type: elaboration
:lrm: 1800-2023 33.4.3 33.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a localparam of the config is set to an expression that is not a literal
:expected_stderr_regex: test_illegal_config_localparam_not_literal\.sv:29:
*/
// IEEE 1800-2023 §33.4.3: a localparam declared in a configuration shall be
// assigned a value, and that value shall only be a literal.
// Icarus Verilog 13.0 does not support a localparam in a config, and Verilator
// 5.052 does not support it either, so the errors they report on that line do
// not count.

module cfglp_leaf #(parameter int W = 4) ();
  initial $display("W=%0d", W);
endmodule

module cfglp_top;
  cfglp_leaf u();
endmodule

config cfglp;
  localparam S = 3 + 4;   // illegal: not a literal
  design work.cfglp_top;
  instance cfglp_top.u use #(.W(S));
endconfig
