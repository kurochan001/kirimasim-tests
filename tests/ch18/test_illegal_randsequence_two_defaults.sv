/*
:name: test_illegal_randsequence_two_defaults
:description: A case production statement in a randsequence block shall have at most one default item, so two default items are an error (IEEE 1800-2023 Section 18.17.3)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.17.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the case production main has two default items
:expected_stderr_regex: test_illegal_randsequence_two_defaults\.sv:27:
*/
// IEEE 1800-2023 §18.17.3: a case production statement selects the production
// of the first matching case item, or the production of the optional default
// item when nothing matches. Multiple default statements in one case
// production statement shall be illegal. The case below has the item 0 and
// two default items, so no implementation can choose between the two defaults
// when the expression is not 0.

module test_illegal_randsequence_two_defaults;
  initial begin
    randsequence(main)
      main : case (1)
               0: first;
               default: second;
               default: third;   // illegal: second default
             endcase;
      first : { $display("first"); };
      second: { $display("second"); };
      third : { $display("third"); };
    endsequence
  end
endmodule
