/*
:name: test_undefineall_clears_nested_macro_expansion
:description: Undefineall clears both a macro and a macro whose expansion refers to it (IEEE 1800-2023 Section 22.5.3)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_undefineall_clears_nested_macro_expansion.expected
*/
// IEEE 1800-2023 22.5.3: All source macro definitions disappear together;
// neither a direct definition nor a forwarding macro survives.
// Oracle checks: Icarus Verilog 13.0 does not reproduce the clause-derived
// output.

`define DEPTH_INNER 21
`define DEPTH_OUTER `DEPTH_INNER
`undefineall
module test_undefineall_clears_nested_macro_expansion;
  initial begin
`ifdef DEPTH_INNER
    $display("inner=present");
`else
    $display("inner=absent");
`endif
`ifdef DEPTH_OUTER
    $display("outer=present");
`else
    $display("outer=absent");
`endif
  end
endmodule
