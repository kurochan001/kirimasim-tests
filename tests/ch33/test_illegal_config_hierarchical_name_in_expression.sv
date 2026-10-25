/*
:name: test_illegal_config_hierarchical_name_in_expression
:description: A hierarchical name in a parameter override of a config is the whole value, not a term of an expression (IEEE 1800-2023 Section 33.4.3)
:tags: ch33
:type: elaboration
:lrm: 1800-2023 33.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the parameter override of the config adds a number to a hierarchical name
:expected_stderr_regex: test_illegal_config_hierarchical_name_in_expression\.sv:32:
*/
// IEEE 1800-2023 §33.4.3: a parameter override of a configuration can take
// its value from a hierarchical name, but that name shall then be the only
// term of the expression.
// Icarus Verilog 13.0 and Verilator 5.052 do not support a hierarchical name as
// the value of a parameter override in a config, so the errors they report on
// that line do not count.

module cfghn_leaf #(parameter int W = 4) ();
  initial $display("W=%0d", W);
endmodule

module cfghn_top;
  parameter int N = 6;
  cfghn_leaf u();
endmodule

config cfghn;
  design work.cfghn_top;
  instance cfghn_top.u use #(.W(cfghn_top.N + 1));   // illegal: name with another term
endconfig
