/*
:name: test_config_cell_use
:description: A cell clause with use binds every instance of that cell, at any level of the hierarchy, to another cell (IEEE 1800-2023 Section 33.4.1.4)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.4.1.4 33.4.1.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_config_cell_use.expected
*/
// IEEE 1800-2023 §33.4.1.4, §33.4.1.6: "cell <cell> use <lib>.<cell>" applies
// to every instance that would be bound to the selected cell. Instances of
// cfg_cell_a directly in this module and inside cfg_cell_mid all become
// cfg_cell_b; the instance of cfg_cell_c is not selected and keeps its cell.
// Icarus Verilog 13.0 skips config declarations.

module cfg_cell_a(output logic [7:0] y);
  assign y = 8'h0a;
endmodule

module cfg_cell_b(output logic [7:0] y);
  assign y = 8'h0b;
endmodule

module cfg_cell_c(output logic [7:0] y);
  assign y = 8'h0c;
endmodule

module cfg_cell_mid(output logic [7:0] y);
  cfg_cell_a inner(y);
endmodule

module test_config_cell_use;
  logic [7:0] y1, y2, y3;

  cfg_cell_a u1(y1);
  cfg_cell_mid m(y2);
  cfg_cell_c u3(y3);

  initial #1 $display("u1=%h m.inner=%h u3=%h", y1, y2, y3);
endmodule

config cfg;
  design work.test_config_cell_use;
  cell cfg_cell_a use work.cfg_cell_b;
endconfig
