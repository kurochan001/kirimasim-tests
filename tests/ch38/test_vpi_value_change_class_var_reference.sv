/*
:name: test_vpi_value_change_class_var_reference
:description: A cbValueChange callback on a class variable comes when the variable is set to refer to another object, a new one included, or to none, with a NULL value, and not when a property of its object changes or the same object is assigned again; vpiObjId of the variable then tells which object it refers to, 0 for none (IEEE 1800-2023 Section 38.36.1)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1 37.33
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_value_change_class_var_reference.c
:expected_stdout: @test_vpi_value_change_class_var_reference.expected
*/
// IEEE 1800-2023 §38.36.1: a cbValueChange callback can be placed on a class
// variable; it is called when the value of the variable changes, that is,
// when the variable comes to refer to another object, a newly constructed one
// included, or to no object. The value of a class variable is opaque, so the
// value field of the s_cb_data passed to the routine is NULL, and the
// vpiObjId property of the variable identifies the object it refers to.
// §37.33: vpiObjId of a class variable is the identifier of the object it
// refers to, unique among the live objects, or 0 when it refers to none.
//
// At time 1, in a cbAfterDelay callback registered at the start of the
// simulation, the application places a cbValueChange callback with
// vpiSimTime and vpiObjTypeVal on h. The design sets h to the object of a1 at
// 10, to the object of a2 at 12, changes a property of that object at 13,
// assigns a2 to h again at 14, sets h to null at 15, to the object of a1 at
// 16 and to a new object at 17; a1 and a2 keep their objects alive. Each
// callback prints the time, whether its value is NULL, and which object h
// refers to, found by comparing the vpiObjId of h with those of a1 and a2.
// The release 13.0 of Icarus Verilog has no vpiObjId in its sv_vpi_user.h,
// and the 5.054 release of Verilator gives no handles for class variables,
// so the expected output follows the clauses alone.

`timescale 1ns/1ns

module test_vpi_value_change_class_var_reference;
  class item;
    int x;
  endclass

  item h, a1, a2;

  initial begin
    #10 a1 = new();
    h = a1;
    #1 a2 = new();
    #1 h = a2;
    #1 h.x = 5;
    #1 h = a2;
    #1 h = null;
    #1 h = a1;
    #1 h = new();
    #1 $finish;
  end
endmodule
