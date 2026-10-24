/*
:name: test_resetall_restores_defaults_keeps_macros
:description: `resetall sets `default_nettype, `unconnected_drive and `celldefine back to their defaults, while text macros, including one from an included file, keep their definitions and an undefined macro stays undefined (IEEE 1800-2023 Sections 22.3 and 22.5)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.3 22.5 22.8 22.9 22.10 22.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:files: resetall_keeps_macros_helper.svh
:vpi_c: @test_resetall_restores_defaults_keeps_macros.c
:expected_stdout: @test_resetall_restores_defaults_keeps_macros.expected
*/
// IEEE 1800-2023 §22.3: `resetall sets every compiler directive that has a
// default back to it, and directives without a default, such as `define and
// `include, are not affected; §22.5: text macros are not affected by
// `resetall. Before the `resetall the file defines RESETALL_KEEP_WIDTH,
// defines and undefines RESETALL_GONE, includes a file that defines
// RESETALL_FROM_INCLUDE, and sets `default_nettype tri0, `unconnected_drive
// pull1 and `celldefine. Afterwards the two defined macros still expand to
// their values and RESETALL_GONE is still undefined. The defaults that come
// back are those of §22.8 (implicit nets are wire), §22.9 (`resetall acts
// as `nounconnected_drive) and §22.10 (`resetall acts as `endcelldefine):
// the module defined before the `resetall pulls its open input up, its
// implicit net is a tri0 driven only by z, which reads 0, and its instances
// are cell instances; the module defined after it leaves its open input
// floating, its implicit net, driven only by z, is a wire that reads z, and
// its instances are not cells. The values are printed at time 1, after the
// continuous assignments have settled, and the VPI task $vt_cells prints the
// property vpiCellInstance of four instances (37.10).

`define RESETALL_KEEP_WIDTH 4
`define RESETALL_GONE 1
`undef RESETALL_GONE
`include "resetall_keeps_macros_helper.svh"
`default_nettype tri0
`unconnected_drive pull1
`celldefine

module resetall_before_leaf(input wire in_a, output wire out_y);
  assign out_y = in_a;
endmodule

module resetall_z_source(output wire z_out);
  assign z_out = 1'bz;
endmodule

module resetall_before_holder;
  resetall_z_source s(.z_out(n_before));
endmodule

`resetall

module resetall_after_leaf(input wire in_a, output wire out_y);
  assign out_y = in_a;
endmodule

module resetall_after_holder;
  resetall_z_source s(.z_out(n_after));
endmodule

module test_resetall_restores_defaults_keeps_macros;
  wire before_y, after_y;
  logic [`RESETALL_KEEP_WIDTH-1:0] kept = '1;

  resetall_before_leaf u_before(.in_a(), .out_y(before_y));
  resetall_after_leaf u_after(.in_a(), .out_y(after_y));
  resetall_before_holder h_before();
  resetall_after_holder h_after();

  initial begin
    #1;
    $display("macro defined before resetall: width %0d", $bits(kept));
`ifdef RESETALL_GONE
    $display("macro undefined before resetall: defined");
`else
    $display("macro undefined before resetall: undefined");
`endif
    $display("macro from the included file: %0d", `RESETALL_FROM_INCLUDE);
    $display("open input of the module before resetall: %b", before_y);
    $display("open input of the module after resetall: %b", after_y);
    $display("implicit net before resetall: %b", h_before.n_before);
    $display("implicit net after resetall: %b", h_after.n_after);
    $vt_cells;
  end
endmodule
