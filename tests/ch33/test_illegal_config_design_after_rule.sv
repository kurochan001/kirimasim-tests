/*
:name: test_illegal_config_design_after_rule
:description: The design statement of a config comes before its config rule statements (IEEE 1800-2023 Section 33.4.1.1)
:tags: ch33
:type: elaboration
:lrm: 1800-2023 33.4.1.1 33.4.1.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a config rule statement precedes the design statement
:expected_stderr_regex: test_illegal_config_design_after_rule\.sv:(27|28):
*/
// IEEE 1800-2023 §33.4.1.1: the design statement shall appear before any
// config rule statement of the config. A tool can report the rule statement,
// where it expects the design statement, or the design statement.

module cfgda_leaf;
  initial $display("leaf");
endmodule

module cfgda_top;
  cfgda_leaf u();
endmodule

config cfgda;
  instance cfgda_top.u use work.cfgda_leaf;   // error here
  design work.cfgda_top;   // illegal: after a rule statement
endconfig
