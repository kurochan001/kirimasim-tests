/*
:name: test_defines_from_metadata
:description: Macros that the tool defines before the first source, one with a text and one without, are expanded and tested by `ifdef as macros of `define are (IEEE 1800-2023 Section 22.5.1)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.1 22.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:defines: COUNT=3 FAST
:expected_stdout: @test_defines_from_metadata.expected
*/
// IEEE 1800-2023 §22.5.1: a use of a text macro is replaced by its text.
// §22.6: `ifdef and `ifndef test whether a macro is defined. The runner
// defines COUNT with the text 3 and FAST without a text (:defines:), as an
// option of the tool does before the first source file, and nothing defines
// SLOW.

module test_defines_from_metadata;
  initial begin
    $display("COUNT=%0d", `COUNT);
`ifdef FAST
    $display("FAST is defined");
`endif
`ifndef SLOW
    $display("SLOW is not defined");
`endif
  end
endmodule
