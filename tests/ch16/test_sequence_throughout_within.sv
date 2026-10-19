/*
:name: test_sequence_throughout_within
:description: e throughout s matches where s matches and e holds at every tick of the match, from its first tick on, and s1 within s2 where s2 matches and s1 matches inside it, neither starting before s2 starts nor ending after s2 ends (IEEE 1800-2023 Sections 16.9.9, 16.9.10)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.9 16.9.10 16.9.6 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_throughout_within.expected
*/
// IEEE 1800-2023 §16.9.9: e throughout s is e[*0:$] intersect s (§16.9.6),
// so it matches wherever s matches and e is true at every tick from the first
// tick of that match to its last. §16.9.10: s1 within s2 matches where s2
// matches and s1 matches along ticks that start no earlier and end no later
// than the match of s2; it ends where s2 ends. Each cover sequence records the
// end time of its matches (§16.14.3).
// The throughout part checks req ##0 (en throughout ##[1:2] ack), whose
// match runs from the req tick to the ack tick: at 5 en holds to the ack at
// 25; at 45 en drops at the ack at 65; at 85 en is low at the req tick; at
// 115 ack comes one and two ticks later with en held, which gives two matches.
// The within part checks (x ##1 x) within (s ##3 s): s2 matches from 155 to
// 185 with x at 165 and 175, and from 205 to 235 with x at 225 and 235; from
// 275 to 305, x ##1 x matches from 265 to 275, starting too early, and from
// 305 to 315, ending too late.

`timescale 1ns/1ns

module test_sequence_throughout_within;
  logic clk = 0, req = 0, en = 0, ack = 0, s = 0, x = 0;
  int m_thr[$], m_win[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  c_thr: cover sequence (@(posedge clk) req ##0 (en throughout ##[1:2] ack))
    m_thr.push_back($time);
  c_win: cover sequence (@(posedge clk) (x ##1 x) within (s ##3 s)) m_win.push_back($time);

  // Set the values sampled at the next tick.
  task automatic tick_thr(logic vreq, logic ven, logic vack);
    req = vreq;
    en = ven;
    ack = vack;
    #10;
  endtask

  task automatic tick_win(logic vs, logic vx);
    s = vs;
    x = vx;
    #10;
  endtask

  function automatic string times(int q[$]);
    string r = "";
    foreach (q[i]) r = {r, $sformatf(" %0d", q[i])};
    return r;
  endfunction

  initial begin
    tick_thr(1, 1, 0); tick_thr(0, 1, 0); tick_thr(0, 1, 1); tick_thr(0, 0, 0);
    tick_thr(1, 1, 0); tick_thr(0, 1, 0); tick_thr(0, 0, 1); tick_thr(0, 0, 0);
    tick_thr(1, 0, 0); tick_thr(0, 1, 1); tick_thr(0, 0, 0);
    tick_thr(1, 1, 0); tick_thr(0, 1, 1); tick_thr(0, 1, 1); tick_thr(0, 0, 0);
    tick_win(1, 0); tick_win(0, 1); tick_win(0, 1); tick_win(1, 0); tick_win(0, 0);
    tick_win(1, 0); tick_win(0, 0); tick_win(0, 1); tick_win(1, 1); tick_win(0, 0);
    tick_win(0, 0); tick_win(0, 1); tick_win(1, 1); tick_win(0, 0); tick_win(0, 0);
    tick_win(1, 1); tick_win(0, 1); tick_win(0, 0);
    $display("throughout:%s", times(m_thr));
    $display("within:%s", times(m_win));
    $finish;
  end
endmodule
