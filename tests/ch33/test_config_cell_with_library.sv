/*
:name: test_config_cell_with_library
:description: A cell clause with a library name applies to every instance bound to that library and cell, wherever it is in the hierarchy, and leaves instances of other cells alone (IEEE 1800-2023 Section 33.4.1.4)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.4.1.4 33.4.1.6 33.3.1 33.3.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_config_cell_with_library.expected
*/
// IEEE 1800-2023 §33.4.1.4: with a library name, "cell work.cfg3_leaf_a"
// selects every instance that is bound, or would be bound, to the cell
// cfg3_leaf_a of the library work, where all cells here are (33.3.1); "use
// work.cfg3_leaf_b" (33.4.1.6) binds them to cfg3_leaf_b instead. So the
// instance in this module and the one inside cfg3_mid both become
// cfg3_leaf_b, while the instance of cfg3_leaf_c keeps its cell.

module cfg3_leaf_a(output logic [7:0] y);
  assign y = 8'haa;
endmodule

module cfg3_leaf_b(output logic [7:0] y);
  assign y = 8'hbb;
endmodule

module cfg3_leaf_c(output logic [7:0] y);
  assign y = 8'hcc;
endmodule

module cfg3_mid(output logic [7:0] y);
  cfg3_leaf_a inner(y);
endmodule

module test_config_cell_with_library;
  logic [7:0] y1, y2, y3;

  cfg3_leaf_a u1(y1);
  cfg3_mid m(y2);
  cfg3_leaf_c u3(y3);

  initial #1 $display("u1=%h m.inner=%h u3=%h", y1, y2, y3);
endmodule

config cfg3;
  design work.test_config_cell_with_library;
  cell work.cfg3_leaf_a use work.cfg3_leaf_b;
endconfig
