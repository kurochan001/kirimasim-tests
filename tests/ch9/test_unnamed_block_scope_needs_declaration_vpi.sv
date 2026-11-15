/*
:name: test_unnamed_block_scope_needs_declaration_vpi
:description: An unnamed begin or fork is a hierarchy scope only when it directly declares something: through VPI such a block is the scope of a system task call inside it and gives its variable through vpiVariables, while an unnamed block without a declaration is skipped in the vpiScope chain (IEEE 1800-2023 Section 9.3.4)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.3.4 37.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_unnamed_block_scope_needs_declaration_vpi.c
:expected_stdout: @test_unnamed_block_scope_needs_declaration_vpi.expected
*/
// IEEE 1800-2023 §9.3.4: a named block always creates a new hierarchy
// scope, and an unnamed block creates one, which has no name, only when it
// directly contains a block item declaration. §37.12 (detail 1) says the
// same for VPI: such an unnamed begin or fork is a scope (vpiBegin or
// vpiFork), one without a declaration is not, and a scope gives its
// variables through vpiVariables. The VPI application registers
// $vt_where(label), which follows vpiScope from the call (§37.42) up to the
// module, printing each scope and then the variables of the first one.
// - A: the unnamed begin declares ka, so it is the scope of the call.
// - B: the outer unnamed begin and the inner unnamed begin declare nothing,
//   so the scope of the call is the named begin nb between them.
// - C: the unnamed fork declares kf, so it is the scope of the call.
// - D: the unnamed fork declares nothing, so the scope is the module, which
//   has no variables of its own.
// - E: the outer unnamed begin only contains the inner one, which declares
//   ki directly, so only the inner one is a scope.
// If every unnamed block were a scope, B, D and E would show more begin and
// fork entries; if none were, A, C and E would show the module, with ka, kf
// and ki among its variables. The calls run at different times, so the
// order of the lines is fixed.
// Icarus Verilog 13.0 skips the unnamed blocks without a declaration, but
// gives the unnamed scopes of A, C and E the type vpiNamedBegin or
// vpiNamedFork with generated names such as $unm_blk_1, and returns no
// variable kf for the fork of C. The 5.054 release of Verilator does not
// run the VPI application, so the expected output follows the cited
// clauses alone.

`timescale 1ns/1ns

module test_unnamed_block_scope_needs_declaration_vpi;
  initial begin
    int ka;
    ka = 1;
    #1 $vt_where("A");
  end

  initial begin
    begin : nb
      begin
        #2 $vt_where("B");
      end
    end
  end

  initial fork
    logic kf;
    #3 $vt_where("C");
  join

  initial fork
    #4 $vt_where("D");
  join

  initial begin
    begin
      int ki;
      ki = 2;
      #5 $vt_where("E");
    end
  end
endmodule
