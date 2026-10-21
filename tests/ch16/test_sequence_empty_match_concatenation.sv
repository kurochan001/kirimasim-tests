/*
:name: test_sequence_empty_match_concatenation
:description: an empty sequence b[*0] concatenated with ##n, n > 0, shortens the concatenation by one tick on either side, with ##0 it never matches, and a repetition range from 0 adds the shortened case (IEEE 1800-2023 Section 16.9.2.1)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.2.1 16.9.2 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_empty_match_concatenation.expected
*/
// IEEE 1800-2023 §16.9.2.1: b[*0] is the empty sequence. For n > 0, empty ##n
// seq is ##(n-1) seq and seq ##n empty is seq ##(n-1) `true; seq ##0 empty
// never matches. So a ##1 b[*0] ##1 c is a ##1 c, b[*0] ##2 c is ##1 c,
// b[*0] ##1 c is c, a ##2 b[*0] is a ##1 1, and a ##0 b[*0] has no match.
// a ##1 b[*0:2] ##1 c is the or of a ##1 c, a ##1 b ##1 c and a ##1 b[*2]
// ##1 c (§16.9.2). Each cover sequence records the end time of every match
// (§16.14.3). a is high at 5 and 55, b at 15, 65 and 75, c at 5, 15, 25
// and 85. ##1 c, started at every tick, matches one tick after a start, so
// not at 5, the first tick; c alone matches at 5 too.

`timescale 1ns/1ns

module test_sequence_empty_match_concatenation;
  logic clk = 0, a = 0, b = 0, c = 0;
  int m_mid[$], m_lead2[$], m_lead1[$], m_trail2[$], m_trail0[$], m_range[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  c_mid: cover sequence (@(posedge clk) a ##1 b[*0] ##1 c) m_mid.push_back($time);
  c_lead2: cover sequence (@(posedge clk) b[*0] ##2 c) m_lead2.push_back($time);
  c_lead1: cover sequence (@(posedge clk) b[*0] ##1 c) m_lead1.push_back($time);
  c_trail2: cover sequence (@(posedge clk) a ##2 b[*0]) m_trail2.push_back($time);
  c_trail0: cover sequence (@(posedge clk) a ##0 b[*0]) m_trail0.push_back($time);
  c_range: cover sequence (@(posedge clk) a ##1 b[*0:2] ##1 c) m_range.push_back($time);

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
    tick(1, 0, 1); tick(0, 1, 1); tick(0, 0, 1); tick(0, 0, 0); tick(0, 0, 0);
    tick(1, 0, 0); tick(0, 1, 0); tick(0, 1, 0); tick(0, 0, 1); tick(0, 0, 0);
    $display("a ##1 b[*0] ##1 c:%s", times(m_mid));
    $display("b[*0] ##2 c:%s", times(m_lead2));
    $display("b[*0] ##1 c:%s", times(m_lead1));
    $display("a ##2 b[*0]:%s", times(m_trail2));
    $display("a ##0 b[*0]:%s", times(m_trail0));
    $display("a ##1 b[*0:2] ##1 c:%s", times(m_range));
    $finish;
  end
endmodule
