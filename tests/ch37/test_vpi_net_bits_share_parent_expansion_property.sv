/*
:name: test_vpi_net_bits_share_parent_expansion_property
:description: Net bit handles agree with the expansion property of their vector parent
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.16 38.19
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_net_bits_share_parent_expansion_property.expected
:vpi_c: @test_vpi_net_bits_share_parent_expansion_property.c
*/
module test_vpi_net_bits_share_parent_expansion_property;
  wire [6:4] basic_net = 3'b010;
  wire scalared [6:4] advisory_net = 3'b101;
  initial #1 $finish;
endmodule
