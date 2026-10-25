/*
:name: test_illegal_if_matches_pattern_of_other_type
:description: in e matches p, the expression and the pattern have the same type (IEEE 1800-2023 Section 12.6.2)
:tags: ch12
:type: elaboration
:lrm: 1800-2023 12.6.2 12.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the int expression k is matched against a tagged union pattern
:expected_stderr_regex: test_illegal_if_matches_pattern_of_other_type\.sv:31:
*/
// IEEE 1800-2023 §12.6.2, §12.6: in each "e matches p" clause of an if
// predicate, e and p shall have the same statically known type. The first if
// matches the tagged union v against a pattern of its type. The second matches
// k, an int, against the tagged union pattern tagged Val .x, whose type is
// not int.
// Icarus Verilog 13.0 and Verilator 5.052 do not support tagged unions.

module test_illegal_if_matches_pattern_of_other_type;
  typedef union tagged {
    void None;
    int  Val;
  } opt_t;
  opt_t v;
  int k = 5;
  initial begin
    v = tagged Val 2;
    if (v matches tagged Val .x) $display("v %0d", x);
    if (k matches tagged Val .x) $display("k %0d", x);   // illegal
  end
endmodule
