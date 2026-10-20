/*
:name: test_assertion_clocked_by_named_event
:description: Concurrent assertions clocked by a named event, explicitly or through always @(e), are evaluated at every trigger of the event (IEEE 1800-2023 Section 16.14.1)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.1 16.5 16.14.6 16.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assertion_clocked_by_named_event.expected
*/
// IEEE 1800-2023 §16.5: the clocking event of a concurrent assertion can be
// any event expression, a named event too. assert property (@(e) ...)
// (16.14.1) starts an attempt at each trigger of e; in an always @(e)
// procedure the assertion takes @(e) as its clock (16.14.6, 16.16). e is
// triggered at 1, 3, ..., 19, so by 20 a property that always holds has
// passed 10 times and a property that never holds has failed 10 times, as
// with the clock @(posedge clk) itself.

module test_assertion_clocked_by_named_event;
  logic clk = 0;
  event e;
  logic x = 0;
  int pass_e = 0, fail_e = 0, fail_proc = 0, pass_clk = 0, fail_clk = 0;

  initial forever #1 clk = ~clk;
  always @(posedge clk) -> e;

  assert property (@(e) 1) pass_e++;
  assert property (@(e) x) else fail_e++;
  always @(e) assert property (x) else fail_proc++;
  assert property (@(posedge clk) 1) pass_clk++;
  assert property (@(posedge clk) x) else fail_clk++;

  initial begin
    #20;
    $display("@(e): %0d passes, %0d failures", pass_e, fail_e);
    $display("always @(e): %0d failures", fail_proc);
    $display("@(posedge clk): %0d passes, %0d failures", pass_clk, fail_clk);
    $finish;
  end
endmodule
