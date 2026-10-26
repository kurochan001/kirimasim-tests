/*
:name: test_randsequence_repeat_break
:description: A repeat production generates its production the stated number of times, a break inside it terminates the whole randsequence instead of the repeat alone, and repeat(0) generates nothing (IEEE 1800-2023 Sections 18.17.4 and 18.17.6)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.17.4 18.17.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randsequence_repeat_break.expected
*/
// IEEE 1800-2023 §18.17.4: repeat(3) P generates P three times. The repeat
// production cannot be terminated by itself: a break in the code block of the
// repeated production leaves the whole randsequence, so the Q that follows is
// not generated and the second call of P does not happen. repeat(0) generates
// no P, and the production after it still runs.

module test_randsequence_repeat_break;
  int p3, q3, p1, q1, p0, q0;

  initial begin
    p3 = 0;
    q3 = 0;
    randsequence (first)
      first : repeat(3) P Q;
      P : { p3++; };
      Q : { q3++; };
    endsequence
    $display("repeat 3: P three times %0d, Q once %0d", p3 == 3, q3 == 1);
    p1 = 0;
    q1 = 0;
    randsequence (second)
      second : repeat(3) R S;
      R : { p1++; if (p1 == 2) break; };
      S : { q1++; };
    endsequence
    $display("break inside repeat: P twice %0d, Q not generated %0d",
             p1 == 2, q1 == 0);
    p0 = 0;
    q0 = 0;
    randsequence (third)
      third : repeat(0) T U;
      T : { p0++; };
      U : { q0++; };
    endsequence
    $display("repeat 0: P not generated %0d, Q once %0d", p0 == 0, q0 == 1);
  end
endmodule
