/*
:name: test_vpi_handle_identity_from_name_and_relation
:description: A vpiHandle is an opaque reference, so two handles to one object compare equal whatever way they were obtained, handles to different objects compare unequal, and the legal operation follows the object type (IEEE 1800-2023 Section 37.2, 37.3.1)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.2 37.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_handle_identity_from_name_and_relation.c
:expected_stdout: @test_vpi_handle_identity_from_name_and_relation.expected
*/
// IEEE 1800-2023 §37.2: a handle is an opaque reference to an object, and the
// operations that are legal depend on the type of the object. §37.3.1: a
// handle is obtained from a hierarchical name or from a relationship with
// another object. w is found twice by vpi_handle_by_name and once by
// iterating vpiReg from the module; all three handles compare equal with
// vpi_compare_objects, while the handle of variable v does not. vpiType gives
// vpiReg for both w and v, and the properties of w are read with the routines
// that apply to a variable.

module test_vpi_handle_identity_from_name_and_relation;
  logic w;
  logic [3:0] v;

  initial begin
    w = 1'b1;
    v = 4'ha;
    $vt_handles;
  end
endmodule
