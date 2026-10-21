/*
:name: test_sequence_intersect_within_precedence
:description: intersect binds tighter than and, throughout tighter than within, and within groups from the left, as in Table 16-1; s1 within s2 may start with s2 and gives a match for each match of s2 that contains s1 (IEEE 1800-2023 Sections 16.9.1, 16.9.10)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.1 16.9.10 16.9.6 16.9.5 16.9.9 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_intersect_within_precedence.expected
*/
// IEEE 1800-2023 §16.9.1 (Table 16-1): ## binds tighter than throughout,
// throughout than within, within than intersect and intersect than and;
// within is left-associative. §16.9.6: s1 intersect s2 needs matches of the
// same length; §16.9.5: s1 and s2 ends at the later end. §16.9.9: e
// throughout s needs e at every tick of s. §16.9.10: s1 within s2 matches
// where s2 matches and s1 matches inside it, starting no earlier and ending
// no later. Each cover sequence records the end time of every match
// (§16.14.3); each uses its own signals, in its own stretch of ticks.
// c_int is (a ##1 b intersect a ##1 c) and d ##2 e: a and d at 5, b and c
// at 15, e at 25 give a match at 25; grouped as a ##1 b intersect (a ##1 c
// and d ##2 e) it could never match, two ticks against three.
// c_thr is (en throughout x ##1 x) within s ##3 s: s at 75 and 105, x and en
// at 85 and 95 give a match at 105; grouped the other way en would be needed
// at 75 too.
// c_assoc is (y within w ##1 w) within z ##3 z. z at 135 and 165, w at 145
// and 155, y at 135: y is inside z ##3 z but not inside w ##1 w, so there is
// no match, where y within (w ##1 w within z ##3 z) would match at 165. z at
// 195 and 225, w at 205 and 215 and y at 215 give a match at 225.
// c_bounds is m within k ##[2:3] k: k at 245, 265 and 275 gives two matches
// of k ##[2:3] k from 245, and m at 245, their first tick, is inside both.

`timescale 1ns/1ns

module test_sequence_intersect_within_precedence;
  logic clk = 0;
  logic a = 0, b = 0, c = 0, d = 0, e = 0;
  logic en = 0, x = 0, s = 0;
  logic y = 0, w = 0, z = 0;
  logic m = 0, k = 0;
  int m_int[$], m_thr[$], m_assoc[$], m_bounds[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  c_int: cover sequence (@(posedge clk) a ##1 b intersect a ##1 c and d ##2 e)
    m_int.push_back($time);
  c_thr: cover sequence (@(posedge clk) en throughout x ##1 x within s ##3 s)
    m_thr.push_back($time);
  c_assoc: cover sequence (@(posedge clk) y within w ##1 w within z ##3 z)
    m_assoc.push_back($time);
  c_bounds: cover sequence (@(posedge clk) m within k ##[2:3] k) m_bounds.push_back($time);

  function automatic string times(int q[$]);
    string r = "";
    foreach (q[i]) r = {r, $sformatf(" %0d", q[i])};
    return r;
  endfunction

  // Each signal is high for the ticks listed (tick n at 10 * n + 5).
  function automatic logic at(int n, int ticks[$]);
    foreach (ticks[i]) if (ticks[i] == n) return 1'b1;
    return 1'b0;
  endfunction

  initial begin
    for (int n = 0; n < 32; n++) begin
      a = at(n, '{0}); b = at(n, '{1}); c = at(n, '{1}); d = at(n, '{0}); e = at(n, '{2});
      s = at(n, '{7, 10}); x = at(n, '{8, 9}); en = at(n, '{8, 9});
      z = at(n, '{13, 16, 19, 22}); w = at(n, '{14, 15, 20, 21}); y = at(n, '{13, 21});
      k = at(n, '{24, 26, 27}); m = at(n, '{24});
      #10;
    end
    $display("a ##1 b intersect a ##1 c and d ##2 e:%s", times(m_int));
    $display("en throughout x ##1 x within s ##3 s:%s", times(m_thr));
    $display("y within w ##1 w within z ##3 z:%s", times(m_assoc));
    $display("m within k ##[2:3] k:%s", times(m_bounds));
    $finish;
  end
endmodule
