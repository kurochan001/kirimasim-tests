/*
:name: test_illegal_randsequence_negative_weight
:description: A production weight shall evaluate to an integral nonnegative value, so a production list weighted with -1 in a randsequence case of alternatives is an error (IEEE 1800-2023 Section 18.17.1)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.17.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the production list add has the negative weight -1
:expected_stderr_regex: test_illegal_randsequence_negative_weight\.sv:24:
*/
// IEEE 1800-2023 §18.17.1: the := operator assigns the weight of a production
// list, and the weight specification shall evaluate to an integral
// nonnegative value. The alternatives add and dec of main are separated by |,
// so their weights are meaningful. dec has the weight 1 and is legal; add has
// the weight -1, which cannot be proportional to a probability, and is
// illegal.

module test_illegal_randsequence_negative_weight;
  initial begin
    randsequence(main)
      main : add := (0 - 1)   // illegal: negative weight
           | dec := 1;
      add  : { $display("add"); };
      dec  : { $display("dec"); };
    endsequence
  end
endmodule
