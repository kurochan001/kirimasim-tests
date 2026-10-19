/*
:name: test_vpi_property_sequence_decls
:description: a module gives its sequence and property declarations, and each declaration its formal arguments in declaration order, with a typespec only when typed, a direction only for local variable arguments, and the default actual as an expression (IEEE 1800-2023 Sections 37.51, 37.53)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.51 37.53 37.12 16.8 16.8.1 16.8.2 16.12.18
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_property_sequence_decls.c
:expected_stdout: @test_vpi_property_sequence_decls.expected
*/
// IEEE 1800-2023 §37.12: a scope iterates its sequence and property
// declarations. §37.53: vpiSeqFormalDecl iterates the formal arguments of a
// sequence declaration in the order they are declared (detail 1); vpiTypespec
// is NULL for an untyped formal (detail 2, §16.8); vpiExpr gives the default
// actual (detail 3); vpiDirection is vpiNoDirection unless the formal is a
// local variable argument, else its direction (detail 4, §16.8.2). §37.51
// gives the same for property declarations with vpiPropFormalDecl (details 1
// and 3 to 5), where an event formal is typed (§16.12.18).

`timescale 1ns/1ns

module test_vpi_property_sequence_decls;
  logic clk = 0, a = 0;

  sequence s_req(x, int n = 2, local output int v);
    (x, v = n) ##2 x;
  endsequence

  property p_chk(event ck, untyped p, q = 1'b1);
    @(ck) p |-> q;
  endproperty

  initial #1 $vt_decls;
endmodule
