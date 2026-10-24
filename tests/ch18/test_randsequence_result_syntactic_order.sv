/*
:name: test_randsequence_result_syntactic_order
:description: The implicit variable of a value-returning production has its return type when the production appears once in a rule and is an array indexed from 1 when it appears more than once, whose elements follow the syntactic order of appearance even when only one of the appearances is generated (IEEE 1800-2023 Section 18.17.7)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.17.7 18.17.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randsequence_result_syntactic_order.expected
*/
// IEEE 1800-2023 §18.17.7: a production declared with a return type returns a
// value with return, and a code block of the rule that generated it reads the
// value by the production name, with an index when needed. For each
// value-returning production in a rule, the rule has an implicit variable:
// of the return type when the production appears once in the rule, and an
// array of that type indexed from 1 to the number of appearances otherwise.
// The elements take the values of the appearances in their syntactic order.
//
// In pick, val appears twice, in the two branches of an if-else production
// (18.17.2), so val is an array with indices 1 and 2, but only one branch is
// generated. With cond 1 the first appearance, val(5), is generated and its
// value is val[1]; with cond 0 the second, val(20), is generated and its
// value is val[2], although it is the only val generated in that rule. The
// element that is not generated is not printed: its value is undefined. In
// show, nib appears once, so nib is a plain variable of the return type
// bit [3:0]: 4 bits wide, and the returned 8'hA7 is kept as 7. There are no
// random choices, so the result is fixed.

module test_randsequence_result_syntactic_order;
  bit cond;

  initial begin
    for (int c = 1; c >= 0; c--) begin
      cond = c;
      randsequence (main)
        main          : pick show;
        pick          : if (cond) val(5) else val(20)
                        { if (cond)
                            $display("cond=1: val[1]=%0d", val[1]);
                          else
                            $display("cond=0: val[2]=%0d", val[2]);
                          $display("  val indices %0d..%0d, element bits %0d",
                                   $low(val), $high(val), $bits(val[1])); };
        int val (int v) : { return v; };
        show          : nib { $display("  nib=%0d bits=%0d", nib, $bits(nib)); };
        bit [3:0] nib : { return 8'hA7; };
      endsequence
    end
  end
endmodule
