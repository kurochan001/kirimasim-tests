/*
:name: test_generate_case_on_type
:description: A case generate construct whose expression and items are type references selects only the arm that matches the type (IEEE 1800-2023 Section 27.5)
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.5 6.23 6.22.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_case_on_type.expected
*/
// IEEE 1800-2023 §6.23: type references can be compared in a case generate
// construct (27.5). Only the arm whose type matches the expression's type
// (6.22.1) is generated: for a type parameter bit [12:0] that is the arm
// bit [12:0], and for int it is the default arm, since int does not match
// shortint or bit [12:0].

module type_dispatch #(parameter type T = int, parameter int ID = 0) ();
  case (type(T))
    type(real): initial #(ID) $display("%0d: real", ID);
    type(shortint): initial #(ID) $display("%0d: shortint", ID);
    type(bit [12:0]): initial #(ID) $display("%0d: bit [12:0]", ID);
    default: initial #(ID) $display("%0d: default", ID);
  endcase
endmodule

module test_generate_case_on_type;
  bit [12:0] a_bus;
  type_dispatch #(type(a_bus), 1) d13 ();
  type_dispatch #(int, 2) dint ();
  type_dispatch #(shortint, 3) dshort ();
endmodule
