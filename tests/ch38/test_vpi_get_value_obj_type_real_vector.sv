/*
:name: test_vpi_get_value_obj_type_real_vector
:description: vpi_get_value with vpiObjTypeVal fills in the value of a real variable as vpiRealVal, of a vector as vpiVectorVal and of a scalar as vpiScalarVal or vpiStrengthVal, and changes the format field to say so (IEEE 1800-2023 Section 38.15)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.15 38.36.2 38.36.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_get_value_obj_type_real_vector.c
:expected_stdout: @test_vpi_get_value_obj_type_real_vector.expected
*/
// IEEE 1800-2023 §38.15: when the format field is vpiObjTypeVal,
// vpi_get_value fills in the value in the format that fits the object and
// changes the format field to it: vpiRealVal for a real, vpiVectorVal for a
// vector, and vpiScalarVal or vpiStrengthVal for a scalar. The application
// reads r, the 12-bit vec and the scalar s in a cbAfterDelay callback at 1
// (38.36.2), registered at the start of the simulation (38.36.3), and prints
// the format it gets back and the value in it.

`timescale 1ns/1ns

module test_vpi_get_value_obj_type_real_vector;
  real r;
  logic [11:0] vec;
  logic s;

  initial begin
    r = -2.25;
    vec = 12'ha5c;
    s = 1'b1;
    #2 $finish;
  end
endmodule
