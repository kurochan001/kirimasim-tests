/*
:name: test_property_leading_clock_sets_operators
:description: under an outer clock, not, parentheses, strong, weak, |->, |=> and a property instance keep the semantic leading clocks of their operand, antecedent or body, so the attempts begin at the ticks of that clock and the outer clock replaces only an inherited one (IEEE 1800-2023 Section 16.16.1)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.16.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_leading_clock_sets_operators.expected
*/
// IEEE 1800-2023 §16.16.1: the set of semantic leading clocks of not q and of
// (q) is that of q; of strong(m) and weak(m) it is the leading clock of m; of
// m |-> p and m |=> p it is that of m, not that of p; of a property instance
// it is that of the body with the actual arguments put in. Under the outer
// clock @(posedge c0) an element "inherited" of the set becomes posedge c0,
// and any other element stays. Every assertion here has one leading clock,
// and a new attempt begins at each of its ticks (16.12.11, 16.14.5).
// c2 rises at 5, 15, ..., 105, c0 at 20, 60 and 100, and c3 at 38 and 78.
// The signals change between ticks. Each assertion or cover adds the time of
// a failure or of a success to its own list, printed at the end.
// - not @(posedge c2) b1 and (not @(posedge c2) b2) have the set {c2}: they
//   fail at the c2 ticks 15 and 75 where b1 and b2 are 1.
// - strong(@(posedge c2) b3 ##1 d3) has {c2}: b3 at 15 and 65 and d3 at 25
//   and 75 give successes at 25 and 75. weak(@(posedge c2) !b4 ##1 !d4) has
//   {c2}: b4 at 35 fails the attempt of 35.
// - strong(b5 ##1 @(posedge c2) d5) starts with the unclocked b5, so its set
//   is {inherited}, here posedge c0: b5 is 1 at the c0 tick 60 and at no c2
//   tick, and d5 at the next c2 tick 65 gives a success at 65.
// - (@(posedge c2) b6) |-> @(posedge c3) d6 has {c2}: b6 at 35 needs d6 at
//   the c3 tick 38, where it is 0. b7 |=> @(posedge c3) d7 has the set of b7,
//   {inherited}: b7 is 1 at the c0 tick 60 only and d7 is 0 at 78.
// - p_body(b8, posedge c2) has the body @(posedge c2) !b8, so {c2}: b8 at 45
//   fails. p_plain(b9) has the unclocked body !b9, so {inherited}: b9 at the
//   c0 tick 100 fails.
// With the attempts at the c0 ticks instead of c2, each would sample at 25,
// 65 and 105 only and the lists would be [ ], [ ], [ 75 ], [ ], [ ] and [ ]
// for the six with {c2}; with c2 or c3 instead of c0 the three with
// {inherited} would give [ ]. No strong attempt is pending at $finish.
// Icarus Verilog 13.0 does not support these assertions, and the 5.054
// release of Verilator rejects a clocking event inside a property or
// sequence operand with a syntax error, so the expected output comes from
// the standard alone.

`timescale 1ns/1ns

module test_property_leading_clock_sets_operators;
  logic c0 = 0, c2 = 0, c3 = 0;
  logic b1 = 0, b2 = 0, b3 = 0, d3 = 0, b4 = 0, d4 = 0, b5 = 0, d5 = 0;
  logic b6 = 0, d6 = 0, b7 = 0, d7 = 0, b8 = 0, b9 = 0;
  string m[string];
  string order[] = '{"not @(c2) b1 fails", "(not @(c2) b2) fails",
                      "strong(@(c2) b3 ##1 d3) succeeds", "weak(@(c2) !b4 ##1 !d4) fails",
                      "strong(b5 ##1 @(c2) d5) succeeds", "(@(c2) b6) |-> @(c3) d6 fails",
                      "b7 |=> @(c3) d7 fails", "p_body(b8, posedge c2) fails",
                      "p_plain(b9) fails"};

  function automatic void hit(string name);
    string t = $sformatf(" %0t", $time);
    if (m.exists(name)) m[name] = {m[name], t};
    else m[name] = t;
  endfunction

  property p_body(x, event ck);
    @(ck) !x;
  endproperty

  property p_plain(x);
    !x;
  endproperty

  always #5 c2 = ~c2;
  initial forever begin
    #20 c0 = 1;
    #20 c0 = 0;
  end
  initial begin
    #38;
    forever begin
      c3 = 1;
      #20 c3 = 0;
      #20;
    end
  end

  a_not: assert property (@(posedge c0) not @(posedge c2) b1)
    else hit("not @(c2) b1 fails");
  a_par: assert property (@(posedge c0) (not @(posedge c2) b2))
    else hit("(not @(c2) b2) fails");
  c_str: cover property (@(posedge c0) strong(@(posedge c2) b3 ##1 d3))
    hit("strong(@(c2) b3 ##1 d3) succeeds");
  a_weak: assert property (@(posedge c0) weak(@(posedge c2) !b4 ##1 !d4))
    else hit("weak(@(c2) !b4 ##1 !d4) fails");
  c_inh: cover property (@(posedge c0) strong(b5 ##1 @(posedge c2) d5))
    hit("strong(b5 ##1 @(c2) d5) succeeds");
  a_ovl: assert property (@(posedge c0) (@(posedge c2) b6) |-> @(posedge c3) d6)
    else hit("(@(c2) b6) |-> @(c3) d6 fails");
  a_nov: assert property (@(posedge c0) b7 |=> @(posedge c3) d7)
    else hit("b7 |=> @(c3) d7 fails");
  a_ins: assert property (@(posedge c0) p_body(b8, posedge c2))
    else hit("p_body(b8, posedge c2) fails");
  a_pln: assert property (@(posedge c0) p_plain(b9))
    else hit("p_plain(b9) fails");

  initial begin
    #12 b1 = 1; b3 = 1;
    #6 b1 = 0; b3 = 0;          // 18
    #4 d3 = 1;                  // 22
    #6 d3 = 0;                  // 28
    #4 b4 = 1; b6 = 1;          // 32
    #6 b4 = 0; b6 = 0;          // 38
    #4 b8 = 1;                  // 42
    #6 b8 = 0;                  // 48
    #9 b5 = 1; b7 = 1;          // 57
    #5 b3 = 1; d5 = 1;          // 62
    #1 b5 = 0; b7 = 0;          // 63
    #5 b3 = 0; d5 = 0;          // 68
    #4 b2 = 1; d3 = 1;          // 72
    #6 b2 = 0; d3 = 0;          // 78
    #19 b9 = 1;                 // 97
    #6 b9 = 0;                  // 103
    #6;                         // 109
    foreach (order[i]) $display("%s: [%s ]", order[i], m.exists(order[i]) ? m[order[i]] : "");
    $finish;
  end
endmodule
