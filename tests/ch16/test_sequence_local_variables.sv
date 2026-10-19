/*
:name: test_sequence_local_variables
:description: each evaluation attempt of a sequence gets its own copies of the local variables, so overlapping attempts keep the values they captured; a declaration assignment uses the sampled value at the start of the attempt, assignments attached to a repeated subsequence accumulate, and a subroutine attached to a match receives the local variables (IEEE 1800-2023 Sections 16.10, 16.11)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.10 16.11 16.12.7 16.14.1 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_local_variables.expected
*/
// IEEE 1800-2023 §16.10: a new copy of each local variable is created at the
// start of every evaluation attempt; a declaration assignment is done then,
// with the sampled value of its expression; assignments attached to a
// subsequence are done at the end of each of its matches, also when the
// subsequence is repeated. §16.11: subroutines attached to a sequence are
// called at each of its end points, with local variables passed by value.
// s_pipe captures din with valid and expects dout two ticks later to be one
// more. Three transfers overlap (din 10, 20, 30 at 5, 15, 25); dout is right
// for the first and third and wrong for the second, so the cover sequence
// (§16.14.3) records 10 and 30 and the assertion (§16.12.7, §16.14.1) fails
// once. s_sum starts at 85 with base 100 and adds din at the next three ticks;
// base changes to 500 right after that tick, which the attempt does not see.

`timescale 1ns/1ns

module test_sequence_local_variables;
  logic clk = 0, valid = 0, start = 0;
  int din = 0, dout = 0, base = 0;
  int got_pipe[$], got_sum[$];
  int fails = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  function automatic void record_pipe(int v);
    got_pipe.push_back(v);
  endfunction

  function automatic void record_sum(int v);
    got_sum.push_back(v);
  endfunction

  sequence s_pipe;
    int v;
    (valid, v = din) ##2 (dout == v + 1, record_pipe(v));
  endsequence

  sequence s_sum;
    int acc = base;
    (start ##1 (1'b1, acc += din)[*3], record_sum(acc));
  endsequence

  property p_pipe;
    int v;
    (valid, v = din) |-> ##2 (dout == v + 1);
  endproperty

  c_pipe: cover sequence (@(posedge clk) s_pipe);
  c_sum: cover sequence (@(posedge clk) s_sum);
  a_pipe: assert property (@(posedge clk) p_pipe) else fails++;

  // Sets the values sampled at the next tick.
  task automatic tick(logic vvalid, int vdin, int vdout);
    valid = vvalid;
    din = vdin;
    dout = vdout;
    #10;
  endtask

  function automatic string values(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    tick(1, 10, 0); tick(1, 20, 0); tick(1, 30, 11); tick(0, 0, 99); tick(0, 0, 31);
    tick(0, 0, 0); tick(0, 0, 0); tick(0, 0, 0);
    base = 100;
    start = 1;
    tick(0, 0, 0);
    start = 0;
    base = 500;
    tick(0, 1, 0); tick(0, 2, 0); tick(0, 3, 0); tick(0, 0, 0);
    $display("captured by s_pipe:%s", values(got_pipe));
    $display("assertion failures: %0d", fails);
    $display("sum from s_sum:%s", values(got_sum));
    $finish;
  end
endmodule
