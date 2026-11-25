/*
:name: test_library_contains_all_seven_cell_categories
:description: One named library supplies module, interface, program, checker, primitive, package and configuration cells
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.10 33.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_library_contains_all_seven_cell_categories.expected
:files: library_cell_categories/providers.map library_cell_categories/provider.sv
*/
module test_library_contains_all_seven_cell_categories;
  wire [7:0] module_value;
  wire [7:0] program_value;
  wire gate_value;
  provider_module mod_unit(module_value);
  provider_interface intf();
  provider_program prog_unit(program_value);
  provider_udp udp_unit(gate_value, 1'b0);
  localparam int package_value = provider_pkg::value;

  initial #1 $display("module=%0d interface=%0d program=%0d primitive=%b package=%0d",
                      module_value, intf.value, program_value, gate_value, package_value);
endmodule

module library_cells_decoy;
  initial $display("selected work instead");
endmodule

config provider_cfg;
  design work.library_cells_decoy;
  default liblist work;
endconfig
