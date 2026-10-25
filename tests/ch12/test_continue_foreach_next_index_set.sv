/*
:name: test_continue_foreach_next_index_set
:description: A continue in a foreach loop over several dimensions ends only the body for the current set of loop variable values, and the loop goes on with the next value of the innermost variable (IEEE 1800-2023 Section 12.8)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.8 12.7.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_continue_foreach_next_index_set.expected
*/
// IEEE 1800-2023 §12.8: in a foreach loop with several dimensions, continue
// jumps to the end of the loop for the current set of loop variable values;
// the loop then goes on with the next set (12.7.3: the rightmost variable
// changes fastest). It does not leave the innermost dimension, and it does
// not leave the loop.
//
// The 2 x 3 loop records "i,j>" when its body starts and "<" when it reaches
// the end of the body. It continues when j is 1, and in row 1 also when j is
// 0, so those sets have no "<" while all the other sets still run, each
// ending in "<".

module test_continue_foreach_next_index_set;
  int m [2][3];
  string trace;
  int ends;

  initial begin
    trace = "";
    ends = 0;
    foreach (m[i, j]) begin
      trace = {trace, $sformatf(" %0d,%0d>", i, j)};
      if (j == 1) continue;
      if (i == 1 && j == 0) continue;
      trace = {trace, "<"};
      ends++;
    end
    $display("trace:%s", trace);
    $display("bodies run to the end: %0d of 6", ends);
  end
endmodule
