/*
:name: test_config_use_without_library
:description: A use clause that names a cell without a library binds the selected instance or cell to that cell in the library of the parent cell, and the bound cell can have another name than the module the instance names (IEEE 1800-2023 Section 33.4.1.6)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.4.1.6 33.4.1.3 33.4.1.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_config_use_without_library.expected
*/
// IEEE 1800-2023 §33.4.1.6: a use clause gives the cell to which the
// selected instance or cell is bound; when it leaves out the library, the
// library is that of the parent cell, and the bound cell need not have the
// name of the module that the instance names. All cells here are in work,
// the library of this module. The config binds the instance u2 of
// cfgnl_leaf_a with "use cfgnl_leaf_b" (33.4.1.3) and every instance of the
// cell cfgnl_cell_c with "use cfgnl_cell_d" (33.4.1.4), both without a
// library, so u2 and u3 become cfgnl_leaf_b and cfgnl_cell_d, while u1 keeps
// cfgnl_leaf_a. Icarus Verilog 13.0 skips config declarations. When it is
// told that this module is the top-level module, Verilator 5.052 prints
// "u1=aa u2=aa u3=cc": it ignores the two use clauses without a library,
// although it follows them when they name the library work.

module cfgnl_leaf_a(output logic [7:0] y);
  assign y = 8'haa;
endmodule

module cfgnl_leaf_b(output logic [7:0] y);
  assign y = 8'hbb;
endmodule

module cfgnl_cell_c(output logic [7:0] y);
  assign y = 8'hcc;
endmodule

module cfgnl_cell_d(output logic [7:0] y);
  assign y = 8'hdd;
endmodule

module test_config_use_without_library;
  logic [7:0] y1, y2, y3;

  cfgnl_leaf_a u1(y1);
  cfgnl_leaf_a u2(y2);
  cfgnl_cell_c u3(y3);

  initial #1 $display("u1=%h u2=%h u3=%h", y1, y2, y3);
endmodule

config cfg;
  design work.test_config_use_without_library;
  default liblist work;
  instance test_config_use_without_library.u2 use cfgnl_leaf_b;
  cell cfgnl_cell_c use cfgnl_cell_d;
endconfig
