/*
:name: test_dpi_cxx_function_and_task_boundaries
:description: C linkage and local exception handling for C++ DPI functions and tasks
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.1.6 35.5.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: dpi_cxx_boundary/native.cpp
:dpi_c: @test_dpi_cxx_function_and_task_boundaries.cpp
:expected_stdout: @test_dpi_cxx_function_and_task_boundaries.expected
*/
module test_dpi_cxx_function_and_task_boundaries;
  import "DPI-C" function int cxx_boundary_function(input int index, output int caught);
  import "DPI-C" task cxx_boundary_task(input int index, output int value, output int caught);
  int value, caught;

  initial begin
    value = cxx_boundary_function(-1, caught);
    $display("function value=%0d caught=%0d", value, caught);
    cxx_boundary_task(-2, value, caught);
    $display("task value=%0d caught=%0d", value, caught);
    value = cxx_boundary_function(4, caught);
    $display("function after=%0d caught=%0d", value, caught);
    cxx_boundary_task(5, value, caught);
    $display("task after=%0d caught=%0d", value, caught);
    $finish(0);
  end
endmodule
