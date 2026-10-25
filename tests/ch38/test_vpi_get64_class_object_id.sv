/*
:name: test_vpi_get64_class_object_id
:description: vpi_get64 takes a property and a handle and returns the 64-bit integer property vpiObjId as PLI_INT64: the same nonzero identifier for class variables that refer to one object and for that class object, different identifiers for different objects, 0 for a null class variable, and the new identifier after a variable is assigned another object (IEEE 1800-2023 Section 38.7)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.7 37.33
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_get64_class_object_id.c
:expected_stdout: @test_vpi_get64_class_object_id.expected
*/
// IEEE 1800-2023 §38.7: vpi_get64(prop, obj) returns the value of a 64-bit
// integer property of an object, of type PLI_INT64. §37.33: vpiObjId is such
// a property ("int64:") of a class variable and of a class object; for a
// class object it identifies the object, unique among the live objects
// (detail 1), and for a class variable it is the identifier of the object
// the variable refers to, or 0 when it refers to none (detail 2).
//
// The application assigns vpi_get64 to a pointer of type
// PLI_INT64 (*)(PLI_INT32, vpiHandle), which a C++ compiler rejects when the
// routine has another type, and keeps the identifiers in PLI_INT64
// variables; the identifiers themselves are not printed, since the standard
// does not fix them. At 1, a and b refer to the first object, c to the
// second and n to none: a and b have the same nonzero identifier, which is
// also that of the class object that vpiClassObj gives for a, c has another
// nonzero one and n has 0. At 2, after b = c, b has the identifier of c and
// no longer that of a.
//
// Icarus Verilog 13.0 cannot build the application, since its sv_vpi_user.h
// does not define vpiObjId and vpiClassObj (Annex M), and Verilator 5.052
// cannot call a system task registered by a VPI application.

module test_vpi_get64_class_object_id;
  class item;
    int v;
  endclass

  item a, b, c, n;

  initial begin
    a = new();
    b = a;
    c = new();
    #1 $vt_ids;
    b = c;
    #1 $vt_ids;
  end
endmodule
