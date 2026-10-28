/*
:name: test_triggered_matched_multiclock
:description: triggered detects the end point of a multiclocked sequence under its ending clock, and of a sequence used inside a multiclocked sequence under the same clock, while matched of a sequence with arguments on another clock is true only at the first destination tick after an end point (IEEE 1800-2023 Section 16.13.5)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.13.5 16.13.6 16.13.1 16.7 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_triggered_matched_multiclock.expected
*/
// IEEE 1800-2023 §16.13.5: triggered can detect the end point of a multiclocked
// sequence, and can be used inside a multiclocked sequence, when the clock
// where it is used is the ending clock of the sequence. matched works across
// clocks: it keeps an end point of the source sequence until the first tick of
// the destination clock after it (§16.13.6), and can be applied to an instance
// with arguments. c1 rises at 5, 15, 25, ...; c2 at 8, 38, 68, 98, 128 and 158.
// s_mc, a on c1 then b on the next c2 tick (§16.13.1), ends at 38 (a at 25, b
// at 38); a at 65 is followed by no b at 68. s_h ends at 98 (h at 68 and 98); g
// at 85 on c1 is followed by the c2 tick at 98. s_pair(u, v) ends on c1 at 35
// (u at 15, v at 35) and at 55 (u at 35, v at 55), so its matched is true at
// the c2 ticks 38 and 68 only. From r at 8, the singly clocked c2 prefix
// r ##[1:2] 1'b1 (§16.7) ends at 38 and at 68; ##0 then samples matched at
// that same c2 tick (§16.13.1 allows ##0 between the differently clocked
// parts), followed by q at 68 and 98; from r at 68 it finds matched false
// at 98 and 128. The covers (§16.14.3) record the times of their matches.

`timescale 1ns/1ns

module test_triggered_matched_multiclock;
  logic c1 = 0, c2 = 0, a = 0, b = 0, h = 0, g = 0, u = 0, v = 0, r = 0, q = 0;
  int m_trig[$], m_trig_in[$], m_mat[$];

  sequence s_mc;
    @(posedge c1) a ##1 @(posedge c2) b;
  endsequence

  sequence s_h;
    @(posedge c2) h ##1 h;
  endsequence

  sequence s_pair(first, second);
    @(posedge c1) first ##2 second;
  endsequence

  c_trig: cover property (@(posedge c2) s_mc.triggered) m_trig.push_back($time);
  c_trig_in: cover sequence (@(posedge c1) g ##1 @(posedge c2) s_h.triggered)
    m_trig_in.push_back($time);
  c_mat: cover sequence
    (@(posedge c2) (r ##[1:2] 1'b1) ##0 s_pair(u, v).matched ##1 q)
    m_mat.push_back($time);

  // True when a signal sampled high at the times listed has to be high at t:
  // it is high from one time unit before each such time.
  function automatic logic at(int t, int times[$]);
    foreach (times[i]) if (t == times[i] - 1 || t == times[i]) return 1'b1;
    return 1'b0;
  endfunction

  function automatic string times(int v[$]);
    string s = "";
    foreach (v[i]) s = {s, $sformatf(" %0d", v[i])};
    return s;
  endfunction

  initial begin
    for (int t = 0; t < 170; t++) begin
      c1 = t % 10 == 5;
      c2 = t % 30 == 8;
      a = at(t, '{25, 65});
      b = at(t, '{38});
      h = at(t, '{68, 98});
      g = at(t, '{55, 85});
      u = at(t, '{15, 35});
      v = at(t, '{35, 55});
      r = at(t, '{8, 68});
      q = at(t, '{68, 98});
      #1;
    end
    $display("@(posedge c2) s_mc.triggered:%s", times(m_trig));
    $display("@(posedge c1) g ##1 @(posedge c2) s_h.triggered:%s", times(m_trig_in));
    $display("@(posedge c2) r ##[1:2] s_pair(u, v).matched ##1 q:%s", times(m_mat));
    $finish;
  end
endmodule
