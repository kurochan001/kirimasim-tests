/*
:name: test_dpi_legacy_vendor_sizes_allocate_two_state_and_four_state_buffers
:description: The legacy DPI size queries supply enough vendor storage for each packed representation
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.4 H.14.2 I.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dpi_legacy_vendor_sizes_allocate_two_state_and_four_state_buffers.expected
:dpi_c: @test_dpi_legacy_vendor_sizes_allocate_two_state_and_four_state_buffers.c
*/
module test_dpi_legacy_vendor_sizes_allocate_two_state_and_four_state_buffers;
  import "DPI-C" function int check_legacy_sizes();

  initial $display("allocated legacy buffers=%0d", check_legacy_sizes());
endmodule
