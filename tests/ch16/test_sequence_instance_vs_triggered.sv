/*
:name: test_sequence_instance_vs_triggered
:description: A named sequence used as an instance has to start matching where it is reached, while its triggered method only asks whether a match ends there; an empty match does not set triggered (IEEE 1800-2023 Section 16.9.11)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.11 16.13.6 16.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_instance_vs_triggered.expected
*/
// IEEE 1800-2023 §16.9.11: an instance of a named sequence inside another
// sequence has to match starting at the tick where it is reached, while
// .triggered tests whether a match of it ends at that tick. In r ##1 pq, pq
// has to start one tick after r; in r ##1 pq.triggered, it has to end there.
// r is 1 at ticks 1 and 5, p at ticks 2 and 5, q at ticks 3 and 6, so the
// instance matches from tick 1 to 3 and .triggered at tick 6. An empty match
// does not set triggered: maybe_s, s repeated zero or one times, has an empty
// match at every tick but triggered is true only at tick 8, where s is 1.
// The ticks are the rising edges of clk at 5, 15, 25 and so on.

`timescale 1ns/1ns

module test_sequence_instance_vs_triggered;
  logic clk = 0, r = 0, p = 0, q = 0, s = 0;
  string inst = "", trig = "", maybe = "";

  always #5 clk = ~clk;

  sequence pq;
    @(posedge clk) p ##1 q;
  endsequence

  sequence maybe_s;
    @(posedge clk) s[*0:1];
  endsequence

  initial begin
    r = 1;
    #10 r = 0; p = 1;
    #10 p = 0; q = 1;
    #10 q = 0;
    #10 r = 1; p = 1;
    #10 r = 0; p = 0; q = 1;
    #10 q = 0;
    #10 s = 1;
    #10 s = 0;
    #20;
    $display("instance:%s", inst);
    $display("triggered:%s", trig);
    $display("empty matches do not trigger:%s", maybe);
    $finish;
  end

  c_inst: cover sequence (@(posedge clk) r ##1 pq) inst = {inst, $sformatf(" %0t", $time)};
  c_trig: cover sequence (@(posedge clk) r ##1 pq.triggered)
    trig = {trig, $sformatf(" %0t", $time)};
  c_maybe: cover property (@(posedge clk) maybe_s.triggered)
    maybe = {maybe, $sformatf(" %0t", $time)};
endmodule
