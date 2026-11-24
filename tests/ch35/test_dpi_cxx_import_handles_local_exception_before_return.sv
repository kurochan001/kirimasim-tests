/*
:name: test_dpi_cxx_import_handles_local_exception_before_return
:description: A C++ implementation with C linkage catches an internal exception and returns a normal value
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.1.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dpi_cxx_import_handles_local_exception_before_return.expected
:dpi_c: @test_dpi_cxx_import_handles_local_exception_before_return.cpp
*/
module test_dpi_cxx_import_handles_local_exception_before_return;
  import "DPI-C" function int checked_cell_index(input int index);

  initial begin
    $display("normal=%0d caught=%0d after=%0d",
             checked_cell_index(2), checked_cell_index(-1), checked_cell_index(5));
  end
endmodule
