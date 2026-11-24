/*
:name: test_unnamed_generate_vpi_name_counts_unselected_construct
:description: VPI finds the unnamed block at its textual number even if the first construct is unselected
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.6 38.21
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unnamed_generate_vpi_name_counts_unselected_construct.expected
:vpi_c: @test_unnamed_generate_vpi_name_counts_unselected_construct.c
*/
module test_unnamed_generate_vpi_name_counts_unselected_construct;
  if (0) begin : unused
    int marker = 99;
  end
  if (1) begin
    int marker = 47;
  end

  initial #1 $finish;
endmodule
