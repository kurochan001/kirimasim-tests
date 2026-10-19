/*
:name: test_vpi_generate_scopes
:description: A generate loop is a gen scope array whose size is its number of iterations and whose gen var is the genvar; its gen scopes are array members with their index, the genvar is a local parameter inside each, and an unnamed generate block is an implicitly declared gen scope named genblk2 (IEEE 1800-2023 Section 37.85)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.85 27.4 27.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_generate_scopes.c
:expected_stdout: @test_vpi_generate_scopes.expected
*/
// IEEE 1800-2023 §37.85: the loop generate g is a gen scope array; vpiSize
// gives its number of elements (detail 1), and vpiGenVar the genvar i. Its gen
// scopes, from vpi_iterate(vpiGenScope) or vpi_handle_by_index, are array
// members with vpiIndex the value of i, and inside each, i is a local parameter
// with that value (detail 3; 27.4). The variable r of g[1] is one bit wider
// than i. The conditional generate block has no name, so it gets the implicit
// name genblk2, being the second generate construct of the module (27.6), and
// its gen scope has vpiImplicitDecl true (detail 2); the application reaches it
// as the vpiScope of x. The application sorts the gen scopes by full name.

module test_vpi_generate_scopes;
  for (genvar i = 0; i < 3; i++) begin : g
    logic [i:0] r = '1;
  end

  if (1) begin
    logic x = 1'b1;
  end

  initial #1 $vt_generate;
endmodule
