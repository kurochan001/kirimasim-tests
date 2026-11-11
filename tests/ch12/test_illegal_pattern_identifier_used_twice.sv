/*
:name: test_illegal_pattern_identifier_used_twice
:description: the same pattern identifier cannot appear twice in one pattern (IEEE 1800-2023 Section 12.6)
:tags: ch12
:type: elaboration
:lrm: 1800-2023 12.6 12.6.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the identifier x is used in two positions of one pattern
:expected_stderr_regex: test_illegal_pattern_identifier_used_twice\.sv:32:
*/
// IEEE 1800-2023 §12.6: each pattern identifier is implicitly declared as a new
// variable of the pattern's scope, and an identifier cannot be used in more
// than one position of a single pattern. The first case item uses two
// different identifiers; the second uses x for both members of the structure.
// Different case items may reuse identifiers (12.6.1), as the second and third
// items do with x.
// Icarus Verilog 13.0 and Verilator 5.052 do not support tagged unions.

module test_illegal_pattern_identifier_used_twice;
  typedef union tagged {
    struct packed { logic [3:0] a, b; } Pair;
    logic [7:0] One;
  } u_t;
  u_t u;
  initial begin
    u = tagged Pair '{a: 4'd1, b: 4'd2};
    case (u) matches
      tagged Pair '{.x, .y}: $display("%0d %0d", x, y);
      tagged Pair '{.x, .x}: $display("%0d", x);   // illegal
      tagged One .x: $display("%0d", x);
    endcase
  end
endmodule
