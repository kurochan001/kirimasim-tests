/*
:name: test_preponed_sampling
:description: A concurrent assertion uses the values of the Preponed region, from before any change in its time step, also for a variable that changes just before the clock edge in the same time step (IEEE 1800-2023 Section 4.4.2.1)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.1 16.5.1 16.9.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_preponed_sampling.expected
*/
// IEEE 1800-2023 §4.4.2.1, §16.5.1: the values that concurrent assertions use
// are sampled in the Preponed region, before the time step's first event.
// At 10 a becomes 1 and then clk rises in the same procedure, so the
// assertion at that edge sees a = 0 and fails; its action shows $sampled(a)
// = 0 while a is already 1 (16.9.3). At 20 a has been 1 since 10, and the
// assertion passes. Each action runs at a different time step.

module test_preponed_sampling;
  logic clk = 0, a = 0;

  a_check: assert property (@(posedge clk) a)
    $display("t=%0d: pass, $sampled(a)=%b a=%b", $time, $sampled(a), a);
    else $display("t=%0d: fail, $sampled(a)=%b a=%b", $time, $sampled(a), a);

  initial begin
    #10;
    a = 1;
    clk = 1;
    #5 clk = 0;
    #5 clk = 1;
    #5 $finish;
  end
endmodule
