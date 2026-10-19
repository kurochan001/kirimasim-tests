/*
:name: test_sequence_triggered
:description: s.triggered is true from the Observed region of the time step in which the sequence reaches an end point to the end of that time step, so a wait or a program sees it but a module process woken by the clock edge does not; @(s) resumes at each end point, and triggered can be used inside another sequence (IEEE 1800-2023 Sections 16.13.6, 9.4.2.4)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.13.6 9.4.2.4 9.4.3 24.3 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_triggered.expected
*/
// IEEE 1800-2023 §16.13.6: s.triggered is true if s has reached its end point
// at that point in time; the status is set in the Observed region and lasts
// for the rest of the time step. A wait statement (§9.4.3) on it therefore
// resumes at each end point, and code of a program, which runs in the
// Reactive region after the Observed region (§24.3), sees it at the clock
// edge, but a module process woken by the same clock edge runs in the Active
// region, before the Observed region, and does not. §9.4.2.4: @(s) blocks
// until s reaches an end point and resumes after that Observed region.
// s_ab is a ##1 b and ends at 15 and 45. The cover sequence (§16.14.3) of
// s_ab.triggered ##1 c matches at 25, where c follows the end at 15.

`timescale 1ns/1ns

module test_sequence_triggered;
  logic clk = 0, a = 0, b = 0, c = 0;
  int m_wait[$], m_event[$], m_prog[$], m_then[$];
  int seen_in_module = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  sequence s_ab;
    @(posedge clk) a ##1 b;
  endsequence

  initial forever begin
    wait (s_ab.triggered);
    m_wait.push_back($time);
    @(posedge clk);
  end

  always @(s_ab) m_event.push_back($time);

  always @(posedge clk) if (s_ab.triggered) seen_in_module++;

  c_then: cover sequence (@(posedge clk) s_ab.triggered ##1 c) m_then.push_back($time);

  program p;
    initial forever @(posedge clk) if (s_ab.triggered) m_prog.push_back($time);
  endprogram

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
    tick(1, 0, 0); tick(0, 1, 0); tick(0, 0, 1); tick(1, 1, 0); tick(0, 1, 0);
    tick(0, 0, 0); tick(0, 0, 0);
    $display("wait (s_ab.triggered):%s", times(m_wait));
    $display("@(s_ab):%s", times(m_event));
    $display("program at posedge clk:%s", times(m_prog));
    $display("module at posedge clk: %0d", seen_in_module);
    $display("s_ab.triggered ##1 c:%s", times(m_then));
    $finish;
  end
endmodule
