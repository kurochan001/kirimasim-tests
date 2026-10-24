/*
:name: test_config_binding_descends_through_children
:description: Binding starts at the top-level module and goes down through the children of every bound instance, so a rule for an instance two levels down applies, and the children of a cell bound by a rule are bound as well (IEEE 1800-2023 Section 33.2)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_config_binding_descends_through_children
:expected_stdout: @test_config_binding_descends_through_children.expected
*/
// IEEE 1800-2023 §33.2: a design description starts with its top-level
// modules; from the source description of each, the instantiated children
// are found, then the source descriptions of their definitions are located,
// and so on until every instance is bound. The top module has two instances
// of cbd_mid, each with a child u_leaf. The instance rule of cbd_cfg binds
// only m2.u_leaf, two levels down, to cbd_leaf_alt, whose own child u_sub is
// then bound by the cell rule to cbd_sub_alt. Every cell prints its
// hierarchical name and its library.cell binding with %l, each cell at a time
// of its own: a leaf at 1, an alternative leaf at 2, a sub cell at 3.
// Icarus Verilog 13.0 skips config declarations and does not implement %l.
// The 5.052 release of Verilator applies the instance rule for m2.u_leaf to
// m1.u_leaf as well, so both leaves become cbd_leaf_alt.

module cbd_sub;
  initial #3 $display("%m: %l");
endmodule

module cbd_sub_alt;
  initial #3 $display("%m: %l");
endmodule

module cbd_leaf;
  initial #1 $display("%m: %l");
endmodule

module cbd_leaf_alt;
  cbd_sub u_sub ();
  initial #2 $display("%m: %l");
endmodule

module cbd_mid;
  cbd_leaf u_leaf ();
endmodule

module test_config_binding_descends_through_children;
  cbd_mid m1 ();
  cbd_mid m2 ();
endmodule

config cbd_cfg;
  design work.test_config_binding_descends_through_children;
  default liblist work;
  instance test_config_binding_descends_through_children.m2.u_leaf use work.cbd_leaf_alt;
  cell cbd_sub use work.cbd_sub_alt;
endconfig
