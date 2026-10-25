/*
:name: test_illegal_tagged_expression_without_context_type
:description: the type of a tagged union expression has to be known from its context, as from an assignment target or a cast (IEEE 1800-2023 Section 11.9)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the tagged union expression tagged Valid 5 is an argument of $display, where no context gives its type
:expected_stderr_regex: test_illegal_tagged_expression_without_context_type\.sv:35:
*/
// IEEE 1800-2023 §11.9: the type of a tagged union expression shall be known
// from its context, for example the variable on the left-hand side of an
// assignment, a cast, or an enclosing expression whose type is known. The
// assignment to vi, the cast vint_t'(...) and the conditional operator in
// an assignment to vi give the type, which is legal; an argument of $display
// does not.
// Icarus Verilog 13.0 does not parse tagged unions, and the 5.052 release
// of Verilator reports them as unsupported.

module test_illegal_tagged_expression_without_context_type;
  typedef union tagged {
    void Invalid;
    int Valid;
  } vint_t;
  vint_t vi;
  bit sel = 1'b1;

  initial begin
    vi = tagged Valid 3;
    vi = vint_t'(tagged Valid 4);
    vi = sel ? tagged Valid 6 : tagged Invalid;
    $display("%p", tagged Valid 5);   // illegal: no type from the context
  end
endmodule
