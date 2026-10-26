/*
:name: test_randsequence_recursive_code
:description: Producing the grammar stream runs the side effects of the generated code blocks, and a recursive production makes the randsequence generate more than one item per call although the statement itself is not a loop (IEEE 1800-2023 Sections 18.17 and 18.17.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.17 18.17.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randsequence_recursive_code.expected
*/
// IEEE 1800-2023 §18.17: as each production is generated, the side effects of
// its code blocks run. The statement does not create a loop, but a recursive
// production does: LIST : LIST ITEM := 8 | ITEM := 2 recurses with probability
// 0.8 and ends with probability 0.2, so one call generates about five items,
// and the code block of ITEM counts them. 100 calls count far more than 100.
// In Verilator 5.052 this recursive grammar sometimes makes the compiler
// abort with an internal fault.

module test_randsequence_recursive_code;
  int items;

  initial begin
    items = 0;
    repeat (100) begin
      randsequence (rec)
        rec : LIST;
        LIST : LIST ITEM := 8 | ITEM := 2;
        ITEM : { items++; };
      endsequence
    end
    $display("side effects run %0d, more than 100 items in 100 calls %0d",
             items > 0, items > 100);
  end
endmodule
