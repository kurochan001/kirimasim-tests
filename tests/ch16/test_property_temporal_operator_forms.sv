/*
:name: test_property_temporal_operator_forms
:description: nexttime and nexttime[n], s_nexttime and s_nexttime[n], always and always[m:n], s_always[m:n], eventually[m:n], s_eventually[m:n] and s_eventually each look at the clock ticks their definitions name, shown by per-phase failure counts (IEEE 1800-2023 Sections 16.12.10, 16.12.11 and 16.12.13)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.10 16.12.11 16.12.13 16.12.7 16.14.1 A.2.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_temporal_operator_forms.expected
*/
// IEEE 1800-2023 §16.12.10: nexttime p needs p at the next tick, nexttime[n] p
// at the n-th next tick, and the s_ forms are their strong forms. §16.12.11:
// always p needs p at the current and every future tick, always[m:n] p at the
// ticks m to n after the start (ticks that do not exist are not required), and
// s_always[m:n] p needs those ticks and p at each. §16.12.13: eventually[m:n]
// p and s_eventually[m:n] p need p at some tick in the range, and s_eventually
// p at some current or future tick.
//
// Each assertion checks start |-> operator (§16.12.7), so one evaluation
// begins at the first tick of a phase, and the fail actions count failures
// (§16.14.1). A phase has eight ticks. In the first, p is 1 at the first four
// ticks; in the second at ticks 2 and 3; in the third at tick 3 only; in the
// fourth at tick 7 only.

`timescale 1ns/1ns

module test_property_temporal_operator_forms;
  logic clk = 0, start = 0, p = 0;
  int f_nt = 0, f_nt2 = 0, f_snt = 0, f_snt2 = 0;
  int f_alw = 0, f_alw2 = 0, f_salw = 0;
  int f_ev = 0, f_sev2 = 0, f_sev = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_nt: assert property (@(posedge clk) start |-> nexttime p) else f_nt++;
  a_nt2: assert property (@(posedge clk) start |-> nexttime [2] p) else f_nt2++;
  a_snt: assert property (@(posedge clk) start |-> s_nexttime p) else f_snt++;
  a_snt2: assert property (@(posedge clk) start |-> s_nexttime [2] p) else f_snt2++;
  a_alw: assert property (@(posedge clk) start |-> always p) else f_alw++;
  a_alw2: assert property (@(posedge clk) start |-> always [1:2] p) else f_alw2++;
  a_salw: assert property (@(posedge clk) start |-> s_always [1:2] p) else f_salw++;
  a_ev: assert property (@(posedge clk) start |-> eventually [1:2] p) else f_ev++;
  a_sev2: assert property (@(posedge clk) start |-> s_eventually [1:2] p) else f_sev2++;
  a_sev: assert property (@(posedge clk) start |-> s_eventually p) else f_sev++;

  // Runs one phase of eight ticks with the p bits given from the start.
  task automatic phase(logic [7:0] ps);
    for (int i = 0; i < 8; i++) begin
      start = (i == 0);
      p = ps[7 - i];
      #10;
    end
    $display("p %b: nexttime %0d, nexttime[2] %0d, s_nexttime %0d, s_nexttime[2] %0d",
             ps, f_nt, f_nt2, f_snt, f_snt2);
    $display("  always %0d, always[1:2] %0d, s_always %0d", f_alw, f_alw2, f_salw);
    $display("  eventually %0d, s_eventually %0d, s_eventually[1:2] %0d", f_ev, f_sev,
             f_sev2);
    f_nt = 0;
    f_nt2 = 0;
    f_snt = 0;
    f_snt2 = 0;
    f_alw = 0;
    f_alw2 = 0;
    f_salw = 0;
    f_ev = 0;
    f_sev2 = 0;
    f_sev = 0;
  endtask

  initial begin
    phase(8'b11110000);
    phase(8'b00110000);
    phase(8'b00010000);
    phase(8'b00000001);
    $finish;
  end
endmodule
