/*
:name: test_define_tool_option_skips_default
:description: A default definition in the source guarded by `ifndef is skipped for a macro that a tool option defines and used for one it does not (IEEE 1800-2023 Section 22.6)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.6 22.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:defines: LEVEL=2
:expected_stdout: @test_define_tool_option_skips_default.expected
*/
// IEEE 1800-2023 §22.6: `ifndef keeps its text only when the macro is not
// defined. The runner defines LEVEL with the text 2 before the first source
// (:defines:), so the default definition of LEVEL in the source is skipped,
// while DEPTH, which nothing defines before, gets its default 8 (§22.5.1).
// The test does not redefine a macro that the option defines: which of the
// two definitions a tool reads last is up to how it applies its options.

`ifndef LEVEL
`define LEVEL 1
`endif
`ifndef DEPTH
`define DEPTH 8
`endif

module test_define_tool_option_skips_default;
  initial $display("LEVEL=%0d DEPTH=%0d", `LEVEL, `DEPTH);
endmodule
