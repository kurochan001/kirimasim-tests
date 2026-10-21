/*
:name: test_config_cell_parameter
:description: A cell rule of a config can bind every instance of a cell to another cell with parameter overrides (IEEE 1800-2023 Sections 33.4.3 and 33.4.1.4)
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.4.3 33.4.1.4 33.4.1.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_config_cell_parameter
:expected_stdout: @test_config_cell_parameter.expected
*/
// IEEE 1800-2023 §33.4.1.4: a cell rule binds every instance of the selected
// cell to the cell named by use. §33.4.3: the use may give the parameters of
// the bound instances, so both instances of cfg_cell_param_a become
// cfg_cell_param_b with W = 5. §33.4.1.6: the default liblist work binds them
// through the library work. Icarus Verilog 13.0 skips config declarations;
// the 5.052 release does not support a parameter assignment in the use of a
// config.

module cfg_cell_param_a #(parameter int W = 1) (output logic [7:0] y);
  assign y = W;
endmodule

module cfg_cell_param_b #(parameter int W = 10) (output logic [7:0] y);
  assign y = W;
endmodule

module test_config_cell_parameter;
  logic [7:0] y1, y2;

  cfg_cell_param_a u1(y1);
  cfg_cell_param_a u2(y2);

  initial #1 $display("u1=%0d u2=%0d", y1, y2);
endmodule

config cfg;
  design work.test_config_cell_parameter;
  default liblist work;
  cell cfg_cell_param_a use work.cfg_cell_param_b #(.W(5));
endconfig
