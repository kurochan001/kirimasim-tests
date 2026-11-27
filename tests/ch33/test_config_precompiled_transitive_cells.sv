/*
:name: test_config_precompiled_transitive_cells
:description: A separately compiled intermediate cell supplies the child paths needed to bind its descendants
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: precompiled_crossed
:expected_exit: 0
:expected_stdout: @test_config_precompiled_transitive_cells.expected
:files: precompiled_transitive/libraries.map precompiled_transitive/configurations.sv precompiled_transitive/enclosure.sv precompiled_cells/worker.sv precompiled_cells/west.sv precompiled_cells/east.sv
*/
module test_config_precompiled_transitive_cells(output wire [7:0] west_value, east_value);
  phase_enclosure middle(.west_value(west_value), .east_value(east_value));

`ifndef YOSYS
  initial begin
    #1;
    $display("west=%h east=%h", west_value, east_value);
    $finish;
  end
`endif
endmodule
