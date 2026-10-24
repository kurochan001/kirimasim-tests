/*
:name: test_assertion_clock_expressions_global_clock
:description: an assertion clocked by @($global_clock) ticks with the event of the global clocking declaration like any other clock, and a clock can be gated with iff, an or of two edges, or the edge of an expression, which ticks only once where its operands overlap (IEEE 1800-2023 Section 16.5.2)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assertion_clock_expressions_global_clock.expected
*/
// IEEE 1800-2023 §16.5.2: $global_clock refers to the clocking event of the
// global clocking declaration and behaves as any other clocking event, so
// @($global_clock) v is checked at the same ticks as @(posedge gclk) v. The
// clock of an assertion can be more than a signal: gated with iff (the tick
// happens only where the gate is true at the edge), an or of two edges, or
// the edge of an expression. c1 is high from 12 to 16 and from 52 to 54, c2
// from 14 to 18 and from 72 to 74: posedge c1 or posedge c2 ticks at 12, 14,
// 52 and 72, while posedge (c1 | c2) ticks at 12, 52 and 72, as c1 | c2 rises
// once while the two pulses overlap. gclk rises at 5, 15, ..., 85, and en is
// high from 20 to 60. v is 1, 0, 1, 1, 0, 1, 0, 1, 0 in the intervals of 10
// from 0. Each assertion records time:P or time:F; the lists are printed at
// 95.
// Icarus Verilog 13.0 does not support these assertions; Verilator 5.052
// rejects or in the clock of an assertion (the other lists agree with the
// standard).

`timescale 1ns/1ns

module test_assertion_clock_expressions_global_clock;
  logic gclk = 0, en = 0, c1 = 0, c2 = 0, v = 0;
  string m[string];
  string order[] = '{"@($global_clock)", "@(posedge gclk)", "@(posedge gclk iff en)",
                      "@(posedge c1 or posedge c2)", "@(posedge (c1 | c2))"};

  global clocking gc @(posedge gclk); endclocking

  function automatic void hit(string name, string r);
    string t = $sformatf(" %0t:%s", $time, r);
    if (m.exists(name)) m[name] = {m[name], t};
    else m[name] = t;
  endfunction

  always #5 gclk = ~gclk;   // rising edges at 5, 15, ..., 85

  a_g: assert property (@($global_clock) v)
    hit("@($global_clock)", "P"); else hit("@($global_clock)", "F");
  a_ref: assert property (@(posedge gclk) v)
    hit("@(posedge gclk)", "P"); else hit("@(posedge gclk)", "F");
  a_iff: assert property (@(posedge gclk iff en) v)
    hit("@(posedge gclk iff en)", "P"); else hit("@(posedge gclk iff en)", "F");
  a_or: assert property (@(posedge c1 or posedge c2) v)
    hit("@(posedge c1 or posedge c2)", "P"); else hit("@(posedge c1 or posedge c2)", "F");
  a_expr: assert property (@(posedge (c1 | c2)) v)
    hit("@(posedge (c1 | c2))", "P"); else hit("@(posedge (c1 | c2))", "F");

  initial begin
    v = 1;
    #10 v = 0;
    #10 v = 1; en = 1;   // 20
    #10 v = 1;           // 30
    #10 v = 0;           // 40
    #10 v = 1;           // 50
    #10 v = 0; en = 0;   // 60
    #10 v = 1;           // 70
    #10 v = 0;           // 80
  end

  initial begin
    #12 c1 = 1;
    #2 c2 = 1;    // 14
    #2 c1 = 0;    // 16
    #2 c2 = 0;    // 18
    #34 c1 = 1;   // 52
    #2 c1 = 0;    // 54
    #18 c2 = 1;   // 72
    #2 c2 = 0;    // 74
    #21;          // 95
    foreach (order[i]) $display("%s: [%s ]", order[i], m.exists(order[i]) ? m[order[i]] : "");
    $finish;
  end
endmodule
