/*
:name: test_vpi_user_h_supplies_default_external_linkage
:description: The VPI header supplies default function and startup array linkage
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.7 K.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_user_h_supplies_default_external_linkage.expected
:expected_exit: 0
:vpi_c: @test_vpi_user_h_supplies_default_external_linkage.c
*/
module test_vpi_user_h_supplies_default_external_linkage;
  initial #1 $finish;
endmodule
