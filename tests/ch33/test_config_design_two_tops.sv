/*
:name: test_config_design_two_tops
:description: The design statement of a config can name more than one cell, and each becomes a top-level module, while another uninstantiated module does not; a cell named without a library is looked up in the config's library (IEEE 1800-2023 Section 33.4.1.1)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.4.1.1 33.3.1 23.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_config_design_two_tops.expected
*/
// IEEE 1800-2023 §33.4.1.1: a config has one design statement, which may name
// several top-level cells; a cell without a library name is searched for in
// the library of the config. §33.5.4: with such a config in the source, the
// cells it names are the top-level modules. Every cell here is in the library
// work (33.3.1). The config names this module, with the library, and
// cfg2_second, without it; both print, cfg2_second one time unit later.
// cfg2_stray is not instantiated either, but it is not in the design
// statement, so it is no top-level module (23.3.1) and prints nothing.

`timescale 1ns/1ns

module cfg2_second;
  initial #1 $display("cfg2_second is a top-level module");
endmodule

module cfg2_stray;
  initial $display("cfg2_stray is a top-level module");
endmodule

module test_config_design_two_tops;
  initial $display("test_config_design_two_tops is a top-level module");
endmodule

config cfg2;
  design work.test_config_design_two_tops cfg2_second;
endconfig
