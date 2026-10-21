/*
:name: test_sequence_subroutine_call_arguments
:description: subroutines attached to a sequence are called at each of its end points in the order of the list, an argument passed by value gets the sampled value and one passed by const ref the current value, and calls attached to a subsequence run when it matches even if the whole property then fails (IEEE 1800-2023 Section 16.11)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.11 16.5.1 16.14.3 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_subroutine_call_arguments.expected
*/
// IEEE 1800-2023 §16.11: tasks and void functions attached to a sequence are
// called at every end point of it, in the order of the list, in the Reactive
// region. An argument passed by value takes the sampled value (§16.5.1) of
// its variables; one passed by reference reads the variable when the call
// runs. d and q are updated by a nonblocking assignment at every tick: at
// tick n (time 10 * n + 5) the sampled d is n and q is 10 * (n + 1) when the
// calls run. c_call (§16.14.3) ends at 25 and 65, giving 2 and 6 by value
// and 30 and 70 by reference, and first then second each time. a_sub
// (§16.14.1) calls mark when its subsequence b matches, at 25 and 65; c does
// not follow at 35, so it fails there, and it passes at 75.

`timescale 1ns/1ns

module test_sequence_subroutine_call_arguments;
  logic clk = 0, a = 0, b = 0, c = 0;
  int d = 0, q = 0;
  string order = "";
  int by_value[$], by_ref[$], marks[$], fails[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  always @(posedge clk) begin
    d <= d + 1;
    q <= q + 10;
  end

  function automatic void take_value(int v);
    by_value.push_back(v);
  endfunction

  function automatic void take_ref(const ref int v);
    by_ref.push_back(v);
  endfunction

  function automatic void first();
    order = {order, "1"};
  endfunction

  task automatic second();
    order = {order, "2"};
  endtask

  function automatic void mark();
    marks.push_back($time);
  endfunction

  c_call: cover sequence (@(posedge clk) (a ##1 b, take_value(d), take_ref(q), first(), second()));
  a_sub: assert property (@(posedge clk) a |-> ##1 (b, mark()) ##1 c) else fails.push_back($time);

  // Sets the values sampled at the next tick.
  task automatic tick(logic va, logic vb, logic vc);
    a = va;
    b = vb;
    c = vc;
    #10;
  endtask

  function automatic string values(int v[$]);
    string s = "";
    foreach (v[i]) s = {s, $sformatf(" %0d", v[i])};
    return s;
  endfunction

  initial begin
    tick(0, 0, 0); tick(1, 0, 0); tick(0, 1, 0); tick(0, 0, 0); tick(0, 0, 0);
    tick(1, 0, 0); tick(0, 1, 0); tick(0, 0, 1); tick(0, 0, 0);
    $display("by value:%s", values(by_value));
    $display("by const ref:%s", values(by_ref));
    $display("order: %s", order);
    $display("mark called at:%s", values(marks));
    $display("a_sub failures:%s", values(fails));
    $finish;
  end
endmodule
