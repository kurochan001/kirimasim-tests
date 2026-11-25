/*
:name: test_vpi_interface_and_module_specify_paths_distinguish_legacy_owner
:description: The legacy module link is null for interface paths and returns the owner for module paths
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.6 37.39 A.1.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: specify_owner_top
:expected_stdout: @test_vpi_interface_and_module_specify_paths_distinguish_legacy_owner.expected
:vpi_c: @test_vpi_interface_specify_path_ownership.c
*/
`timescale 1ns/1ns

interface timing_interface(input wire a, output wire y);
  assign y = a;
  specify
    (a => y) = 5;
  endspecify
endinterface

module timing_module(input wire a, output wire y);
  assign y = a;
  specify
    (a => y) = 3;
  endspecify
endmodule

module specify_owner_top;
  wire yi, yj, ym;
  timing_interface left(1'b0, yi);
  timing_interface right(1'b1, yj);
  timing_module control(1'b0, ym);

  initial begin
    #1 $vt_specify_owner("specify_owner_top.left");
    $vt_specify_owner("specify_owner_top.control");
    $vt_specify_owner("specify_owner_top.right");
  end
endmodule
