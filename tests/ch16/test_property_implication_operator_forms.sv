/*
:name: test_property_implication_operator_forms
:description: The overlapping and nonoverlapping implication and followed-by operators start their consequent at the end of the antecedent match or at the tick after it, as per-phase failure counts show (IEEE 1800-2023 Sections 16.12.7 and 16.12.9)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.7 16.12.9 16.14.1 A.2.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_implication_operator_forms.expected
*/
// IEEE 1800-2023 §16.12.7: with the overlapping implication |->, the
// consequent starts at the end point of the antecedent match; with the
// nonoverlapping |=>, at the clock tick after it. §16.12.9: the followed-by
// operators #-# and #=# are the duals, with the same start points as |-> and
// |=>. Here the antecedent go ##1 a matches two ticks after go, so the
// overlapping forms need x at that second tick and the nonoverlapping forms
// at the third.
//
// A phase is five ticks long; go is high at the first and a at the second.
// In the first phase x is high at the second tick, in the second at the third,
// and in the third never. The fail actions count the failures of each phase
// (§16.14.1).

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
