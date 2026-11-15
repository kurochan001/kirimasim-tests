/*
:name: test_illegal_macro_recursion_indirect
:description: Two macros whose texts use each other are recursive, and using one of them is an error (IEEE 1800-2023 Section 22.5.1)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.5.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the use of PING expands to PONG, whose text contains another use of PING, a recursive macro
:expected_stderr_regex: test_illegal_macro_recursion_indirect\.sv:(25|26|33):
*/
// IEEE 1800-2023 §22.5.1: it is an error for a macro to expand, directly or
// through other macros, to text that contains another use of the same macro.
// PING uses PONG and PONG uses PING, so the expansion of PING comes back to
// PING through PONG. The clause does not say whether the error belongs to a
// definition or to the use, so the error may be reported on the line of
// either definition or on the line of the use. TOP uses MID, which uses LEAF:
// a chain of macro uses that does not come back to a macro being expanded.
// The 5.054 release of Verilator reports a recursive macro on the line of the
// use. Icarus Verilog 13.0 stops there with a parser message that its memory
// is exhausted, which does not name the rule, so it is not counted.

`define PING (1 + `PONG)
`define PONG (2 + `PING)
`define LEAF 3
`define MID (`LEAF + 1)
`define TOP (`MID * 2)

module test_illegal_macro_recursion_indirect;
  localparam int OK = `TOP;
  localparam int BAD = `PING;   // illegal: PING comes back to itself through PONG
endmodule
