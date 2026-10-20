/*
:name: test_vpi_class_obj_id
:description: vpiObjId of a class variable is the identifier of the object it refers to, the same for two variables that share an object, different for another object and 0 for null; vpiClassObj of a null variable is NULL (IEEE 1800-2023 Section 37.33)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.33 37.32
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_class_obj_id.c
:expected_stdout: @test_vpi_class_obj_id.expected
*/
// IEEE 1800-2023 §37.33: vpiObjId identifies a live class object uniquely; for
// a class variable it is the identifier of the referenced object, or 0 when the
// variable is null. vpiClassObj of a null class variable is NULL, and
// vpiClassTypespec gives the class type the variable was declared with (37.32).
// a and b refer to one object, c to another, and n to none. The identifiers
// themselves are not printed.

`timescale 1ns/1ns

module test_vpi_class_obj_id;
  class item;
    int v;
  endclass

  item a, b, c, n;

  initial begin
    a = new();
    b = a;
    c = new();
    #1 $vt_ids;
  end
endmodule
