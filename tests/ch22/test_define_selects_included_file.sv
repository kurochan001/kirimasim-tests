/*
:name: test_define_selects_included_file
:description: A macro defined by a tool option chooses with `ifdef which of two files in an include directory is included (IEEE 1800-2023 Section 22.6)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.6 22.4 22.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:defines: USE_FAST
:incdirs: incdirs_select_ch22
:expected_stdout: @test_define_selects_included_file.expected
*/
// IEEE 1800-2023 §22.6: `ifdef keeps the text of the branch whose macro is
// defined, and only an `include (§22.4) in kept text is processed. The runner
// defines USE_FAST (:defines:) and gives the include directory (:incdirs:), so
// select_fast.svh is included and select_slow.svh, which would define the macro
// with another text, is not.

`ifdef USE_FAST
`include "select_fast.svh"
`else
`include "select_slow.svh"
`endif

module test_define_selects_included_file;
  initial $display("speed=%s", `SPEED);
endmodule
