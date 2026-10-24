/*
:name: test_randsequence_break_in_loop
:description: A break inside a loop of a production code block ends only the smallest enclosing loop, while a break outside any loop ends the whole randsequence (IEEE 1800-2023 Section 18.17.6)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.17.6 12.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randsequence_break_in_loop.expected
*/
// IEEE 1800-2023 §18.17.6: a break executed in a code block of a production
// ends the smallest loop statement that encloses it, as in 12.8; only when no
// loop encloses it does it end the generation of the randsequence, and
// execution goes on after endsequence.
//
// In first, the break leaves the for loop at i == 2, so the code block goes on
// and appends F, and the next production is generated. In second, the break
// leaves only the inner while loop, so the outer for loop runs all three
// times. In third, the break is in no loop, so the rest of that code block
// and the production fourth are not generated, and the statement after
// endsequence appends E. No production has alternatives, so the result is
// fixed.

module test_randsequence_break_in_loop;
  string log = "";
  int j;
  bit stop = 1;

  initial begin
    randsequence (main)
      main   : first second third fourth;
      first  : { for (int i = 0; i < 5; i++) begin
                   if (i == 2) break;
                   log = {log, "f"};
                 end
                 log = {log, "F"}; };
      second : { for (int i = 0; i < 3; i++) begin
                   j = 0;
                   while (1) begin
                     if (j == 1) break;
                     log = {log, "s"};
                     j++;
                   end
                   log = {log, "S"};
                 end };
      third  : { log = {log, "T"};
                 if (stop) break;
                 log = {log, "x"}; };
      fourth : { log = {log, "y"}; };
    endsequence
    log = {log, "E"};
    $display("log=%s", log);
  end
endmodule
