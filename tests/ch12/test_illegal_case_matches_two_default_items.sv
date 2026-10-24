/*
:name: test_illegal_case_matches_two_default_items
:description: a pattern-matching case statement cannot have two default items (IEEE 1800-2023 Section 12.5)
:tags: ch12
:type: elaboration
:lrm: 1800-2023 12.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the pattern-matching case statement has two default items
:expected_stderr_regex: test_illegal_case_matches_two_default_items\.sv:32:
*/
// IEEE 1800-2023 §12.5: more than one default item in one case statement is
// illegal; the rule covers the case_pattern_item form of the default item used
// by a pattern-matching case statement (12.6.1), which here has two.
// Icarus Verilog 13.0 does not support tagged unions, and Verilator 5.052
// does not support their void members; both report errors on other lines.

module test_illegal_case_matches_two_default_items;
  typedef union tagged {
    void None;
    int  Val;
  } opt_t;
  opt_t o;
  initial begin
    o = tagged Val 4;
    case (o) matches
      tagged None: $display("none");
      default: $display("first default");
      tagged Val .n: $display("value %0d", n);
      default: $display("second default");   // illegal
    endcase
  end
endmodule
