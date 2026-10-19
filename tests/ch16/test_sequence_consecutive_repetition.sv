/*
:name: test_sequence_consecutive_repetition
:description: b[*m:n] matches any number of consecutive repetitions in the range, b[+] at every tick of a run of b, a repeated sequence repeats as a whole, b[*0] is an empty match that shortens the concatenation by one tick, and an empty match fused with ##0 never matches (IEEE 1800-2023 Sections 16.9.2, 16.9.2.1)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.2 16.9.2.1 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_consecutive_repetition.expected
*/
// IEEE 1800-2023 §16.9.2: consecutive repetition [*m:n] matches the operand
// m to n times in a row, one tick after the other, and ends at the end of the
// last repetition; [+] is [*1:$]. §16.9.2.1: [*0] is the empty sequence, so
// a ##1 b[*0:1] ##2 c is (a ##2 c) or (a ##1 b ##2 c), and empty ##0 s never
// matches. Each cover sequence records the end time of every match
// (§16.14.3). a is high at 5 and 65, b at 15 to 35, and c at 25 to 45 and 85:
// from 5, b[*2:3] ends at 25 and 35 and is followed by c at 35 and 45;
// b[*0:1] gives c at 25 or, after b at 15, c at 35; (b ##1 c)[*2] is b at 15,
// c at 25, b at 35 and c at 45. From 65 only a ##2 c matches, at 85.

`timescale 1ns/1ns

module test_sequence_consecutive_repetition;
  logic clk = 0, a = 0, b = 0, c = 0;
  int m_range[$], m_opt[$], m_plus[$], m_seq[$], m_empty[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  c_range: cover sequence (@(posedge clk) a ##1 b[*2:3] ##1 c) m_range.push_back($time);
  c_opt: cover sequence (@(posedge clk) a ##1 b[*0:1] ##2 c) m_opt.push_back($time);
  c_plus: cover sequence (@(posedge clk) a ##1 b[+]) m_plus.push_back($time);
  c_seq: cover sequence (@(posedge clk) a ##1 (b ##1 c)[*2]) m_seq.push_back($time);
  c_empty: cover sequence (@(posedge clk) a[*0] ##0 b) m_empty.push_back($time);

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
    tick(1, 0, 0); tick(0, 1, 0); tick(0, 1, 1); tick(0, 1, 1); tick(0, 0, 1);
    tick(0, 0, 0); tick(1, 0, 0); tick(0, 0, 0); tick(0, 0, 1); tick(0, 0, 0);
    tick(0, 0, 0);
    $display("a ##1 b[*2:3] ##1 c:%s", times(m_range));
    $display("a ##1 b[*0:1] ##2 c:%s", times(m_opt));
    $display("a ##1 b[+]:%s", times(m_plus));
    $display("a ##1 (b ##1 c)[*2]:%s", times(m_seq));
    $display("a[*0] ##0 b:%s", times(m_empty));
    $finish;
  end
endmodule
