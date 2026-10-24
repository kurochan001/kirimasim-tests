/*
:name: test_illegal_config_design_is_config
:description: The cells that the design statement of a config names cannot be configurations themselves (IEEE 1800-2023 Section 33.4.1.1)
:tags: ch33
:type: elaboration
:lrm: 1800-2023 33.4.1.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the design statement of a config names another config
:expected_stderr_regex: test_illegal_config_design_is_config\.sv:31:
*/
// IEEE 1800-2023 §33.4.1.1: the design statement names the library and cell
// of the top-level modules of the configured hierarchy, and these cells
// cannot be configurations themselves. The design statement of cfgdc names
// the config cfgdc_inner, which is an error; cfgdc_inner itself, which names
// the module cfgdc_top, is legal.
// Icarus Verilog 13.0 skips config declarations, and Verilator 5.052
// accepts the design.

module cfgdc_top;
  initial $display("top");
endmodule

config cfgdc_inner;
  design work.cfgdc_top;
endconfig

config cfgdc;
  design work.cfgdc_inner;   // illegal: the design cell is a config
endconfig
