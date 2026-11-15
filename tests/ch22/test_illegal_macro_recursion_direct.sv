/*
:name: test_illegal_macro_recursion_direct
:description: A macro whose text contains a use of itself is a recursive macro, and using it is an error (IEEE 1800-2023 Section 22.5.1)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.5.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the use of GROW expands to text that contains another use of GROW, a recursive macro
:expected_stderr_regex: test_illegal_macro_recursion_direct\.sv:(24|30):
*/
// IEEE 1800-2023 §22.5.1: it is an error for a macro to expand, directly or
// through other macros, to text that contains another use of the same macro.
// The text of GROW uses GROW, so its expansion never ends. The clause does not
// say whether the error belongs to the definition or to the use, so the error
// may be reported on either line. TWICE uses ONE twice, which nests macro uses
// without coming back to the macro being expanded, and is legal.
// The 5.054 release of Verilator reports a recursive macro on the line of the
// use. Icarus Verilog 13.0 stops there with a parser message that its memory
// is exhausted, which does not name the rule, so it is not counted.

`define GROW (1 + `GROW)
`define ONE 1
`define TWICE (`ONE + `ONE)

module test_illegal_macro_recursion_direct;
  localparam int OK = `TWICE;
  localparam int BAD = `GROW;   // illegal: GROW expands to a use of itself
endmodule
