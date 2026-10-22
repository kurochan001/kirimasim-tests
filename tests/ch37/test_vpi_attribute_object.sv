/*
:name: test_vpi_attribute_object
:description: An attribute on a module instance is a VPI vpiAttribute object with its name and value, and vpiDefAttribute is false (IEEE 1800-2023 Section 37.83)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.83
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_attribute_object.c
:expected_stdout: @test_vpi_attribute_object.expected
*/
// IEEE 1800-2023 §37.83: an attribute is a vpiAttribute object whose vpiName
// is the name and whose value is read with vpi_get_value(); vpiDefAttribute
// says whether it is on a definition or an instance. The attribute below is on
// the instance u, so vpiDefAttribute is false, and the application prints the
// name, the string value and the flag from the handle of u.

module leaf;
endmodule

module test_vpi_attribute_object;
  (* note = "hello" *) leaf u();

  initial #1 $vt_report;
endmodule
