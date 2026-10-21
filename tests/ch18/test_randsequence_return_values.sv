/*
:name: test_randsequence_return_values
:description: A randsequence production with a return type returns a value to the rule that generates it, read by the production name, or as an array indexed from 1 in the order of appearance when it appears more than once in the rule (IEEE 1800-2023 Section 18.17.7)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.17.7 18.17 18.17.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randsequence_return_values.expected
*/
// IEEE 1800-2023 §18.17.7: a production declared with a type returns a value
// with return, and a code block of the rule that generated it reads the value
// by the name of the production. A production that appears once in the rule is
// a variable of its type there; one that appears more than once is an array
// indexed from 1 in the order the production appears in that rule. So the
// next that scaled generates for itself, the third one counted, is not an
// element of the array of main, whose third element is the fourth one
// counted. There are no random choices, so the result is fixed.

module test_randsequence_return_values;
  int count = 0;

  initial begin
    randsequence (main)
      main       : next next scaled next
                   { $display("next=%0d,%0d,%0d scaled=%0d",
                              next[1], next[2], next[3], scaled); };
      int next   : { count++; return count; };
      int scaled : next { return next * 10; };
    endsequence
  end
endmodule
