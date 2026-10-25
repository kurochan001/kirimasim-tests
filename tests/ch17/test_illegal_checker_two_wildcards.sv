/*
:name: test_illegal_checker_two_wildcards
:description: The token pair .* can appear at most once in the port connections of a checker instance (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance names the .* wildcard twice
:expected_stderr_regex: test_illegal_checker_two_wildcards\.sv:32:
*/
// IEEE 1800-2023 17.3: the .* token pair shall appear at most once in a list of
// checker port connections. The instance below names it twice, so the
// connection list is not legal. The named connection .a that comes before them
// is legal, as are the formals and the rest of the design.
// Icarus Verilog 13.0 does not support checkers at all. Verilator 5.052
// supports the unit-level checker and rejects the second wildcard with an
// error on that line (docs are not edited here; see notes/chk-simdiff.md).

`timescale 1ns/1ns

checker wild_pair(input logic a, output logic y);
  assign y = a;
endchecker : wild_pair

module test_illegal_checker_two_wildcards;
  logic a = 1'b1;
  logic y;

  wild_pair u(.a(a), .*, .*);   // illegal: .* twice

  initial #1 $display("y=%b", y);
endmodule
