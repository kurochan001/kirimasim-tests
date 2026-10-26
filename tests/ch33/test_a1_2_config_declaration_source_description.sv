/*
:name: test_a1_2_config_declaration_source_description
:description: A configuration declaration in the source text selects the top-level module of the design and rebinds an instance, so it is one of the source descriptions that elaborates with the modules of its file (IEEE 1800-2023 Sections 3.2 and 33.3, A.1.2)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.3 3.2 A.1.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_a1_2_config_declaration_source_description.expected
*/
// IEEE 1800-2023 A.1.2: a source description is a module, interface, program,
// package, primitive, config declaration or package item; a source text is a
// sequence of them. §33.3: the configuration declaration of a design selects
// its top-level module and its rules rebind cells.
//
// The file holds the cells sda and sdb, the module sdm, the test module and
// the configuration cfg_desc. The configuration names
// work.test_a1_2_config_declaration_source_description as its design and binds
// every cell sda to sdb, so the instance inside sdm and the direct instance u2
// each print 2. A tool that did not read the configuration declaration as a
// source description would print 1 for both. Icarus Verilog 13.0 skips
// configuration declarations, so the expected output was recorded with the
// 5.052 release of Verilator.

module sda (output logic [3:0] y);
  assign y = 4'h1;
endmodule

module sdb (output logic [3:0] y);
  assign y = 4'h2;
endmodule

module sdm (output logic [3:0] y);
  sda u ();
  assign y = u.y;
endmodule

module test_a1_2_config_declaration_source_description;
  logic [3:0] y1, y2;

  sdm m1 (.y(y1));
  sda u2 (.y(y2));

  initial #1 $display("m=%h u=%h", y1, y2);
endmodule

config cfg_desc;
  design work.test_a1_2_config_declaration_source_description;
  cell sda use work.sdb;
endconfig
