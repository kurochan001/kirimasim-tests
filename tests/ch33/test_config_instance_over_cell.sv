/*
:name: test_config_instance_over_cell
:description: An instance rule overrides a cell rule for the instance it names (IEEE 1800-2023 Sections 33.4.1.3 and 33.4.1.4)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.4.1.3 33.4.1.4 33.4.1.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_config_instance_over_cell
:expected_stdout: @test_config_instance_over_cell.expected
*/
// IEEE 1800-2023 §33.4.1.3: an instance rule binds one instance to a cell.
// §33.4.1.4: a cell rule binds every instance of that cell. §33.4.1.6: when
// both apply to an instance, the instance rule wins. Here the cell rule sends
// both cfg_leaf_a instances to cfg_leaf_b, and the instance rule sends u2 to
// cfg_leaf_c, so u1 is b1 and u2 is c1. Icarus Verilog 13.0 skips config
// declarations, so it gives a1 for both.

module cfg_leaf_a(output logic [7:0] y);
  assign y = 8'ha1;
endmodule

module cfg_leaf_b(output logic [7:0] y);
  assign y = 8'hb1;
endmodule

module cfg_leaf_c(output logic [7:0] y);
  assign y = 8'hc1;
endmodule

module test_config_instance_over_cell;
  logic [7:0] y1, y2;

  cfg_leaf_a u1(y1);
  cfg_leaf_a u2(y2);

  initial #1 $display("u1=%h u2=%h", y1, y2);
endmodule

config cfg;
  design work.test_config_instance_over_cell;
  default liblist work;
  cell cfg_leaf_a use work.cfg_leaf_b;
  instance test_config_instance_over_cell.u2 use work.cfg_leaf_c;
endconfig
