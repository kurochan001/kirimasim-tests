/*
:name: test_resetall_leaves_text_macros_usable
:description: `resetall does not affect the text macro facility, so after it a macro with arguments and a default still expands, `ifdef still sees a macro defined before it, `undef still removes that macro, and a macro defined between two `resetall directives is still defined after the second (IEEE 1800-2023 Sections 22.5 and 22.3)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5 22.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_resetall_leaves_text_macros_usable.expected
*/
// IEEE 1800-2023 §22.5: the text macro facility is not affected by
// `resetall; §22.3: `resetall sets only the directives that have a default
// value back to it, and `define has none. Before the first `resetall the
// file defines RA_SCALE, with the formal argument k whose default is 3, and
// the flag RA_FLAG. After it, `ifdef RA_FLAG still takes its first branch,
// which defines RA_SEEN as 1, `undef RA_FLAG removes the flag, and RA_LATE
// is defined; a second `resetall follows. In the module, RA_SCALE(2) uses
// the default and gives 6, RA_SCALE(2, 5) gives 10, RA_SEEN is 1, RA_FLAG
// is undefined because of the `undef, and RA_LATE is 7.

`define RA_SCALE(x, k = 3) ((x) * (k))
`define RA_FLAG
`resetall
`ifdef RA_FLAG
`define RA_SEEN 1
`else
`define RA_SEEN 0
`endif
`undef RA_FLAG
`define RA_LATE 7
`resetall

module test_resetall_leaves_text_macros_usable;
  initial begin
    $display("macro with arguments after resetall: %0d %0d", `RA_SCALE(2), `RA_SCALE(2, 5));
    $display("macro seen by ifdef after resetall: %0d", `RA_SEEN);
`ifdef RA_FLAG
    $display("macro after undef: defined");
`else
    $display("macro after undef: undefined");
`endif
    $display("macro defined between two resetall: %0d", `RA_LATE);
  end
endmodule
