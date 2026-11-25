/*
:name: test_dpi_context_requires_separate_vpi_activation
:description: A DPI context import reads a variable with separately enabled VPI
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.3 H.9.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_context_requires_separate_vpi_activation.c
:vpi_c: @test_dpi_vpi_systf_handle_in_import_vpi.c
:expected_stdout: @test_dpi_context_requires_separate_vpi_activation.expected
*/
module test_dpi_context_requires_separate_vpi_activation;
  int marker /* verilator public_flat_rw */ = 417;
  import "DPI-C" context function int read_vpi_marker(output int context_active,
                                                     output int released);
  int active, released, value;

  initial begin
    value = read_vpi_marker(active, released);
    $display("context=%0d value=%0d released=%0d", active, value, released);
    $finish(0);
  end
endmodule
