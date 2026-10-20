/*
:name: test_sequence_local_variable_initialization
:description: A local variable declared with an initial value in a named sequence is initialized at the start of each evaluation attempt (IEEE 1800-2023 Section 16.13.7)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.13.7 16.10 16.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_local_variable_initialization.expected
*/
// IEEE 1800-2023 §16.10, §16.13.7: a local variable declared in a named
// sequence with an initialization assignment, int v = cnt, gets the sampled
// value of cnt in the time step in which an evaluation attempt begins, at a
// tick of the sequence's clock, and each attempt has its own copy. cnt goes
// up by one at each tick, so two ticks after an attempt begins cnt == v + 2
// holds and cnt == v + 1 does not: the attempts started at 5, 15 and 25 end
// at 25, 35 and 45, three passes of a_two and three failures of a_one by 52.

module test_sequence_local_variable_initialization;
  logic clk = 0;
  int cnt = 0;
  int pass_two = 0, fail_two = 0, pass_one = 0, fail_one = 0;

  always #5 clk = ~clk;
  always @(posedge clk) cnt <= cnt + 1;

  sequence s_step(int n);
    int v = cnt;
    ##2 cnt == v + n;
  endsequence

  a_two: assert property (@(posedge clk) s_step(2)) pass_two++;
    else fail_two++;
  a_one: assert property (@(posedge clk) s_step(1)) pass_one++;
    else fail_one++;

  initial begin
    #52 $display("s_step(2): %0d passes, %0d failures; s_step(1): %0d passes, %0d failures",
                 pass_two, fail_two, pass_one, fail_one);
    $finish;
  end
endmodule
