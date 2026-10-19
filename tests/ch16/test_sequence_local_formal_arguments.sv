/*
:name: test_sequence_local_formal_arguments
:description: a local output formal argument of a sequence passes the value the sequence assigned to it back to the local variable bound to it at the end of each match, and a local inout formal starts from that variable's value and returns its updated value (IEEE 1800-2023 Sections 16.8.2, 16.10)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.8.2 16.10 16.12.7 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_local_formal_arguments.expected
*/
// IEEE 1800-2023 §16.8.2: a formal argument declared local output or local
// inout is a local variable of the sequence; its actual is a local variable
// of the instantiating property (§16.10). A local output formal starts
// unassigned, and a local inout formal starts with the actual's value; at the
// end of a match the formal's value is assigned to the actual. capture
// stores data when valid is high and matches when ack follows; add_twice adds
// data at two consecutive ticks. The properties then compare result and sum
// one tick later (§16.12.7), and the fail actions count failures (§16.14.1).
// result is right for the first capture (10 + 1) and wrong for the second
// (22 for 20 + 1); sum is right for the first addition (100 + 1 + 2) and
// wrong for the second (12 for 0 + 5 + 6).

`timescale 1ns/1ns

module test_sequence_local_formal_arguments;
  logic clk = 0, valid = 0, ack = 0, go = 0;
  int data = 0, result = 0, base = 0, sum = 0;
  int f_out = 0, f_inout = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  sequence capture(local output int v);
    (valid, v = data) ##1 ack;
  endsequence

  sequence add_twice(local inout int total, untyped d);
    (1'b1, total += d)[*2];
  endsequence

  property p_out;
    int x;
    capture(x) |=> (result == x + 1);
  endproperty

  property p_inout;
    int t;
    (go, t = base) ##0 add_twice(t, data) |=> (sum == t);
  endproperty

  a_out: assert property (@(posedge clk) p_out) else f_out++;
  a_inout: assert property (@(posedge clk) p_inout) else f_inout++;

  // Sets the values sampled at the next tick.
  task automatic tick(logic v, int d, logic a, int r, logic g, int b, int s);
    valid = v; data = d; ack = a; result = r; go = g; base = b; sum = s;
    #10;
  endtask

  initial begin
    tick(1, 10, 0, 0, 0, 0, 0);    // 5
    tick(0, 3, 1, 0, 0, 0, 0);     // 15
    tick(0, 0, 0, 11, 0, 0, 0);    // 25
    tick(1, 20, 0, 0, 0, 0, 0);    // 35
    tick(0, 0, 1, 0, 0, 0, 0);     // 45
    tick(0, 0, 0, 22, 0, 0, 0);    // 55
    tick(0, 1, 0, 0, 1, 100, 0);   // 65
    tick(0, 2, 0, 0, 0, 0, 0);     // 75
    tick(0, 0, 0, 0, 0, 0, 103);   // 85
    tick(0, 5, 0, 0, 1, 0, 0);     // 95
    tick(0, 6, 0, 0, 0, 0, 0);     // 105
    tick(0, 0, 0, 0, 0, 0, 12);    // 115
    tick(0, 0, 0, 0, 0, 0, 0);     // 125
    $display("local output: %0d failures", f_out);
    $display("local inout: %0d failures", f_inout);
    $finish;
  end
endmodule
