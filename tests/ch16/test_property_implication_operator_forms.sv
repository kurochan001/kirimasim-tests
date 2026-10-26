/*
:name: test_property_implication_operator_forms
:description: The overlapping and nonoverlapping implication and followed-by operators start their consequent at the end of the antecedent match or at the tick after it, as per-phase failure counts show (IEEE 1800-2023 Sections 16.12.7 and 16.12.9)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.7 16.12.9 16.14.1 16.14.5 A.2.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_implication_operator_forms.expected
*/
// IEEE 1800-2023 16.12.7: |-> starts its consequent at the antecedent's
// end tick; |=> starts it at the next tick for this nonempty antecedent.
// go ##1 a starts at the first tick of a phase and ends at its second tick,
// so the overlapping forms need x at the second tick and the nonoverlapping
// forms at the third. Section 16.12.9 gives #-# and #=# those same alignments
// but also requires an antecedent match for success.
//
// Each five-tick phase has go high only at its first tick. Each module-level
// assertion starts an attempt at every tick (16.14.5). At the four other
// starts, go ##1 a cannot match: the implications pass vacuously, while both
// followed-by forms fail. Their phase failure counts therefore include four
// failures in addition to any failure of the attempt started with go high.
// Fail actions increment the phase counters (16.14.1).

`timescale 1ns/1ns

module test_property_implication_operator_forms;
  logic clk = 0, go = 0, a = 0, x = 0;
  int f_ov = 0, f_nov = 0, f_fb = 0, f_fbn = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_ov: assert property (@(posedge clk) (go ##1 a) |-> x) else f_ov++;
  a_nov: assert property (@(posedge clk) (go ##1 a) |=> x) else f_nov++;
  a_fb: assert property (@(posedge clk) (go ##1 a) #-# x) else f_fb++;
  a_fbn: assert property (@(posedge clk) (go ##1 a) #=# x) else f_fbn++;

  // Runs one phase of five ticks; x is high at tick x_at, or never for 0.
  task automatic phase(int x_at);
    for (int i = 0; i < 5; i++) begin
      go = (i == 0);
      a = (i == 1);
      x = (x_at != 0) && (i == x_at);
      #10;
    end
    $display("x at tick %0d: |-> %0d, |=> %0d, #-# %0d, #=# %0d", x_at, f_ov, f_nov,
             f_fb, f_fbn);
    f_ov = 0;
    f_nov = 0;
    f_fb = 0;
    f_fbn = 0;
  endtask

  initial begin
    phase(1);
    phase(2);
    phase(0);
    $finish;
  end
endmodule
