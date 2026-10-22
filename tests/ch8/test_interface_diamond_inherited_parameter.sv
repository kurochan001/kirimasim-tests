/*
:name: test_interface_diamond_inherited_parameter
:description: The same interface parameter inherited along a diamond is a single declaration (IEEE 1800-2023 Section 8.26.6.3)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.26.6.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_diamond_inherited_parameter.expected
*/
// IEEE 1800-2023 8.26.6.3: A diamond that carries a parameter without
// redeclaring it must not cause an ambiguous name conflict.
// Oracle checks: Icarus Verilog 13.0 does not build this case.

module test_interface_diamond_inherited_parameter;
  interface class root_if; parameter int WIDTH = 19; endclass
  interface class left_if extends root_if; endclass
  interface class right_if extends root_if; endclass
  interface class diamond_if extends left_if, right_if; endclass
  initial $display("width=%0d", diamond_if::WIDTH);
endmodule
