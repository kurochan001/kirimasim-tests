/*
:name: test_randsequence_return_aborts_production
:description: A return in a production code block aborts the rest of that production, including the productions after the code block in its rule and an enclosing loop, and generation goes on with the production that follows it (IEEE 1800-2023 Section 18.17.6)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.17.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randsequence_return_aborts_production.expected
*/
// IEEE 1800-2023 §18.17.6: a return executed in a code block of a production
// aborts the generation of that production, not only of the code block and
// not of the whole randsequence; generation continues with the production
// that follows the aborted one.
//
// The rule of outer generates head, then a code block that appends 1 and
// returns, so neither the rest of that code block (x) nor the production
// skipped after it in the same rule is generated; generation continues with
// after, the production that follows outer in main. In inner, the return is
// inside a for loop: it aborts inner, not only the loop, so y is not appended,
// and tail, which follows inner, is generated. No production has
// alternatives, so the result is fixed.

module test_randsequence_return_aborts_production;
  string log = "";
  bit quit = 1;

  initial begin
    randsequence (main)
      main    : outer after;
      outer   : head { log = {log, "1"};
                       if (quit) return;
                       log = {log, "x"}; } skipped;
      head    : { log = {log, "h"}; };
      skipped : { log = {log, "s"}; };
      after   : inner tail;
      inner   : { log = {log, "i"};
                  for (int k = 0; k < 3; k++) begin
                    if (k == 1) return;
                    log = {log, "k"};
                  end
                  log = {log, "y"}; };
      tail    : { log = {log, "t"}; };
    endsequence
    log = {log, "E"};
    $display("log=%s", log);
  end
endmodule
