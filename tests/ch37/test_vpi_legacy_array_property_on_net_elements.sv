/*
:name: test_vpi_legacy_array_property_on_net_elements
:description: The deprecated boolean array attribute distinguishes a packed vector from an unpacked net array element
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_legacy_array_property_on_net_elements.expected
:vpi_c: @test_vpi_legacy_array_property_on_net_elements.c
*/
module test_vpi_legacy_array_property_on_net_elements;
  wire [3:0] individual_net = 4'b1011;
  wire [3:0] array_net [4:5];
  assign array_net[4] = 4'b0101;
  assign array_net[5] = 4'b0011;
  initial #1 $finish;
endmodule
