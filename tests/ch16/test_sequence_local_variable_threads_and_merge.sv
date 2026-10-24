/*
:name: test_sequence_local_variable_threads_and_merge
:description: assignments attached to a subsequence run in the order of the list at each of its matches, local variables are initialized in declaration order after the local formals with sampled values, a value assigned before or, and or intersect reaches each operand thread separately, the threads of or go on with their own values, and and or intersect keep the latest value of each local variable that flows out (IEEE 1800-2023 Section 16.10)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_local_variable_threads_and_merge.expected
*/
// IEEE 1800-2023 §16.10: the assignments in the list after a subsequence are
// done at the end of each nonempty match of it, in the order written, also
// when the subsequence is repeated. Local variables are initialized in the
// Observed region when an attempt starts, the local formals first and then
// the declared ones in their order, with the sampled values of the
// expressions. A value assigned before or, and or intersect flows into each
// operand, and the operands work on separate copies. Each matching operand
// of or goes on as its own thread with its own values. When and or
// intersect completes, the threads are merged and a local variable that
// flows out has its latest assigned value; one assigned in just one operand
// flows out with that value.
// Tick k is at 10 * k + 5. assign: x = d = 5, then y = x + 1 = 6, then x
// gets 10 added at each of two ticks. init: q goes up by a nonblocking
// assignment at every tick, so its sampled value at tick 6 is 6: f = 6,
// u = 7, w = 70. or: x = 10, then 11 in one operand and 12 in the other;
// both threads go on, and only the one with x == c2 (12) matches the check.
// and: one operand sets x to 6 while the other still sees 5 and sets y; the
// result has x = 6 and y = 7. intersect: x becomes 11 in one operand, the
// other computes y = 1 + 2. The attached calls record time:value; the
// values of the two or threads are sorted, as their calls happen in the
// same time step.

`timescale 1ns/1ns

module test_sequence_local_variable_threads_and_merge;
  logic clk = 0, a1 = 0, b1 = 0, st_i = 0, a2 = 0, b2 = 0, b3 = 0, a3 = 0, a4 = 0;
  int d = 0, q = 0, c2 = 0;
  string or_all[$];
  string m[string];

  function automatic void add(string name, string s);
    if (m.exists(name)) m[name] = {m[name], s};
    else m[name] = s;
  endfunction

  function automatic void rec1(string name, int v);
    add(name, $sformatf(" %0t:%0d", $time, v));
  endfunction

  function automatic void rec2(string name, int v, int w);
    add(name, $sformatf(" %0t:%0d/%0d", $time, v, w));
  endfunction

  function automatic void push_or(int v);
    or_all.push_back($sformatf("%0t:%0d", $time, v));
  endfunction

  function automatic string ends(string name);
    return m.exists(name) ? m[name] : "";
  endfunction

  always #5 clk = ~clk;   // tick k at 10 * k + 5
  always @(posedge clk) q <= q + 1;

  sequence s_assign;
    int x = 100, y;
    (a1, x = d, y = x + 1) ##1 (b1, x += 10)[*2] ##1 (1'b1, rec2("assign", x, y));
  endsequence

  sequence s_init(local input int f);
    int u = f + 1, w = u * 10;
    ##1 (1'b1, rec2("init", u, w));
  endsequence

  sequence s_or_all;
    int x;
    (a2, x = 10) ##1 ((b2, x += 1) or (b3, x += 2)) ##1 (1'b1, push_or(x));
  endsequence

  sequence s_or_eq;
    int x;
    (a2, x = 10) ##1 ((b2, x += 1) or (b3, x += 2)) ##1 (c2 == x, rec1("or match", x));
  endsequence

  sequence s_and;
    int x, y;
    (a3, x = 5) ##1 (((1'b1, x = x + 1) ##1 (x == 6)) and (##2 (x == 5, y = 7)))
      ##1 (1'b1, rec2("and", x, y));
  endsequence

  sequence s_isect;
    int x, y;
    (a4, x = 1) ##1 (((1'b1, x = x + 10) ##1 1'b1) intersect (##1 (1'b1, y = x + 2)))
      ##1 (1'b1, rec2("intersect", x, y));
  endsequence

  c_assign: cover sequence (@(posedge clk) s_assign);
  c_init: cover sequence (@(posedge clk) st_i ##0 s_init(q));
  c_or_all: cover sequence (@(posedge clk) s_or_all);
  c_or_eq: cover sequence (@(posedge clk) s_or_eq);
  c_and: cover sequence (@(posedge clk) s_and);
  c_isect: cover sequence (@(posedge clk) s_isect);

  initial begin
    #10 a1 = 1; d = 5;       // tick 1
    #10 a1 = 0; b1 = 1;      // tick 2
    #10;                     // tick 3
    #10 b1 = 0; d = 0;       // tick 4
    #20 st_i = 1;            // tick 6
    #10 st_i = 0;            // tick 7
    #20 a2 = 1;              // tick 9
    #10 a2 = 0; b2 = 1; b3 = 1;   // tick 10
    #10 b2 = 0; b3 = 0; c2 = 12;  // tick 11
    #10 c2 = 0;              // tick 12
    #10 a3 = 1;              // tick 13
    #10 a3 = 0;              // tick 14
    #50 a4 = 1;              // tick 19
    #10 a4 = 0;              // tick 20
    #40;
    or_all.sort();
    $display("assign: [%s ]", ends("assign"));
    $display("init: [%s ]", ends("init"));
    $write("or threads: [");
    foreach (or_all[i]) $write(" %s", or_all[i]);
    $display(" ]");
    $display("or match: [%s ]", ends("or match"));
    $display("and: [%s ]", ends("and"));
    $display("intersect: [%s ]", ends("intersect"));
    $finish;
  end
endmodule
