/*
:name: test_property_operator_precedence_one_tick
:description: property operators group by the precedence of Table 16-3, checked with operands that decide each attempt at its first tick: not over and, and over or, or over iff, iff over implies, implies to the right and over |-> and #-#, and if-else and the abort operators lowest, with all expression operators above them (IEEE 1800-2023 Section 16.12)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_operator_precedence_one_tick.expected
*/
// IEEE 1800-2023 §16.12, Table 16-3: from higher to lower precedence, the
// property operators are not (with nexttime); and; or; iff; until and
// implies, grouping to the right; |->, |=>, #-# and #=#, also to the right;
// and last if-else, case, always, eventually and the abort operators
// accept_on, reject_on, sync_accept_on and sync_reject_on. The operators of
// Table 11-2 bind tighter than all of them.
// Each assertion below is written without parentheses; its operands are
// Boolean, so every attempt passes or fails at the tick where it starts.
// The eight ticks at 5, 15, ..., 75 take a, b, c through 000 to 111, with e
// high at the second, third, sixth and seventh. For each assertion the pass
// and fail actions write P or F per tick, and the strings are printed at the
// end. The comment after each assertion gives the grouping; another
// grouping gives a different string.
// Icarus Verilog 13.0 does not support these assertions. Verilator 5.052
// rejects if-else with a pass action and a or b iff c, and without them
// gives other strings for not a or not b and c, a #-# b implies c, the two
// reject_on forms and a || b and c.

`timescale 1ns/1ns

module test_property_operator_precedence_one_tick;
  logic clk = 0, a = 0, b = 0, c = 0, e = 0;
  string m[string];
  string order[] = '{"not a and b", "not a or not b and c", "a or b iff c", "a iff b implies c",
                      "a implies b implies c", "a |-> b implies c", "a #-# b implies c",
                      "if (e) a else b or c", "accept_on (e) a and b", "reject_on (e) a or b",
                      "sync_accept_on (e) a and b", "sync_reject_on (e) a or b", "a || b and c",
                      "a ? b : c iff e"};

  function automatic void r(string name, string v);
    if (m.exists(name)) m[name] = {m[name], v};
    else m[name] = v;
  endfunction

  always #5 clk = ~clk;   // ticks at 5, 15, ..., 75

  // (not a) and b
  p1: assert property (@(posedge clk) not a and b)
    r("not a and b", "P"); else r("not a and b", "F");
  // (not a) or ((not b) and c)
  p2: assert property (@(posedge clk) not a or not b and c)
    r("not a or not b and c", "P"); else r("not a or not b and c", "F");
  // (a or b) iff c
  p3: assert property (@(posedge clk) a or b iff c)
    r("a or b iff c", "P"); else r("a or b iff c", "F");
  // (a iff b) implies c
  p4: assert property (@(posedge clk) a iff b implies c)
    r("a iff b implies c", "P"); else r("a iff b implies c", "F");
  // a implies (b implies c)
  p5: assert property (@(posedge clk) a implies b implies c)
    r("a implies b implies c", "P"); else r("a implies b implies c", "F");
  // a |-> (b implies c)
  p6: assert property (@(posedge clk) a |-> b implies c)
    r("a |-> b implies c", "P"); else r("a |-> b implies c", "F");
  // a #-# (b implies c)
  p7: assert property (@(posedge clk) a #-# b implies c)
    r("a #-# b implies c", "P"); else r("a #-# b implies c", "F");
  // if (e) a else (b or c)
  p8: assert property (@(posedge clk) if (e) a else b or c)
    r("if (e) a else b or c", "P"); else r("if (e) a else b or c", "F");
  // accept_on (e) (a and b)
  p9: assert property (@(posedge clk) accept_on (e) a and b)
    r("accept_on (e) a and b", "P"); else r("accept_on (e) a and b", "F");
  // reject_on (e) (a or b)
  p10: assert property (@(posedge clk) reject_on (e) a or b)
    r("reject_on (e) a or b", "P"); else r("reject_on (e) a or b", "F");
  // sync_accept_on (e) (a and b)
  p11: assert property (@(posedge clk) sync_accept_on (e) a and b)
    r("sync_accept_on (e) a and b", "P"); else r("sync_accept_on (e) a and b", "F");
  // sync_reject_on (e) (a or b)
  p12: assert property (@(posedge clk) sync_reject_on (e) a or b)
    r("sync_reject_on (e) a or b", "P"); else r("sync_reject_on (e) a or b", "F");
  // (a || b) and c
  p13: assert property (@(posedge clk) a || b and c)
    r("a || b and c", "P"); else r("a || b and c", "F");
  // (a ? b : c) iff e
  p14: assert property (@(posedge clk) a ? b : c iff e)
    r("a ? b : c iff e", "P"); else r("a ? b : c iff e", "F");

  initial begin
    for (int k = 0; k < 8; k++) begin
      {a, b, c} = k[2:0];
      e = k inside {1, 2, 5, 6};
      #10;
    end
    foreach (order[i]) $display("%s: %s", order[i], m.exists(order[i]) ? m[order[i]] : "");
    $finish;
  end
endmodule
