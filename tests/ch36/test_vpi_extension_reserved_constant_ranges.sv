/*
:name: test_vpi_extension_reserved_constant_ranges
:description: Public VPI constants use their assigned ranges and may share numbers across categories
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.7 M.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_extension_reserved_constant_ranges.c
:expected_stdout: @test_vpi_extension_reserved_constant_ranges.expected
*/
module test_vpi_extension_reserved_constant_ranges;
  initial #1 $display("reserved constants observed");
endmodule
