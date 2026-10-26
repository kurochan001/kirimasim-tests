/*
:name: test_illegal_rand_join_parameter
:description: The optional expression of rand join shall be a real number from 0.0 through 1.0, so rand join (1.5) between two productions is an error (IEEE 1800-2023 Section 18.17.5)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.17.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the rand join expression 1.5 is outside the range 0.0 to 1.0
:expected_stderr_regex: test_illegal_rand_join_parameter\.sv:23:
*/
// IEEE 1800-2023 §18.17.5: rand join interleaves two or more production
// sequences, and its optional expression shall be a real number in the range
// 0.0 to 1.0. The value 0.0 gives priority to shorter sequences and 1.0 to
// longer ones. The expression 1.5 has no defined priority in that range, so
// the production main below is illegal.

module test_illegal_rand_join_parameter;
  initial begin
    randsequence(main)
      main : rand join (1.5) A B;   // illegal: outside 0.0 to 1.0
      A    : { $display("A"); };
      B    : { $display("B"); };
    endsequence
  end
endmodule
