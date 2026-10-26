/*
:name: test_sequence_method_empty_matches
:description: An empty match of a sequence that admits one does not activate the triggered method, and an empty source match does not activate the matched method at the destination clock, so neither method reports the empty matches that b[*0:1] makes at every tick (IEEE 1800-2023 Section 16.13.6)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.13.6 16.13.5 16.9.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_method_empty_matches.expected
*/
// IEEE 1800-2023 §16.13.6: if a sequence admits an empty match, such empty
// matches shall not activate the triggered or matched methods. se = b[*0:1]
// admits the empty match at every tick and a nonempty match only where b is
// true. Under c1's clock b is true only at the tick at 25, so se.triggered is
// true only there and the cover with the method records only 25. se2 has the
// same body under c2, whose ticks are 10, 20, 30 and 40; the source has a
// nonempty match only at 20, so matched is true at the first c1 tick after
// it, 25, and not at 15 after the empty match at 10, nor at 35 after the
// empty match at 30.

`timescale 1ns/1ns

module test_sequence_method_empty_matches;
  logic c1 = 0, c2 = 0, b = 0;
  int t_trig[$], t_match[$];

  always #5 c1 = ~c1;    // ticks at 5, 15, 25, 35, 45
  always #10 c2 = ~c2;   // ticks at 10, 20, 30, 40

  initial begin
    #18 b = 1;
    #9 b = 0;    // 27
  end

  sequence se;
    b[*0:1];
  endsequence

  sequence se2;
    @(posedge c2) b[*0:1];
  endsequence

  c_trig: cover property (@(posedge c1) se.triggered) t_trig.push_back($time);
  c_match: cover property (@(posedge c1) se2.matched) t_match.push_back($time);

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    #60;
    $display("triggered:%s", times(t_trig));
    $display("matched:%s", times(t_match));
    $finish;
  end
endmodule
