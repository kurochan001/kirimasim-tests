/*
:name: test_syntax_randcase_and_randsequence_forms
:description: randcase picks an item by its expression weight and runs its statement or null statement, and a randsequence statement runs its productions, as A.6.7, 18.16 and 18.17 say (IEEE 1800-2023 Sections 18.16 and 18.17, A.6.4, A.6.7)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.16 18.17 A.6.4 A.6.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_randcase_and_randsequence_forms.expected
*/
// IEEE 1800-2023 A.6.7: a randcase statement is "randcase randcase_item {
// randcase_item } endcase", and an item is "expression : statement_or_null".
// §18.16: an item is chosen with a probability proportional to its
// expression, which is evaluated when the statement is reached; an item of
// weight 0 is never chosen. A.6.4 lists the randcase statement and the
// randsequence statement as statement items.
//
// Ten randcase statements each have the weights 0, 1 and 0, so the second
// item runs every time and the other two never: c1 is 10 and c0 and c2 are 0.
// Another randcase has an item with a null statement and a zero-weight item,
// so it changes nothing. The randsequence has a single production, which runs
// once and adds 1 to n.
//
// The expected output follows the standard; Icarus Verilog 13.0 does not
// support randsequence, and the 5.052 release of the other simulator
// produces it.

module test_syntax_randcase_and_randsequence_forms;
  int c0 = 0, c1 = 0, c2 = 0;
  int n = 0;

  initial begin
    repeat (10) begin
      randcase
        0: c0++;
        1: c1++;
        0: c2++;
      endcase
    end

    randcase
      1: ;
      0: c0++;
    endcase

    randsequence (main)
      main : { n = n + 1; };
    endsequence

    $display("weights: c0=%0d c1=%0d c2=%0d", c0, c1, c2);
    $display("randsequence n=%0d", n);
  end
endmodule
