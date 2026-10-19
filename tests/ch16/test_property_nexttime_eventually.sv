/*
:name: test_property_nexttime_eventually
:description: nexttime p and nexttime[n] p check p at the next and at the n-th next clock tick, and eventually[m:n] p and s_eventually[m:n] p are true only if p holds at one of the m-th to n-th ticks, not earlier or later (IEEE 1800-2023 Sections 16.12.10, 16.12.13)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.10 16.12.13 16.12.7 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_nexttime_eventually.expected
*/
// IEEE 1800-2023 §16.12.10: nexttime p is true if p is true at the next clock
// tick (or there is none) and nexttime[n] p if p is true at the last of the
// next n ticks. §16.12.13: eventually[m:n] p and s_eventually[m:n] p are true
// if p is true at one of the ticks from the m-th to the n-th after the start;
// with all those ticks present the weak and strong forms agree. Each assertion
// checks start |-> ... (§16.12.7), and the fail actions count failures per
// phase (§16.14.1). In each phase start is high at its first tick and x at
// exactly one later tick: one, two, three or four ticks after start. Every
// phase lasts six ticks, so all ticks the properties look at exist.

`timescale 1ns/1ns

module test_property_nexttime_eventually;
  logic clk = 0, start = 0, x = 0;
  int f_next = 0, f_next2 = 0, f_ev = 0, f_sev = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_next: assert property (@(posedge clk) start |-> nexttime x) else f_next++;
  a_next2: assert property (@(posedge clk) start |-> nexttime [2] x) else f_next2++;
  a_ev: assert property (@(posedge clk) start |-> eventually [2:3] x) else f_ev++;
  a_sev: assert property (@(posedge clk) start |-> s_eventually [2:3] x) else f_sev++;

  // Runs one phase: start at its first tick, x the given number of ticks later.
  task automatic phase(int later);
    for (int i = 0; i < 6; i++) begin
      start = (i == 0);
      x = (i == later);
      #10;
    end
    $display("x after %0d: nexttime %0d, nexttime[2] %0d, eventually %0d, s_eventually %0d",
             later, f_next, f_next2, f_ev, f_sev);
    f_next = 0;
    f_next2 = 0;
    f_ev = 0;
    f_sev = 0;
  endtask

  initial begin
    phase(1);
    phase(2);
    phase(3);
    phase(4);
    $finish;
  end
endmodule
