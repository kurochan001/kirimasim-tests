/*
:name: test_sequence_first_match
:description: first_match keeps only the earliest-ending matches of its operand, all of them when several end at that tick, which changes what a longer sequence built on it can match (IEEE 1800-2023 Section 16.9.8)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.8 16.9.7 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_first_match.expected
*/
// IEEE 1800-2023 §16.9.8: first_match(seq) matches only the match of seq that
// ends first, or all the matches that end at that same earliest tick. Each
// cover sequence runs its statement once per match (§16.14.3) and records the
// end time. From the tick at 5, a ##[1:3] b ends at 15, 25 and 35, but only
// the match at 15 is first, so first_match(...) ##1 c needs c at 25, which
// it does not get, while the plain sequence goes on with the match at 25 and
// c at 35. From 55, b ##2 later and c ##2 later both end at 75, so
// first_match of their or (§16.9.7) has two matches there. From 105 the first
// match at 115 is followed by c at 125.

`timescale 1ns/1ns

module test_sequence_first_match;
  logic clk = 0, a = 0, b = 0, c = 0;
  int m_all[$], m_first[$], m_then[$], m_first_then[$], m_tie[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  c_all: cover sequence (@(posedge clk) a ##[1:3] b) m_all.push_back($time);
  c_first: cover sequence (@(posedge clk) first_match(a ##[1:3] b)) m_first.push_back($time);
  c_then: cover sequence (@(posedge clk) (a ##[1:3] b) ##1 c) m_then.push_back($time);
  c_first_then: cover sequence (@(posedge clk) first_match(a ##[1:3] b) ##1 c)
    m_first_then.push_back($time);
  c_tie: cover sequence (@(posedge clk) first_match((a ##[1:2] b) or (a ##2 c)))
    m_tie.push_back($time);

  // Sets the values sampled at the next tick.
  task automatic tick(logic va, logic vb, logic vc);
    a = va;
    b = vb;
    c = vc;
    #10;
  endtask

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    tick(1, 0, 0); tick(0, 1, 0); tick(0, 1, 0); tick(0, 1, 1); tick(0, 0, 0);
    tick(1, 0, 0); tick(0, 0, 0); tick(0, 1, 1); tick(0, 0, 0); tick(0, 0, 0);
    tick(1, 0, 0); tick(0, 1, 0); tick(0, 0, 1); tick(0, 0, 0); tick(0, 0, 0);
    $display("a ##[1:3] b:%s", times(m_all));
    $display("first_match(a ##[1:3] b):%s", times(m_first));
    $display("(a ##[1:3] b) ##1 c:%s", times(m_then));
    $display("first_match(a ##[1:3] b) ##1 c:%s", times(m_first_then));
    $display("first_match of the or:%s", times(m_tie));
    $finish;
  end
endmodule
