/*
:name: test_illegal_tagged_expression_member_not_in_type
:description: the member name after tagged has to be a member of the tagged union type that the context gives (IEEE 1800-2023 Section 11.9)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the tagged union expression assigned to the vint_t variable vi names Count, which is not a member of vint_t
:expected_stderr_regex: test_illegal_tagged_expression_member_not_in_type\.sv:38:
*/
// IEEE 1800-2023 §11.9: a tagged union expression is type-checked statically
// against the type given by its context; the only member names allowed after
// tagged are the member names of that type. tagged Valid 23 and tagged
// Invalid are legal for vint_t; Count is a member of the other union cnt_t,
// not of vint_t.
// Icarus Verilog 13.0 does not parse tagged unions, and the 5.052 release
// of Verilator reports them as unsupported.

module test_illegal_tagged_expression_member_not_in_type;
  typedef union tagged {
    void Invalid;
    int Valid;
  } vint_t;
  typedef union tagged {
    void None;
    int Count;
  } cnt_t;
  vint_t vi;
  cnt_t ci;

  initial begin
    vi = tagged Valid 23;
    vi = tagged Invalid;
    ci = tagged Count 4;
    vi = tagged Count 5;   // illegal: Count is not a member of vint_t
    $display("%0d", ci.Count);
  end
endmodule
