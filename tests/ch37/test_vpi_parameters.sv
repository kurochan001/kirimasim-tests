/*
:name: test_vpi_parameters
:description: The parameters of an instance give their values at the end of elaboration, overridden ones included, whether they are local, their explicit range or none, and their default expressions, and the parameter assignments of the instance give the overridden parameter and the new value (IEEE 1800-2023 Section 37.28)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.28 23.10 6.20.2 6.20.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_parameters.c
:expected_stdout: @test_vpi_parameters.expected
*/
// IEEE 1800-2023 §37.28: vpi_iterate(vpiParameter, instance) gives the
// parameters of u. vpi_get_value gives the value at the end of elaboration
// (detail 1): W and P are overridden by the instance (23.10), and the local
// parameter L follows W (6.20.4). vpiLocalParam tells L apart. Only P has an
// explicit range; for the others vpiLeftRange and vpiRightRange give NULL
// (detail 5). vpiExpr gives the default expression of a value parameter, 4 for
// W and 8'h0f for P (detail 3). vpi_iterate(vpiParamAssign, instance) gives
// the overrides, whose vpiLhs is the overridden parameter (detail 4) and whose
// vpiRhs is the new value. The application sorts both lists by name.

module pm_sub #(parameter W = 4, parameter [7:0] P = 8'h0f, parameter real R = 1.5);
  localparam L = W * 2;
  logic [L-1:0] x;
  initial x = P;
endmodule

module test_vpi_parameters;
  pm_sub #(.W(8), .P(8'ha5)) u();

  initial #1 $vt_parameters;
endmodule
