/*
:name: test_sequence_throughout_within_expansions
:description: e throughout s matches exactly where its expansion e[*0:$] intersect s matches, and s1 within s2 exactly where (1[*0:$] ##1 s1 ##1 1[*0:$]) intersect s2 matches, including matches of s2 that s1 starts or ends with and attempts with several matches (IEEE 1800-2023 Sections 16.9.9, 16.9.10)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.9 16.9.10 16.9.6 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_throughout_within_expansions.expected
*/
// IEEE 1800-2023 §16.9.9: e throughout s abbreviates (e)[*0:$] intersect s,
// so it matches where s matches and e holds at every tick of that match.
// §16.9.10: s1 within s2 abbreviates (1[*0:$] ##1 s1 ##1 1[*0:$]) intersect
// s2, so it matches where s2 matches and s1 matches inside it; s1 may start
// at the first tick of s2 and end at its last. §16.9.6: intersect needs both
// operands to match over the same ticks. Each pair of cover sequences
// checks a form next to its expansion; start signals fix the first tick of
// the only attempts that can match (tick n at 10 * n + 5), and every match
// adds its end time to the list of its cover (§16.14.3).
// Throughout: from tick 0, b ##[1:3] c ends at 1, 2 and 3 and e holds at 0
// to 2, so there are matches at 15 and 25; from tick 5 e is low at the first
// tick, so there is none.
// Within: from tick 10, s ##[2:4] s ends at 12, 13 and 14, and x ##1 x at 11
// and 12 lies inside each, ending with the first: matches at 125, 135 and
// 145. From tick 20, s ##2 s covers 20 to 22, while x ##1 x starts at 19 or
// ends at 23: no match. From tick 30, x ##1 x at 30 and 31 starts with s ##2
// s, which ends at 32: a match at 325.

`timescale 1ns/1ns

module test_sequence_throughout_within_expansions;
  logic clk = 0, st = 0, e = 0, b = 0, c = 0, st2 = 0, s = 0, x = 0;
  int m_thr[$], m_thr_x[$], m_win[$], m_win_x[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  c_thr: cover sequence (@(posedge clk) st ##0 (e throughout b ##[1:3] c)) m_thr.push_back($time);
  c_thr_x: cover sequence (@(posedge clk) st ##0 (e[*0:$] intersect b ##[1:3] c))
    m_thr_x.push_back($time);
  c_win: cover sequence (@(posedge clk) st2 ##0 (x ##1 x within s ##[2:4] s))
    m_win.push_back($time);
  c_win_x: cover sequence (@(posedge clk)
                           st2 ##0 ((1'b1[*0:$] ##1 x ##1 x ##1 1'b1[*0:$]) intersect s ##[2:4] s))
    m_win_x.push_back($time);

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
    for (int n = 0; n < 36; n++) begin
      st = at(n, '{0, 5}); b = at(n, '{0, 5}); c = at(n, '{1, 2, 3, 6}); e = at(n, '{0, 1, 2, 6});
      st2 = at(n, '{10, 20, 30}); s = at(n, '{10, 12, 13, 14, 20, 22, 30, 32});
      x = at(n, '{11, 12, 19, 20, 22, 23, 30, 31});
      #10;
    end
    $display("e throughout b ##[1:3] c:%s", times(m_thr));
    $display("e[*0:$] intersect b ##[1:3] c:%s", times(m_thr_x));
    $display("x ##1 x within s ##[2:4] s:%s", times(m_win));
    $display("(1[*0:$] ##1 x ##1 x ##1 1[*0:$]) intersect s ##[2:4] s:%s", times(m_win_x));
    $finish;
  end
endmodule
