/*
:name: test_vpi_param_assign_defparam
:description: A defparam is iterated from the module that contains it and gives that module, the overridden parameter as vpiLhs and the new value as vpiRhs; the parameter assignments of an instance or interface instance give their instance as module and scope, the overridden value or type parameter as vpiLhs and the new value or type as vpiRhs (IEEE 1800-2023 Section 37.28)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.28 23.10 23.10.1 23.10.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_param_assign_defparam.c
:expected_stdout: @test_vpi_param_assign_defparam.expected
*/
// IEEE 1800-2023 §37.28: a module iterates its def params (23.10.1), and a
// def param leads to its module, to the overridden parameter with vpiLhs and
// to the new value with vpiRhs. The defparam in the top module overrides D of
// u2, so vpi_iterate(vpiDefParam) of the top module gives it and that of u2
// none, its vpiLhs is u2.D and its vpiRhs the expression 33, the value of
// u2.D. A module or scope iterates its param assigns (23.10.2), each leading
// back to its module and scope, to the overridden parameter with vpiLhs
// (detail 4, a value parameter W or the type parameter T) and to the new
// value or type with vpiRhs (12, and the shortint typespec). u2 has no
// parameter value assignment (a defparam is not one); the interface instance
// ifc, a scope that is not a module, has one, for N. Assignments are listed
// sorted by the name of the parameter.

interface test_vpi_param_assign_defparam_if #(parameter int N = 2) ();
endinterface

module test_vpi_param_assign_defparam_sub #(parameter int W = 4, parameter type T = int,
                                            parameter int D = 1) ();
  T tv;
endmodule

module test_vpi_param_assign_defparam;
  test_vpi_param_assign_defparam_sub #(.W(12), .T(shortint)) u1();
  test_vpi_param_assign_defparam_sub u2();
  test_vpi_param_assign_defparam_if #(.N(7)) ifc();

  defparam u2.D = 33;

  initial #1 $vt_assigns;
endmodule
