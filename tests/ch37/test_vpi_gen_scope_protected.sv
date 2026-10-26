/*
:name: test_vpi_gen_scope_protected
:description: A generate scope exposes vpiProtected as a Boolean that is FALSE for source outside a decryption envelope (IEEE 1800-2023 Sections 37.85 and 37.3.6)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.85 37.3.6 27.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_gen_scope_protected.c
:expected_stdout: @test_vpi_gen_scope_protected.expected
*/
// IEEE 1800-2023 §37.85: a generate scope has the Boolean property
// vpiProtected (37.85 diagram). §37.3.6: vpiIsProtected is TRUE if and only if
// the object represents code contained in a decryption envelope, and
// vpiProtected is the same Boolean property under its earlier name. The
// generate block of this design is ordinary source, so the value is FALSE,
// which is 0 (37.3.1).

`timescale 1ns/1ns

module test_vpi_gen_scope_protected;
  if (1) begin : g
    wire x;
    assign x = 1'b0;
  end

  initial #1 $vt_gen;
endmodule
