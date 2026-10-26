/*
:name: test_config_symbolic_cell_overrides_binding
:description: A cell rule binds every instance of a cell, named symbolically as library.cell, to another cell, and the config overrides the default library binding (IEEE 1800-2023 Section 33.3, 33.2.1, 33.8)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.2.1 33.3 33.4.1.4 33.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_config_symbolic_cell_overrides_binding.expected
*/
// IEEE 1800-2023 §33.3: a cell is named by the symbolic lib.cell notation,
// which does not depend on where its source file is. §33.2.1: the cell name is
// the name of the design element, here the module scb_leaf_a. §33.8: with no
// config, an instance of scb_leaf_a is bound to that cell; the config scb
// overrides that default search, and its cell rule (33.4.1.4) binds every
// instance that would use cell scb_leaf_a to cell scb_leaf_b, in this module
// and inside scb_mid. Both then show b2 instead of a1.
//
// Icarus Verilog 13.0 skips config declarations; Verilator 5.052 carries out
// the cell rule.

module scb_leaf_a(output logic [7:0] y);
  assign y = 8'ha1;
endmodule

module scb_leaf_b(output logic [7:0] y);
  assign y = 8'hb2;
endmodule

module scb_mid(output logic [7:0] y);
  scb_leaf_a inner(y);
endmodule

module test_config_symbolic_cell_overrides_binding;
  logic [7:0] y1, y2;

  scb_leaf_a keep(y1);
  scb_mid mid(y2);

  initial #1 $display("keep=%h inner=%h", y1, y2);
endmodule

config scb;
  design work.test_config_symbolic_cell_overrides_binding;
  default liblist work;
  cell work.scb_leaf_a use work.scb_leaf_b;
endconfig
