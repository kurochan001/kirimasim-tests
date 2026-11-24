/*
:name: test_vpi_unnamed_loop_blocks_have_external_indices
:description: An unnamed generate loop exposes its external name and index through VPI
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.6 27.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_unnamed_loop_blocks_have_external_indices.expected
:vpi_c: @test_vpi_unnamed_loop_blocks_have_external_indices.c
*/
module test_vpi_unnamed_loop_blocks_have_external_indices;
  for (genvar i = 0; i < 2; i++) begin
    int marker = 31 + i;
  end

  initial #1 $vt_inspect_unnamed;
endmodule
