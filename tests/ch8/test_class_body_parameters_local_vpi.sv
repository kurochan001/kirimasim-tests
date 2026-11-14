/*
:name: test_class_body_parameters_local_vpi
:description: Value and type parameters declared with the parameter keyword as class items are local parameters, in a class with a parameter port list and in one without, which vpiLocalParam of the class definition reports, while the parameters of the port list are not (IEEE 1800-2023 Section 8.3)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.3 37.31
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_class_body_parameters_local_vpi.c
:expected_stdout: @test_class_body_parameters_local_vpi.expected
*/
// IEEE 1800-2023 §8.3: in a parameter declaration that is a class item, the
// keyword parameter means the same as localparam (footnote 7 of Syntax 8-1).
// §37.31: the vpiParameter iteration of a class defn returns the parameters
// of its parameter port list and those declared in its body as class items,
// and vpiLocalParam (37.28) is TRUE for the latter.
// ported_c has the value parameter P and the type parameter PT in its port
// list. Its body declares, with the keyword parameter, the value parameter
// B, the two value parameters C1 and C2 in one declaration and the type
// parameter BT, and with localparam the value parameter L. plain_c has no
// port list and declares the value parameter N and the type parameter NT
// with the keyword parameter. The VPI application $vt_class_param_flags
// prints, for each class defn, the name and the vpiLocalParam flag of every
// parameter, sorted by name: 1 for each body parameter and 0 for P and PT.
// An implementation that kept the body parameters declared with parameter
// overridable would print 0 for B, BT, C1, C2, N and NT.
// Icarus Verilog 13.0 does not support parameterized classes, and the
// 5.054 release of Verilator does not know the system task of the VPI
// application, so the expected output follows the cited clauses alone.

module test_class_body_parameters_local_vpi;
  class ported_c #(int P = 1, type PT = int);
    parameter int B = 2;
    parameter int C1 = 3, C2 = 4;
    parameter type BT = byte;
    localparam int L = 5;
    PT pv;
    BT bv;
  endclass

  class plain_c;
    parameter int N = 6;
    parameter type NT = shortint;
    NT nv;
  endclass

  ported_c #(7, longint) h1;
  plain_c h2;

  initial #1 $vt_class_param_flags;
endmodule
