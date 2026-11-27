/*
:name: test_config_precompiled_cells
:description: A configuration binds a hierarchy from separately compiled cells and selects different descendants of one reused cell
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.5 33.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: precompiled_crossed
:expected_exit: 0
:expected_stdout: @test_config_precompiled_cells.expected
:files: precompiled_cells/libraries.map precompiled_cells/configurations.sv precompiled_cells/worker.sv precompiled_cells/west.sv precompiled_cells/east.sv
*/
module test_config_precompiled_cells(output wire [7:0] west_value, east_value);
  phase_worker west(.value(west_value));
  phase_worker east(.value(east_value));

`ifndef YOSYS
  initial begin
    #1;
    $display("west=%h east=%h", west_value, east_value);
    $finish;
  end
`endif
endmodule
