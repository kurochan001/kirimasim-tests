/*
:name: test_illegal_config_index_not_literal
:description: An index expression in a hierarchical name of a configuration parameter override can only use literals and localparams of the configuration, so a parameter of the design as the index is an error (IEEE 1800-2023 Section 33.4.3)
:tags: ch33
:type: elaboration
:lrm: 1800-2023 33.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an index in the hierarchical name of a parameter override of the config is a parameter of the design
:expected_stderr_regex: test_illegal_config_index_not_literal\.sv:36:
*/
// IEEE 1800-2023 §33.4.3: index expressions in a hierarchical name used by
// a parameter override of a configuration shall only refer to literals or
// to localparams of the configuration. The override of u reads the element
// of the parameter array TABLE of cfgix_top whose index is cfgix_top.K, a
// parameter of the design, which is an error; the index 2 or a localparam
// of the config would be legal.
// Icarus Verilog 13.0 and Verilator 5.052 do not support parameter
// overrides in a config, so the errors they report on that line do not
// count.

module cfgix_leaf #(parameter int W = 4) ();
  initial $display("W=%0d", W);
endmodule

module cfgix_top;
  parameter int TABLE [0:3] = '{1, 2, 3, 4};
  parameter int K = 2;
  cfgix_leaf u();
endmodule

config cfgix;
  design work.cfgix_top;
  instance cfgix_top.u use #(.W(cfgix_top.TABLE[cfgix_top.K]));   // illegal: index not literal
endconfig
