/*
:name: test_config_design_top
:description: The design statement of a config names the top-level module, and other uninstantiated modules in the source are not elaborated (IEEE 1800-2023 Section 33.4.1.1)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.4.1.1 33.5.4 33.3.1 23.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_config_design_top.expected
*/
// IEEE 1800-2023 §33.5.4: when a config with a design statement is part of the
// source, the cell it names is the top-level module, whatever other
// uninstantiated cells the source has. §33.4.1.1: the design statement names
// that cell. §33.3.1: cells from a file that no library map matches are in the
// library work. cfg_stray is never instantiated, but because the config names
// only this module, it is not a top-level module (23.3.1) and prints nothing.
// Icarus Verilog 13.0 skips config declarations. Verilator 5.052 gives this
// output only when --top-module names this module; without it, it elaborates
// every uninstantiated module.

module cfg_stray;
  initial $display("cfg_stray elaborated");
endmodule

module test_config_design_top;
  initial #1 $display("top: %m");
endmodule

config cfg;
  design work.test_config_design_top;
endconfig
