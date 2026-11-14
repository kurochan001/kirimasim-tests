/*
:name: test_parameter_keyword_local_contexts_vpi
:description: A parameter declared in the body of a module, interface or program that has a parameter port list, even an empty one, in any class body, in a generate block, in a package and in the compilation unit is a local parameter, which vpiLocalParam reports, while the parameters of the port lists and of a module without one are not (IEEE 1800-2023 Section 6.20.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.1 37.28
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_parameter_keyword_local_contexts_vpi.c
:expected_stdout: @test_parameter_keyword_local_contexts_vpi.expected
*/
// IEEE 1800-2023 §6.20.1: when a module, interface, program or class
// declaration has a parameter port list, even an empty #(), the parameter
// keyword of a parameter declaration directly in its body means localparam.
// In a class body that is so with or without a port list, and in a generate
// block, a package and the compilation unit every parameter declaration is a
// local parameter. The parameters of a port list, and the body parameters of
// a module without a port list, stay nonlocal.
// §37.28: a parameter object has the property vpiLocalParam, which is true for
// a local parameter. The VPI application $vt_local_flags iterates vpiParameter
// from each scope (37.10: an instance, a generate scope, a package, which with
// vpiUnit is the compilation unit; 37.31: a class definition) and prints the
// name and the local flag of each parameter, sorted by name.
// Every declaration below uses the parameter keyword, or none in a port list;
// none uses localparam. Body parameters show local 1 in u1, u2, i1, p1, the
// classes, the generate block g, the package and the compilation unit;
// A, IA, PA, CP and the body parameter N of u3, which has no port list, show
// local 0. An implementation that kept such body parameters overridable would
// show local 0 for them.
// Oracle checks: Icarus Verilog 13.0 rejects the empty parameter port list
// and the classes with parameters as syntax errors, and the system task of
// the VPI application is unknown to the 5.054 release of Verilator, so the
// expected output follows the cited clauses alone.

parameter int test_parameter_keyword_local_contexts_vpi_unit_p = 9;

package test_parameter_keyword_local_contexts_vpi_pkg;
  parameter int PKG_P = 8;
endpackage

module test_parameter_keyword_local_contexts_vpi_ports #(parameter int A = 1) ();
  parameter int B = 2;
endmodule

module test_parameter_keyword_local_contexts_vpi_empty #() ();
  parameter int E = 3;
endmodule

module test_parameter_keyword_local_contexts_vpi_noports;
  parameter int N = 4;
  if (1) begin : g
    parameter int G = 5;
  end
endmodule

interface test_parameter_keyword_local_contexts_vpi_ifc #(parameter int IA = 1) ();
  parameter int IB = 2;
endinterface

program test_parameter_keyword_local_contexts_vpi_prg #(parameter int PA = 1) ();
  parameter int PB = 2;
endprogram

module test_parameter_keyword_local_contexts_vpi;
  class pc_c #(int CP = 1);
    parameter int CB = 2;
  endclass

  class nc_c;
    parameter int NB = 3;
  endclass

  test_parameter_keyword_local_contexts_vpi_ports u1();
  test_parameter_keyword_local_contexts_vpi_empty u2();
  test_parameter_keyword_local_contexts_vpi_noports u3();
  test_parameter_keyword_local_contexts_vpi_ifc i1();
  test_parameter_keyword_local_contexts_vpi_prg p1();

  initial #1 $vt_local_flags;
endmodule
