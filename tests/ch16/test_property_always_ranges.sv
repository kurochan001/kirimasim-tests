/*
:name: test_property_always_ranges
:description: always [m:n] p and s_always [m:n] p need p at every tick from the m-th to the n-th after the start, and always [m:$] p at every tick from the m-th on, however late p fails (IEEE 1800-2023 Section 16.12.11)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.11 16.12.15 16.12.7 16.14.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_always_ranges.expected
*/
// IEEE 1800-2023 §16.12.11: always [m:n] p is true if p holds at every tick
// from the m-th to the n-th after the start, and s_always [m:n] p also needs
// those ticks to exist (§16.12.15); every phase lasts long enough for them,
// so the two agree. always [m:$] p needs p at every tick from the m-th on.
// The ranged assertions start at the first tick T of each phase, with go,
// and the unbounded one only in the last phase, with go2 (§16.12.7); y drops
// there at T+6. The fail actions count the failures of each phase
// (§16.14.1). A phase has the ticks T to T+7; each line shows x and y at them.

`timescale 1ns/1ns

module test_property_always_ranges;
  logic clk = 0, go = 0, go2 = 0, x = 0, y = 0;
  int f_always = 0, f_s_always = 0, f_unbounded = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_always: assert property (@(posedge clk) go |-> always [1:3] x) else f_always++;
  a_s_always: assert property (@(posedge clk) go |-> s_always [1:3] x) else f_s_always++;
  a_unbounded: assert property (@(posedge clk) go2 |-> always [2:$] y) else f_unbounded++;

  // Runs one phase of 8 ticks; go, and go2 if last is set, are high at the first.
  task automatic phase(logic [7:0] xs, logic [7:0] ys, bit last);
    for (int i = 0; i < 8; i++) begin
      go = (i == 0);
      go2 = last && i == 0;
      x = xs[7 - i];
      y = ys[7 - i];
      #10;
    end
    $display("x %b, y %b: always %0d, s_always %0d, always [2:$] %0d", xs, ys, f_always,
             f_s_always, f_unbounded);
    f_always = 0;
    f_s_always = 0;
    f_unbounded = 0;
  endtask

  initial begin
    phase(8'b0111_0000, 8'b0000_0000, 0);
    phase(8'b0110_0000, 8'b0000_0000, 0);
    phase(8'b0011_1000, 8'b0011_1101, 1);
    $finish;
  end
endmodule
