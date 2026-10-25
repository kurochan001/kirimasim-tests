/*
:name: test_config_library_cell_and_topmodule_names
:description: A config declaration, the topmodule of its design clause, the library of its liblist and the cells of its cell clause are named by identifiers; the cell clause binds the instances of cfg_a to cfg_b, and %L prints the library and cell each instance is bound to (IEEE 1800-2023 Sections 33.4.1, 33.4.1.1, 33.4.1.4 and 33.7)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.4.1 33.4.1.1 33.4.1.4 33.7 A.9.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_config_library_cell_and_topmodule_names
:expected_stdout: @test_config_library_cell_and_topmodule_names.expected
*/
// IEEE 1800-2023 A.9.3: a config identifier, a library identifier, a cell
// identifier and a topmodule identifier are identifiers. §33.4.1: the config
// declaration cfg_ids selects its design, its default library list and its
// cells. §33.4.1.1: the design clause names the top module through the
// library work. §33.4.1.4: cell cfg_a use work.cfg_b binds every instance of
// cfg_a to cfg_b, so u1, declared as cfg_a, is an instance of cfg_b and keeps
// its parameter D = 1. §33.7: %L prints the library and cell of the instance
// in which it is called, and %m prints the hierarchical name.
//
// The top prints work.test_config_library_cell_and_topmodule_names. u1 prints
// at time 1 as work.cfg_b, and u2, which stays cfg_b, prints at time 2 as
// work.cfg_b too.
//
// Icarus Verilog 13.0 skips config declarations and prints %L as it stands;
// the 5.052 release of Verilator produces this output when --top-module
// names the test module, which the :top_module: field does.

`timescale 1ns/1ns

module cfg_a #(parameter int D = 1);
  initial #(D) $display("a %m %L");
endmodule

module cfg_b #(parameter int D = 2);
  initial #(D) $display("b %m %L");
endmodule

module test_config_library_cell_and_topmodule_names;
  cfg_a #(.D(1)) u1 ();
  cfg_b #(.D(2)) u2 ();

  initial $display("top %m %L");
endmodule

config cfg_ids;
  design work.test_config_library_cell_and_topmodule_names;
  default liblist work;
  cell cfg_a use work.cfg_b;
endconfig
