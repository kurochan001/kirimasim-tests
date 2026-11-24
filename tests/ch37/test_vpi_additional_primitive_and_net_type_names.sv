/*
:name: test_vpi_additional_primitive_and_net_type_names
:description: VPI subtype queries return both the integer constants and names for primitives and nets
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.2 37.16 37.35
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_additional_primitive_and_net_type_names.expected
:vpi_c: @test_vpi_additional_primitive_and_net_type_names.c
*/
module test_vpi_additional_primitive_and_net_type_names;
  reg drive = 1;
  wire wire_result;
  wand wand_result;
  buf active_buf(wire_result, drive);
  not inverter(wand_result, drive);
  initial #1 $finish;
endmodule
