/*
:name: test_local_variable_init_two_leading_clocks
:description: a local variable with an initialization assignment in a property with two semantic leading clocks gets one copy per leading clock, each initialized at the first tick of its clock at or after the start of the evaluation attempt, which can be the start itself (IEEE 1800-2023 Section 16.13.7)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.13.7 16.16.1 16.10 16.11 16.13.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_local_variable_init_two_leading_clocks.expected
*/
// IEEE 1800-2023 §16.13.7: when a named property has two semantic leading
// clocks (§16.16.1), as an and of two operands on different clocks does, a
// separate copy of each local variable is made for each of them, and each copy
// is initialized at the earliest tick of its own clock at or after the start of
// the evaluation attempt, with sampled values (§16.10). In @(posedge clk) trig
// |-> snapshot, the attempt of snapshot starts at the tick with trig, and a
// tick of another clock in that time step counts (§16.13.2). On ca, snapshot
// waits one more ca tick before it passes snap to note (§16.11), so the copy is
// used later than it is initialized; on cb, note is called at once. stamp grows
// by 3 every time unit, so its sampled value at time t is 3 * (t - 1). clk
// rises at 5, 15, ...; trig is high at 15; ca rises at 9, 15, 24 and 40, cb at
// 12, 27 and 50. The ca copy is initialized at 15, together with the start, and
// used at 24; the cb copy is initialized and used at 27.

`timescale 1ns/1ns

module test_local_variable_init_two_leading_clocks;
  logic clk = 0, ca = 0, cb = 0, trig = 0;
  int stamp = 0, fails = 0;
  string got[$];

  always #5 clk = ~clk;   // rising edges at 5, 15, 25, ...

  always #1 stamp = stamp + 3;

  function automatic void note(string which, int value);
    got.push_back($sformatf("copy for %s: snap=%0d at %0d", which, value, $time));
  endfunction

  property snapshot;
    int snap = stamp + 1000;
    (@(posedge ca) 1'b1 ##1 (1'b1, note("ca", snap))) and (@(posedge cb) (1'b1, note("cb", snap)));
  endproperty

  a_snap: assert property (@(posedge clk) trig |-> snapshot) else fails++;

  initial begin
    #14 trig = 1;
    #2 trig = 0;
  end

  initial begin
    #9 ca = 1; #1 ca = 0;
    #2 cb = 1; #1 cb = 0;
    #2 ca = 1; #1 ca = 0;
    #8 ca = 1; #1 ca = 0;
    #2 cb = 1; #1 cb = 0;
    #12 ca = 1; #1 ca = 0;
    #9 cb = 1; #1 cb = 0;
  end

  initial begin
    #60;
    foreach (got[i]) $display("%s", got[i]);
    $display("failures: %0d", fails);
    $finish;
  end
endmodule
