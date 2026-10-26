/*
:name: test_config_design_statement_selects_top
:description: When a config has a design statement, the cell it names is the top-level module even when another cell in the source is uninstantiated (IEEE 1800-2023 Section 33.5.4)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.5.4 33.4.1.1 23.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_config_design_statement_selects_top.expected
*/
// IEEE 1800-2023 §33.5.4: in a single-pass use model with a config on the
// command line, "in the case where the config includes a design statement,
// then the specified cell shall be the top-level module, regardless of the
// presence of any uninstantiated cells in the rest of the source files."
// §33.4.1.1: the design statement names a cell that is not a configuration.
// The module cds_stray is never instantiated, but without the config it would
// be a top-level module too (23.3.1) and would print its line. The config cds
// names only test_config_design_statement_selects_top, so that line is absent
// while the top module's line appears.
//
// Icarus Verilog 13.0 skips config declarations, and Verilator 5.052 does not
// apply the design statement without --top-module, so :oracle: names the
// standard alone.

module cds_stray;
  initial $display("cds_stray elaborated");
endmodule

module test_config_design_statement_selects_top;
  initial #1 $display("top: %m");
endmodule

config cds;
  design work.test_config_design_statement_selects_top;
endconfig
