/*
:name: test_vpi_interface_specify_paths_keep_interface_owner
:description: Two paths in an interface return that interface as their instance and no legacy module
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.6 37.39 A.1.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: specify_owner_top
:expected_stdout: @test_vpi_interface_specify_paths_keep_interface_owner.expected
:vpi_c: @test_vpi_interface_specify_path_ownership.c
*/
`timescale 1ns/1ns

interface timing_paths(input wire a, b, output wire y, z);
  assign y = a;
  assign z = b;
  specify
    (a => y) = 3;
    (b => z) = 5;
  endspecify
endinterface

interface without_paths(input wire a, output wire y);
  assign y = a;
endinterface

module specify_owner_top;
  wire y, z, control_y;
  timing_paths traced(1'b0, 1'b1, y, z);
  without_paths control(1'b0, control_y);

  initial begin
    #1 $vt_specify_owner("specify_owner_top.traced");
    $vt_specify_owner("specify_owner_top.control");
  end
endmodule
