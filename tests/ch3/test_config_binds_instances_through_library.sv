/*
:name: test_config_binds_instances_through_library
:description: A configuration binds the module instances of its design to cells of a library: its cell clause binds the instance of one module to another cell of the library work, its instance clause binds one instance of a second module to a fourth cell, and the other instance of the second module, which no clause but the default selects, keeps its own cell (IEEE 1800-2023 Section 3.10)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.10 33.4.1.2 33.4.1.3 33.4.1.4 33.4.1.5 33.4.1.6
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: cbl_cfg
:expected_stdout: @test_config_binds_instances_through_library.expected
*/
// IEEE 1800-2023 §3.10: a configuration says which source definition each
// module instance is bound to, through libraries. §33.3.1: a file that no
// library map names goes into the library work. §33.4.1.4: a cell clause
// selects the instances of the cell it names; §33.4.1.3: an instance clause
// selects one instance; §33.4.1.6: a use clause binds what is selected to
// the library and cell it names. §33.4.1.2 and §33.4.1.5: the default clause
// selects every other instance, and with the library list work such an
// instance is bound to the cell of its own name in work.
// The configuration cbl_cfg, which :top_module: elaborates, has the test
// module as its design. u1 is written as cbl_one (1), and u2 and u3 as
// cbl_two (2). The cell clause selects only u1, the one instance of cbl_one,
// and binds it to cbl_three (3); the instance clause selects only u2 and
// binds it to cbl_four (4); no instance is selected by both. u3 is selected
// by the default clause only and stays cbl_two. The test module prints
// u1=3 u2=4 u3=2; without the configuration it would print u1=1 u2=2 u3=2.
// The 5.054 release of Verilator produces this output; Icarus Verilog 13.0
// skips configuration declarations.

module cbl_one (output logic [3:0] y);
  assign y = 4'd1;
endmodule

module cbl_two (output logic [3:0] y);
  assign y = 4'd2;
endmodule

module cbl_three (output logic [3:0] y);
  assign y = 4'd3;
endmodule

module cbl_four (output logic [3:0] y);
  assign y = 4'd4;
endmodule

module test_config_binds_instances_through_library;
  logic [3:0] y1, y2, y3;

  cbl_one u1 (y1);
  cbl_two u2 (y2);
  cbl_two u3 (y3);

  initial #1 $display("u1=%0d u2=%0d u3=%0d", y1, y2, y3);
endmodule

config cbl_cfg;
  design work.test_config_binds_instances_through_library;
  default liblist work;
  cell cbl_one use work.cbl_three;
  instance test_config_binds_instances_through_library.u2 use work.cbl_four;
endconfig
