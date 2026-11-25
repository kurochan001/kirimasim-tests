/*
:name: test_dpi_and_vpi_handles_use_distinct_apis
:description: DPI and VPI obtain separate handles to an unpacked array
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.3 H.9.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_and_vpi_handles_use_distinct_apis.cpp
:vpi_c: @test_dpi_vpi_systf_handle_in_import_vpi.c
:expected_stdout: @test_dpi_and_vpi_handles_use_distinct_apis.expected
*/
module test_dpi_and_vpi_handles_use_distinct_apis;
  int values[3] /* verilator public_flat_rw */ = '{31, 17, 44};
  import "DPI-C" context function int inspect_handles(input int values[]);
  int result;

  initial begin
    result = inspect_handles(values);
    $display("dpi count=%0d vpi element=%0d", result / 1000, result % 1000);
    $finish(0);
  end
endmodule
