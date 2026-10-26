/*
:name: test_sequence_or_and_local_flow
:description: a local variable flows out of an or only when it flows out of each operand, and out of and and intersect when it flows out of at least one operand and is not blocked, with the latest assigned value on each continuing thread (IEEE 1800-2023 Section 16.10)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.10 16.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_or_and_local_flow.expected
*/
// IEEE 1800-2023 §16.10, F.5.4: a local variable flows out of p or q if, and
// only if, it flows out of both operands; each matching operand continues as
// its own thread with its own value. It flows out of p and q and of
// p intersect q if it flows out of at least one operand, unless it is blocked
// because it is assigned in and flows out of both operands or because it is
// blocked in one of them. The value that flows out is the latest assigned one.
// The recording functions (§16.11) run at each end point, so a sum of their
// arguments does not depend on the order of the threads. a, b, c and d are
// high at the tick at 5 and at the tick at 15, so every operand pair matches
// once, and the values are recorded at 25. x is assigned 1 on the left and 2
// on the right of the first or; y is assigned 7 on the left and keeps its
// initial 5 on the right of the second or; z is assigned 7 on the left of the
// and; w is assigned 9 on the left of the intersect.

`timescale 1ns/1ns

module test_sequence_or_and_local_flow;
  logic clk = 0, a = 0, b = 0, c = 0, d = 0;
  int or_both = 0, or_one = 0, and_one = 0, int_one = 0;

  always #5 clk = ~clk;   // rising edges at 5, 15, 25, ...

  function automatic void add_or_both(int v);
    or_both += v;
  endfunction

  function automatic void add_or_one(int v);
    or_one += v;
  endfunction

  function automatic void add_and_one(int v);
    and_one += v;
  endfunction

  function automatic void add_int_one(int v);
    int_one += v;
  endfunction

  sequence s_or_both;
    int x = 5;
    ((a ##1 (b, x = 1)) or (c ##1 (d, x = 2))) ##1 (1'b1, add_or_both(x));
  endsequence

  sequence s_or_one;
    int y = 5;
    ((a ##1 (b, y = 7)) or (c ##1 d)) ##1 (1'b1, add_or_one(y));
  endsequence

  sequence s_and_one;
    int z = 5;
    ((a ##1 (b, z = 7)) and (c ##1 d)) ##1 (1'b1, add_and_one(z));
  endsequence

  sequence s_int_one;
    int w = 5;
    ((a ##1 (b, w = 9)) intersect (c ##1 d)) ##1 (1'b1, add_int_one(w));
  endsequence

  c_or_both: cover sequence (@(posedge clk) s_or_both);
  c_or_one: cover sequence (@(posedge clk) s_or_one);
  c_and_one: cover sequence (@(posedge clk) s_and_one);
  c_int_one: cover sequence (@(posedge clk) s_int_one);

  initial begin
    a = 1; c = 1;
    #10 a = 0; c = 0; b = 1; d = 1;
    #30;
    $display("or both: %0d", or_both);
    $display("or one: %0d", or_one);
    $display("and one: %0d", and_one);
    $display("intersect one: %0d", int_one);
    $finish;
  end
endmodule
