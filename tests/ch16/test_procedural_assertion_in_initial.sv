/*
:name: test_procedural_assertion_in_initial
:description: A concurrent assertion in an initial procedure starts one attempt each time it is reached, while a static one starts an attempt at every clock tick (IEEE 1800-2023 Section 16.14.6)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.6 16.14.5 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_procedural_assertion_in_initial.expected
*/
// IEEE 1800-2023 §16.14.6: a concurrent assertion reached in procedural code
// is queued and matures in the Observed region; if its clocking event
// occurred in that time step, its evaluation attempt starts at once. An
// initial procedure that reaches a_once at the third clock edge, at 25,
// gets exactly one attempt, which passes at 25. Reaching a_loop three times
// in that time step queues three instances, so it passes three times at 25.
// §16.14.5: a_static, outside procedural code, starts an attempt at every
// edge: 6 by 57.

module test_procedural_assertion_in_initial;
  logic clk = 0;
  int n_once = 0, n_loop = 0, n_static = 0;
  int once_at = -1;

  always #5 clk = ~clk;

  a_static: assert property (@(posedge clk) 1) n_static++;

  initial begin
    repeat (3) @(posedge clk);
    a_once: assert property (@(posedge clk) 1) begin
      n_once++;
      once_at = $time;
    end
    for (int i = 0; i < 3; i++) begin
      a_loop: assert property (@(posedge clk) 1) n_loop++;
    end
    #32;
    $display("a_once: %0d pass at %0d, a_loop: %0d passes, a_static: %0d passes", n_once,
             once_at, n_loop, n_static);
    $finish;
  end
endmodule
