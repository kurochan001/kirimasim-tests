/*
:name: test_sequence_and_or_intersect
:description: s1 and s2 matches when both operands match from the same tick and ends at the later end, s1 or s2 has every match of either operand, and s1 intersect s2 only pairs of matches of the same length; cover sequence runs its statement for each match (IEEE 1800-2023 Sections 16.9.5, 16.9.6, 16.9.7)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.5 16.9.6 16.9.7 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_and_or_intersect.expected
*/
// IEEE 1800-2023 §16.9.5: both operands of and start at the same tick, and
// each pair of their matches is a match that ends where the later of the two
// ends. §16.9.6: intersect keeps only the pairs whose two matches have the same
// length. §16.9.7: the matches of or are the union of the matches of its
// operands. §16.14.3: cover sequence runs its statement once for each match,
// so the queues hold the end time of every match. Here s1 is a ##[1:3] b and
// s2 is a ##2 c. From the tick at 5, s1 ends at 15, 25 and 35 and s2 at 25;
// from 55 only s1 matches, at 65; from 95 s2 ends at 115 and s1 at 125.

`timescale 1ns/1ns

module test_sequence_and_or_intersect;
  logic clk = 0, a = 0, b = 0, c = 0;
  int m_and[$], m_or[$], m_int[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  c_and: cover sequence (@(posedge clk) (a ##[1:3] b) and (a ##2 c)) m_and.push_back($time);
  c_or: cover sequence (@(posedge clk) (a ##[1:3] b) or (a ##2 c)) m_or.push_back($time);
  c_int: cover sequence (@(posedge clk) (a ##[1:3] b) intersect (a ##2 c)) m_int.push_back($time);

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
    tick(1, 0, 0); tick(0, 1, 0); tick(0, 1, 1); tick(0, 1, 0); tick(0, 0, 0);
    tick(1, 0, 0); tick(0, 1, 0); tick(0, 0, 0); tick(0, 0, 0);
    tick(1, 0, 0); tick(0, 0, 0); tick(0, 0, 1); tick(0, 1, 0); tick(0, 0, 0);
    $display("and:%s", times(m_and));
    $display("or:%s", times(m_or));
    $display("intersect:%s", times(m_int));
    $finish;
  end
endmodule
