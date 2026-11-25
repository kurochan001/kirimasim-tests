/*
:name: test_undef_never_defined_macro_preserves_other_definitions
:description: Undefining an unknown macro permits a warning and leaves other macro definitions intact
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.2 22.5.1 22.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_undef_never_defined_macro_preserves_other_definitions.expected
*/
// tools/run_preprocessor_effects.py checks the optional diagnostic
// against the same source with the never-defined undef removed.
`define VT_REMOVE_KNOWN 11
`define VT_UNRELATED_MACRO 37
module test_undef_never_defined_macro_preserves_other_definitions;
  localparam before_removal = `VT_REMOVE_KNOWN;
`undef VT_NEVER_DEFINED_MACRO
`undef VT_REMOVE_KNOWN

  initial begin
    $display("before=%0d surviving=%0d", before_removal, `VT_UNRELATED_MACRO);
`ifdef VT_NEVER_DEFINED_MACRO
    $display("unknown macro defined");
`else
    $display("unknown macro absent");
`endif
`ifdef VT_REMOVE_KNOWN
    $display("known macro defined");
`else
    $display("known macro removed");
`endif
  end
endmodule
