/*
:name: test_vpi_legacy_array_property_on_module_instances
:description: The deprecated boolean array attribute distinguishes ordinary modules from instance array members
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_legacy_array_property_on_module_instances.expected
:vpi_c: @test_vpi_legacy_array_property_on_module_instances.c
*/
module fixture(input wire active);
  wire observed = active;
endmodule
module test_vpi_legacy_array_property_on_module_instances;
  fixture scalar_instance(1'b1);
  fixture instances [4:5](2'b01);
  initial #1 $finish;
endmodule
