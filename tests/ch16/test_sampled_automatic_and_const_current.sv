/*
:name: test_sampled_automatic_and_const_current
:description: the sampled and past values of an automatic variable are its current value, a const cast samples the current value of its argument even in a past reference, and $changed compares the sampled values of the two clock ticks, so a change in the same time step as a tick is not seen there (IEEE 1800-2023 Sections 16.5.1 and 16.5.2)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.5.1 16.5.2 16.14.6.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sampled_automatic_and_const_current.expected
*/
// IEEE 1800-2023 §16.5.1: the sampled values of automatic variables are their
// current values, and when a past or future value of an automatic variable is
// referenced by a sampled value function the current value is taken instead.
// The sampled value of const'(a) is the current value of a, also for a past
// reference. §16.5.2: assertion expressions are tied to their clock, and a
// value change is a change of the sampled values, so the change of the static
// variable a in the same time step as the tick at 15 is seen by $changed only
// at the tick at 25. The procedural concurrent assertion in the automatic task
// watch reads its automatic variable av, which the same task sets to 1 at 15
// and 2 at 25 in the Active region; at the tick at 15 the Preponed value of a
// is still 0 while its current value is 1.

`timescale 1ns/1ns

module test_sampled_automatic_and_const_current;
  logic clk = 0;
  int a = 0;

  always #5 clk = ~clk;   // rising edges at 5, 15, 25, ...

  task automatic watch();
    int av = 0;

    a_cur: assert property (@(posedge clk) 1'b1) begin
      $display("t=%0t av=%0d sampled_av=%0d past_av=%0d changed_a=%0d",
               $time, av, $sampled(av), $past(av), $changed(a));
      $display("     a=%0d sampled_a=%0d const_a=%0d past_const_a=%0d",
               a, $sampled(a), const'(a), $past(const'(a)));
    end

    #15 av = 1;   // in the time step of the tick at 15
    #10 av = 2;   // in the time step of the tick at 25
    #15;
  endtask

  initial begin
    fork
      watch();
      begin
        #15 a = 1;   // in the time step of the tick at 15
        #20;
      end
    join
    $finish;
  end
endmodule
