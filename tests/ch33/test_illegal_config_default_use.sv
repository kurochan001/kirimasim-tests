/*
:name: test_illegal_config_default_use
:description: A default clause of a config cannot take a use clause (IEEE 1800-2023 Section 33.4.1.2)
:tags: ch33
:type: elaboration
:lrm: 1800-2023 33.4.1.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the default clause of the config has a use clause
:expected_stderr_regex: test_illegal_config_default_use\.sv:26:
*/
// IEEE 1800-2023 §33.4.1.2: the use clause (33.4.1.6) cannot go with a default
// selection clause; it applies only to an instance or a cell.

module cfgx1_leaf;
endmodule

module test_illegal_config_default_use;
  cfgx1_leaf u();
endmodule

config cfgx1;
  design work.test_illegal_config_default_use;
  default use work.cfgx1_leaf;   // illegal: use with default
endconfig
