/*
:name: test_triggered_local_variable_threads
:description: a local variable passed to a named sequence to which triggered is applied flows out of the triggered check with the value the sequence assigned, and two matches that end in the same tick with different values make two threads that go on separately (IEEE 1800-2023 Section 16.10)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_triggered_local_variable_threads.expected
*/
// IEEE 1800-2023 §16.10: a local variable can be passed whole to an untyped
// formal of a named sequence to which triggered is applied; the sequence
// assigns it before reading it, and when triggered stands alone (a maximal
// Boolean expression) the variable flows out with the value assigned in
// the matching evaluation. Several matches of the instance in one tick
// with different values of the variable are treated like the matching
// operands of or: the thread forks, and each copy goes on with its own value.
// sub(lv) stores d in lv when a is high and matches when b follows one or
// two ticks later. Tick k is at 10 * k + 5. a is high at ticks 1 and 2 with
// d = 10 and 20, b at tick 3, c at tick 3; e is 20 at tick 4. Both matches
// of sub end at tick 3, so top forks: each thread records v at tick 4
// (45:10 and 45:20, sorted as they come in the same time step), and in
// top_eq only the thread with v == e matches.
// Icarus Verilog 13.0 does not support these assertions and Verilator
// 5.052 does not support local variables in sequences.

`timescale 1ns/1ns

module test_triggered_local_variable_threads;
  logic clk = 0, a = 0, b = 0, c = 0;
  int d = 0, e = 0;
  string all_v[$], eq_v[$];

  function automatic void rec_all(int v);
    all_v.push_back($sformatf("%0t:%0d", $time, v));
  endfunction

  function automatic void rec_eq(int v);
    eq_v.push_back($sformatf("%0t:%0d", $time, v));
  endfunction

  always #5 clk = ~clk;   // tick k at 10 * k + 5

  sequence sub(lv);
    (a, lv = d) ##[1:2] b;
  endsequence

  sequence top;
    int v;
    c ##0 sub(v).triggered ##1 (1'b1, rec_all(v));
  endsequence

  sequence top_eq;
    int v;
    c ##0 sub(v).triggered ##1 (e == v, rec_eq(v));
  endsequence

  c_top: cover sequence (@(posedge clk) top);
  c_top_eq: cover sequence (@(posedge clk) top_eq);

  initial begin
    #10 a = 1; d = 10;          // tick 1
    #10 d = 20;                 // tick 2
    #10 a = 0; d = 0; b = 1; c = 1;   // tick 3
    #10 b = 0; c = 0; e = 20;   // tick 4
    #10 e = 0;                  // tick 5
    #20;
    all_v.sort();
    $write("all threads: [");
    foreach (all_v[i]) $write(" %s", all_v[i]);
    $display(" ]");
    $write("v == e: [");
    foreach (eq_v[i]) $write(" %s", eq_v[i]);
    $display(" ]");
    $finish;
  end
endmodule
