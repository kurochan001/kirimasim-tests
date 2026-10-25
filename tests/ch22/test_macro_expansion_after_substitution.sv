/*
:name: test_macro_expansion_after_substitution
:description: Macro uses in the text or in a default of a macro are expanded when the macro is used, after the outer substitution, with the definitions in force then; a macro use given as an actual argument is expanded only after it is substituted, so its commas do not split arguments, and its expansion brings no new formal names for the outer macro; and directives in macro text take effect only when the macro is used (IEEE 1800-2023 Section 22.5.1)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.1 22.5.2 22.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_macro_expansion_after_substitution.expected
*/
// IEEE 1800-2023 §22.5.1: macro uses in macro text and in argument defaults
// are substituted after the outer macro is substituted, not when it is
// defined; a macro use in an actual argument is expanded only after it has
// been substituted into the outer text; the expansion of a macro use given as
// an actual or a default does not add new uses of the formal arguments of the
// outer macro; and directives in macro text are ignored until the macro is
// used. INNER is 1 when OUTER and WITH_DEFAULT are defined and 4 when they
// are used, so they give 14 and 12. CAT(`PAIR) has one actual, so b takes its
// default and the result is the 24 bits 03 04 00. DIFF of two DIFF uses gives
// ((q - 1) - (10 - p)), 109 for p = 100 and q = 20; the p and q that the inner
// uses bring are not replaced again. LATE_VALUE is defined, and VICTIM
// undefined (22.5.2), only where MAKE_LATE and DROP_VICTIM are used, as
// `ifdef (22.6) shows before and after each use.

`define INNER 1
`define OUTER (`INNER + 10)
`define WITH_DEFAULT(a = `INNER) (a * 3)
`define PAIR 8'd3, 8'd4
`define CAT(a, b = 8'h00) {a, b}
`define DIFF(p, q) (p - q)
`define MAKE_LATE `define LATE_VALUE 70
`define DROP_VICTIM `undef VICTIM
`define VICTIM 5
`undef INNER
`define INNER 4

module test_macro_expansion_after_substitution;
  localparam int p = 100, q = 20;
`ifdef LATE_VALUE
  int late_before = 1;
`else
  int late_before = 0;
`endif
`MAKE_LATE
`ifdef LATE_VALUE
  int late_after = `LATE_VALUE;
`else
  int late_after = 0;
`endif
`ifdef VICTIM
  int victim_before = 1;
`else
  int victim_before = 0;
`endif
`DROP_VICTIM
`ifdef VICTIM
  int victim_after = 1;
`else
  int victim_after = 0;
`endif

  initial begin
    $display("macro in text: %0d, in default: %0d", `OUTER, `WITH_DEFAULT());
    $display("macro in actual: bits=%0d value=%h", $bits(`CAT(`PAIR)), `CAT(`PAIR));
    $display("nested actuals: %0d", `DIFF(`DIFF(q, 1), `DIFF(10, p)));
    $display("define in text: before=%0d after=%0d", late_before, late_after);
    $display("undef in text: before=%0d after=%0d", victim_before, victim_after);
  end
endmodule
