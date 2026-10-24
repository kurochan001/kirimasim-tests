/*
:name: test_vpi_parameter_defaults_types
:description: Value and type parameters are both iterated with vpiParameter; a value parameter gives its typespec, its elaborated value, its default expression with vpiExpr and NULL bounds when it has no explicit range; a type parameter gives with vpiTypespec its elaborated type, with the typedef name of the override kept, and with vpiExpr its default type (IEEE 1800-2023 Section 37.28)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.28 37.25 6.20.2 6.20.3 23.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_parameter_defaults_types.c
:expected_stdout: @test_vpi_parameter_defaults_types.expected
*/
// IEEE 1800-2023 §37.28: the parameters group has two members, the value
// parameter (vpiParameter) and the type parameter (vpiTypeParameter, 6.20.3);
// vpi_iterate(vpiParameter, u) gives both kinds. A value parameter has a
// typespec (int for W, bit [3:0] for B). Detail 1: vpi_get_value gives the
// value at the end of elaboration, 9 for the overridden W. Detail 2:
// vpiTypespec of a type parameter gives its type at the end of elaboration
// without resolving typedef aliases: T is overridden with the typedef
// my_byte_t of byte, so it gives a byte typespec named my_byte_t; V keeps its
// default int. Detail 3: vpiExpr of a value parameter gives its default
// expression (4 for W, 4'd5 for B) and of a type parameter its default type
// (logic [3:0] for T, a logic typespec with range 3:0 and no name). Detail 5:
// W and U have no explicit range, so vpiLeftRange and vpiRightRange each give
// NULL; B has 3:0. Parameters are listed sorted by name.

module test_vpi_parameter_defaults_types_sub #(parameter int W = 4, parameter bit [3:0] B = 4'd5,
                                               parameter U = 5, parameter type T = logic [3:0],
                                               parameter type V = int) ();
  T tv;
  V vv;
endmodule

module test_vpi_parameter_defaults_types;
  typedef byte my_byte_t;

  test_vpi_parameter_defaults_types_sub #(.W(9), .T(my_byte_t)) u();

  initial #1 $vt_params;
endmodule
