/*
:name: test_sequence_precedence_repetition_within
:description: the repetition operators [*], [->] and [=] bind tighter than ##, within binds tighter than intersect, and a chain of throughout groups from the right, as in Table 16-1 (IEEE 1800-2023 Section 16.9.1)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.1 16.9.2 16.9.6 16.9.9 16.9.10 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_precedence_repetition_within.expected
*/
// IEEE 1800-2023 §16.9.1 (Table 16-1): [*], [=] and [->] have the highest
// precedence, then ##, throughout (grouping from the right), within and
// intersect. Each cover sequence uses its own signals in its own stretch of
// ticks (tick n at 10 * n + 5) and records the end time of every match
// (§16.14.3).
// c_rep is a ##1 b[*2] ##1 c, that is a ##1 (b ##1 b) ##1 c (§16.9.2): a at
// 0, b at 1 and 2 and c at 3 give a match at 35; a, b, a, b, c at 5 to 9,
// which (a ##1 b)[*2] ##1 c would match at 95, give none.
// c_goto is g ##1 h[->2] ##1 k: g at 11, h at 13 and 15, k at 16, a match at
// 165. c_nonc is u ##1 v[=2] ##1 w: u at 20, v at 21 and 23, w at 25, a match
// at 255, since [=2] may go on past the last v while v stays low.
// c_win is p ##2 p intersect q within r ##2 r, that is (p ##2 p) intersect
// (q within (r ##2 r)) (§16.9.6, §16.9.10): p and r at 30 and 32 and q at 31
// give a match at 325, where ((p ##2 p) intersect q) within (r ##2 r) could
// never match, as p ##2 p and q differ in length; with q at 35, before r at
// 36 and 38, there is no match.
// c_thr is x throughout y throughout s ##2 s, that is x throughout (y
// throughout (s ##2 s)) (§16.9.9): s at 40 and 42 with x and y at 40 to 42
// give a match at 425; y low at 47 (s at 45 and 47) and x low at 52 (s at 50
// and 52) give none.

`timescale 1ns/1ns

module test_sequence_precedence_repetition_within;
  logic clk = 0;
  logic a = 0, b = 0, c = 0, g = 0, h = 0, k = 0, u = 0, v = 0, w = 0;
  logic p = 0, q = 0, r = 0, x = 0, y = 0, s = 0;
  int m_rep[$], m_goto[$], m_nonc[$], m_win[$], m_thr[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  c_rep: cover sequence (@(posedge clk) a ##1 b[*2] ##1 c) m_rep.push_back($time);
  c_goto: cover sequence (@(posedge clk) g ##1 h[->2] ##1 k) m_goto.push_back($time);
  c_nonc: cover sequence (@(posedge clk) u ##1 v[=2] ##1 w) m_nonc.push_back($time);
  c_win: cover sequence (@(posedge clk) p ##2 p intersect q within r ##2 r)
    m_win.push_back($time);
  c_thr: cover sequence (@(posedge clk) x throughout y throughout s ##2 s)
    m_thr.push_back($time);

  function automatic string times(int t[$]);
    string str = "";
    foreach (t[i]) str = {str, $sformatf(" %0d", t[i])};
    return str;
  endfunction

  // Each signal is high at the ticks listed.
  function automatic logic at(int n, int ticks[$]);
    foreach (ticks[i]) if (ticks[i] == n) return 1'b1;
    return 1'b0;
  endfunction

  initial begin
    for (int n = 0; n < 56; n++) begin
      a = at(n, '{0, 5, 7}); b = at(n, '{1, 2, 6, 8}); c = at(n, '{3, 9});
      g = at(n, '{11}); h = at(n, '{13, 15}); k = at(n, '{16});
      u = at(n, '{20}); v = at(n, '{21, 23}); w = at(n, '{25});
      p = at(n, '{30, 32, 36, 38}); q = at(n, '{31, 35}); r = at(n, '{30, 32, 36, 38});
      s = at(n, '{40, 42, 45, 47, 50, 52});
      x = at(n, '{40, 41, 42, 45, 46, 47, 50, 51});
      y = at(n, '{40, 41, 42, 45, 46, 50, 51, 52});
      #10;
    end
    $display("a ##1 b[*2] ##1 c:%s", times(m_rep));
    $display("g ##1 h[->2] ##1 k:%s", times(m_goto));
    $display("u ##1 v[=2] ##1 w:%s", times(m_nonc));
    $display("p ##2 p intersect q within r ##2 r:%s", times(m_win));
    $display("x throughout y throughout s ##2 s:%s", times(m_thr));
    $finish;
  end
endmodule
