/*
:name: test_dpi_matching_versions_allow_multiple_aliases_for_one_linkage
:description: Two current DPI imports may refer to the same C linkage name
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.4 35.5.4
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dpi_matching_versions_allow_multiple_aliases_for_one_linkage.expected
:dpi_c: @test_dpi_matching_versions_allow_multiple_aliases_for_one_linkage.c
*/
module test_dpi_matching_versions_allow_multiple_aliases_for_one_linkage;
  import "DPI-C" common_number = function int first_alias(input int number);
  import "DPI-C" common_number = function int second_alias(input int number);

  initial begin
    $display("first=%0d second=%0d", first_alias(4), second_alias(14));
  end
endmodule
