/*
:name: test_dpi_annex_j_isolates_versioned_dependencies
:description: Two DPI libraries select their own versioned C++ dependencies
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.1 J.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: dpi_annex_j_versions/dependency.cpp dpi_annex_j_versions/optional.cpp
:dpi_c: @test_dpi_annex_j_isolates_versioned_dependencies.cpp
:expected_stdout: @test_dpi_annex_j_isolates_versioned_dependencies.expected
*/
module test_dpi_annex_j_isolates_versioned_dependencies;
  import "DPI-C" function int annex_j_client_one();
  import "DPI-C" function int annex_j_client_two();
  int first, second;

  initial begin
    first = annex_j_client_one();
    second = annex_j_client_two();
    $display("resolved versions=%0d,%0d", first, second);
    $finish(0);
  end
endmodule
