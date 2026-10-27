/*
:name: test_35_extra_35_5_3_chain_attribute
:description: One C helper called from a context import and from a noncontext import runs in both call chains, and only the context chain may reach an exported SystemVerilog function, so the context attribute belongs to each chain and not to the C routine (IEEE 1800-2023 Section 35.5.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.3 H.9 H.6.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_35_extra_35_5_3_chain_attribute.c
:expected_stdout_verilator: @test_35_extra_35_5_3_chain_attribute.expected
*/
// IEEE 1800-2023 §35.5.3: the context property applies to each import call
// made from SystemVerilog and is not promoted transitively; it adheres to the
// calling chain, not to an individual routine, so the same routine can appear
// in a context chain and in a noncontext chain. Only a context chain may call
// an exported SystemVerilog subroutine (H.9, H.6.5).
//
// The C helper shared_level is called by both imports. The context import
// c_ctx_attr first reads its scope with svGetScope, which a context import is
// given, and then lets shared_level call the exported sv_double. The
// noncontext import c_nc_attr calls the same helper with the flag 0, so the
// helper computes 2 * v itself and makes no export call. Both calls return
// 14; the context call returns -1 if it was given no scope.
module ctx_chain_mod;
  import "DPI-C" context function int c_ctx_attr(input int v, input int use_export);
  export "DPI-C" function sv_double;

  function int sv_double(input int x);
    return 2 * x;
  endfunction
endmodule

module noncontext_chain_mod;
  import "DPI-C" c_nc_attr = function int nc_attr(input int v, input int use_export);
endmodule

module test_35_extra_35_5_3_chain_attribute;
  ctx_chain_mod u1();
  noncontext_chain_mod u2();

  initial begin
    $display("context chain %0d", u1.c_ctx_attr(7, 1));
    $display("noncontext chain %0d", u2.nc_attr(7, 0));
  end
endmodule
