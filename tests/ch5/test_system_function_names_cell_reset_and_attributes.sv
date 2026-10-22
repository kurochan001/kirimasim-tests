/*
:name: test_system_function_names_cell_reset_and_attributes
:description: Case sensitive dollar-containing system functions inspect cell tagging and numeric instance attributes (IEEE 1800-2023 Section 5.6.3)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.6.3 22.10 37.83 38.37.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_system_function_names_cell_reset_and_attributes.c
:expected_stdout: @test_system_function_names_cell_reset_and_attributes.expected
*/
// IEEE 1800-2023 5.6.3 22.10 37.83 38.37.1: Two registered function names
// differ only in case. Each computes a value from a numeric instance attribute
// and the cell flag, with resetall ending the cell declaration region.
// Oracle checks: Icarus Verilog 13.0 does not build this case. The 5.052
// release does not build this case.

`celldefine
module marked_cell; endmodule
`resetall
module plain_cell; endmodule
module test_system_function_names_cell_reset_and_attributes;
  (* weight = 5 *) marked_cell u();
  (* weight = 9 *) plain_cell v();
  initial #1 $display("marked=%0d plain=%0d", $Depth$probe_7(), $depth$probe_7());
endmodule
