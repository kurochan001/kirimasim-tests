/*
:name: test_randsequence_control
:description: randsequence productions with if-else, repeat, break, return and arguments (IEEE 1800-2023 Section 18.17)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.17 18.17.2 18.17.4 18.17.6 18.17.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randsequence_control.expected
*/
// IEEE 1800-2023 §18.17: randsequence generates its first production by
// generating, in order, the productions and code blocks it lists. §18.17.2: an
// if-else production chooses by its condition. §18.17.4: repeat (n) generates a
// production n times. §18.17.6: break ends the whole randsequence, and return
// ends only the production it is in. §18.17.7: a production can take arguments
// like a task. There are no random choices here, so the result is fixed.

module test_randsequence_control;
  string log;
  string log2;
  int total;
  bit flag = 1;

  initial begin
    log = "";
    randsequence (main)
      main        : first repeat_it second stop never;
      first       : { log = {log, "F"}; };
      repeat_it   : repeat (3) tick;
      tick        : { log = {log, "t"}; };
      second      : if (flag) yes else no;
      yes         : { log = {log, "Y"}; };
      no          : { log = {log, "N"}; };
      stop        : { log = {log, "B"}; break; };
      never       : { log = {log, "X"}; };
    endsequence
    $display("log=%s", log);

    log2 = "";
    randsequence (top)
      top   : part1 part2;
      part1 : { log2 = {log2, "a"}; return; log2 = {log2, "b"}; };
      part2 : { log2 = {log2, "c"}; };
    endsequence
    $display("log2=%s", log2);

    randsequence (start)
      start : add(2, 3);
      add (int a, int b) : { total = a + b; };
    endsequence
    $display("total=%0d", total);
  end
endmodule
