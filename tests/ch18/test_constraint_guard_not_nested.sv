/*
:name: test_constraint_guard_not_nested
:description: Negation in constraint guards and nested guard conditions follow the four-value rules, and a final R keeps every random term as the condition (IEEE 1800-2023 Section 18.5.12)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.12 18.5.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constraint_guard_not_nested.expected
:expected_stderr_regex: (?i)\berror\b
*/
// IEEE 1800-2023 §18.5.12: a condition of an implication (18.5.5) is
// evaluated as a guard before solving. Each subexpression is 0 (false), 1
// (true), E (an evaluation error) or R (it has random variables), and
// Figure 18-3 gives the value of a negation: !0 is 1, !1 is 0, !E is E and !R
// is R. The rules apply recursively until the whole condition has a value,
// and a final R creates the constraint with every random term that is not
// hidden as its condition, while guard terms that are hidden, also errors,
// play no part. The test probes the four negations and seven nested
// conditions, among them (1 && R) || (1 && R) with r1 and r2, whose
// condition is r1 || r2, and (0 || R) && (E || 1), whose condition is r1
// alone because E || 1 is 1.
// The terms of the conditions here are: 0 is z == 1 and 1 is z == 0, where z
// is a state variable holding 0; E is n.x == 0, read through the null handle
// n; R is r1 == 1 or r2 == 1, as each constraint shows, with r1 and r2
// random. Each probe is one constraint, cond -> v == 7, the
// only one on (constraint_mode, 18.9) while randomize() is called five times
// with inline constraints (18.7): v == 7, then v == 9 together with (r1, r2)
// = (0,0), (1,1), (1,0) and (0,1). The five results are printed as digits.
// A final 0 removes the constraint, so all five succeed: 11111. A final 1
// creates v == 7, so only the first succeeds: 10000. A final E is an error
// and fails every call: 00000 (the tool also reports the error, which the
// run's messages are checked for). A final R creates the constraint with the
// random terms as its condition: 1 followed by 0 where that condition is
// true and 1 where it is false.
// Icarus Verilog 13.0 does not compile classes with constraints. Verilator
// 5.052 gives the lines up to the first probe that reads n.x, and then stops
// the simulation (null pointer dereferenced) instead of failing that call.

class gtn_data;
  int x;
endclass

class gtn_obj;
  rand bit r1, r2;
  rand bit [7:0] v;
  int z = 0;
  gtn_data n;   // never set: n stays null
  constraint p00 { !(z == 1) -> v == 8'd7; }
  constraint p01 { !(z == 0) -> v == 8'd7; }
  constraint p02 { !(n.x == 0) -> v == 8'd7; }
  constraint p03 { !(r1 == 1'b1) -> v == 8'd7; }
  constraint p04 { !((z == 1) && (n.x == 0)) -> v == 8'd7; }
  constraint p05 { (((n.x == 0) || (z == 0)) && !((r1 == 1'b1) && (z == 1))) -> v == 8'd7; }
  constraint p06 { (((z == 1) || (r1 == 1'b1)) && ((n.x == 0) || (z == 0))) -> v == 8'd7; }
  constraint p07 { (((z == 0) && (r1 == 1'b1)) || ((z == 0) && (r2 == 1'b1))) -> v == 8'd7; }
  constraint p08 { (!((n.x == 0) && (z == 1)) && ((r1 == 1'b1) || (n.x == 0))) -> v == 8'd7; }
  constraint p09 { !(((r1 == 1'b1) && (z == 0)) || ((n.x == 0) && (z == 1))) -> v == 8'd7; }
  constraint p10 { (!((z == 1) || (n.x == 0)) || ((z == 0) && (z == 0))) -> v == 8'd7; }
endclass

module test_constraint_guard_not_nested;
  gtn_obj o;

  task automatic probe(int k, string label);
    int a, b, c, d, e;
    o.constraint_mode(0);
    case (k)
      0: o.p00.constraint_mode(1);
      1: o.p01.constraint_mode(1);
      2: o.p02.constraint_mode(1);
      3: o.p03.constraint_mode(1);
      4: o.p04.constraint_mode(1);
      5: o.p05.constraint_mode(1);
      6: o.p06.constraint_mode(1);
      7: o.p07.constraint_mode(1);
      8: o.p08.constraint_mode(1);
      9: o.p09.constraint_mode(1);
      10: o.p10.constraint_mode(1);
    endcase
    a = o.randomize() with { v == 8'd7; };
    b = o.randomize() with { v == 8'd9; r1 == 1'b0; r2 == 1'b0; };
    c = o.randomize() with { v == 8'd9; r1 == 1'b1; r2 == 1'b1; };
    d = o.randomize() with { v == 8'd9; r1 == 1'b1; r2 == 1'b0; };
    e = o.randomize() with { v == 8'd9; r1 == 1'b0; r2 == 1'b1; };
    $display("%s: %0d%0d%0d%0d%0d", label, a, b, c, d, e);
  endtask

  initial begin
    o = new;
    probe(0, "!0");
    probe(1, "!1");
    probe(2, "!E");
    probe(3, "!R");
    probe(4, "!(0 && E)");
    probe(5, "(E || 1) && !(R && 0)");
    probe(6, "(0 || R) && (E || 1)");
    probe(7, "(1 && R) || (1 && R)");
    probe(8, "!(E && 0) && (R || E)");
    probe(9, "!((R && 1) || (E && 0))");
    probe(10, "!(0 || E) || (1 && 1)");
  end
endmodule
