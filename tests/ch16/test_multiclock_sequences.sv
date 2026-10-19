/*
:name: test_multiclock_sequences
:description: in a multiclocked sequence ##1 moves to the nearest strictly later tick of the next clock and ##0 to the nearest tick that may coincide; the multiclocked implications |=> and |-> wait for the consequent clock in the same ways (IEEE 1800-2023 Sections 16.13.1, 16.13.2)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.13.1 16.13.2 16.13.3 16.14.1 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_multiclock_sequences.expected
*/
// IEEE 1800-2023 §16.13.1: in @(posedge c1) a ##1 @(posedge c2) b, ##1 goes
// from the end of a at a tick of c1 to the nearest tick of c2 strictly after
// it; with ##0 it goes to the nearest tick of c2 that may coincide with it.
// §16.13.2: @(posedge c1) a |=> @(posedge c2) b checks b at the nearest tick
// of c2 strictly after the end of the antecedent, and |-> at the nearest tick
// that may coincide. §16.13.3: each clock applies until the next one. c1
// rises at 5, 15, 25, 35 and 45, c2 at 5, 12, 25, 31 and 47; a is high at the
// c1 ticks at 5 and 25, b at the c2 ticks at 12 and 25. The cover statements
// (§16.14.3) record their matches and the fail actions (§16.14.1) their
// failures.

`timescale 1ns/1ns

module test_multiclock_sequences;
  logic c1 = 0, c2 = 0, a = 0, b = 0;
  int m_next[$], m_same[$], f_next[$], f_same[$];

  always #5 c1 = ~c1;   // rising edges at 5, 15, 25, ...

  initial begin   // rising edges of c2 at 5, 12, 25, 31 and 47
    #5 c2 = 1; #1 c2 = 0;
    #6 c2 = 1; #1 c2 = 0;
    #12 c2 = 1; #1 c2 = 0;
    #5 c2 = 1; #1 c2 = 0;
    #15 c2 = 1; #1 c2 = 0;
  end

  initial begin
    a = 1;          // sampled by c1 at 5
    #8 b = 1;       // sampled by c2 at 12
    #2 a = 0;
    #3 b = 0;
    #7 a = 1;       // 20: sampled by c1 at 25
    b = 1;          // sampled by c2 at 25
    #6 a = 0;
    b = 0;
  end

  c_next: cover sequence (@(posedge c1) a ##1 @(posedge c2) b) m_next.push_back($time);
  c_same: cover sequence (@(posedge c1) a ##0 @(posedge c2) b) m_same.push_back($time);
  a_next: assert property (@(posedge c1) a |=> @(posedge c2) b) else f_next.push_back($time);
  a_same: assert property (@(posedge c1) a |-> @(posedge c2) b) else f_same.push_back($time);

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    #60;
    $display("a ##1 b matches:%s", times(m_next));
    $display("a ##0 b matches:%s", times(m_same));
    $display("a |=> b failures:%s", times(f_next));
    $display("a |-> b failures:%s", times(f_same));
    $finish;
  end
endmodule
