/*
:name: test_ch16_edge_instance_flow
:description: the scope of a clocking event flows into and left to right across an instance of a named sequence or property, so an unclocked named sequence used between two ##1 delays and an unclocked named property match on the ticks of the enclosing clock (IEEE 1800-2023 Section 16.13.3)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.13.3 16.16.1 16.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ch16_edge_instance_flow.expected
*/
// IEEE 1800-2023 §16.13.3: "the scope of a clocking event flows into an
// instance of a named property or sequence ... The scope of a clocking event
// flows left to right across an instance of a property or sequence." Neither
// `middle` nor `prop_middle` below has a clocking event of its own, so the
// only clock they can be evaluated on is the one written on the assertion.
// The clock ticks five times, at 5, 15, ..., 45. A tick is labelled T = 0..4
// and starts one evaluation attempt of each assertion.
//
//   T      0  1  2  3  4
//   start  1  0  0  0  0
//   b      0  1  0  0  0
//   c      0  0  1  0  0
//   d      0  0  0  1  0
//
// a_seq is `start ##1 around` with around = `middle ##1 d` and middle =
// `b ##1 c`, so its attempt at T matches when start is at T, b at T+1, c at
// T+2 and d at T+3. Only the attempt at T = 0 matches, at 35; the attempts at
// T = 1..4 fail because start is low. The ##1 written after the instance is
// measured on the outer clock: if the instance closed the clock scope, that
// delay would have no clock at all, and `middle`, which has no clock, could
// not be evaluated anywhere.
//
// a_swap is the control: the same three signals in the order b, d, c never
// match on this trace, so the counts above are not the result of ignoring the
// delays or the instance boundary.
//
// a_prop instances the unclocked property prop_middle, whose body is
// `b ##1 c`, directly under the outer clock, so its attempt at T matches when
// b is at T and c at T+1: the attempt at T = 1 matches at 25, one tick before
// a_seq, which is the one extra ##1 d that a_seq adds.
//
// Both action branches only update counters, so the output is three lines
// printed at the end and no line depends on the order in which a tool runs
// the action blocks of one time step. Verilator 5.052 runs an action block
// only when both the pass and the else action are present, hence the
// otherwise uninformative failure counter.
//
// Not observed here: a clocking event declared inside an instance does not
// flow out, and an instance to which triggered or matched is applied. Both
// need a second clocking event inside the property; Verilator 5.052 rejects
// it ("Unsupported: clocking event inside sequence expression"), and Icarus
// Verilog 13.0 rejects concurrent assertions altogether ("sorry:
// concurrent_assertion_item not supported").

`timescale 1ns/1ns

module test_ch16_edge_instance_flow;
  logic clk = 0, start = 0, b = 0, c = 0, d = 0;
  int seq_pass = 0, seq_fail = 0, seq_first = -1;
  int swap_pass = 0, swap_fail = 0;
  int prop_pass = 0, prop_fail = 0, prop_first = -1;

  sequence middle;
    b ##1 c;
  endsequence

  property prop_middle;
    b ##1 c;
  endproperty

  sequence around;
    middle ##1 d;
  endsequence

  sequence swapped;
    b ##1 d ##1 c;
  endsequence

  a_seq: assert property (@(posedge clk) start ##1 around)
    begin
      seq_pass++;
      if (seq_first < 0) seq_first = $time;
    end
    else seq_fail++;

  a_swap: assert property (@(posedge clk) start ##1 swapped)
    swap_pass++;
    else swap_fail++;

  a_prop: assert property (@(posedge clk) prop_middle)
    begin
      prop_pass++;
      if (prop_first < 0) prop_first = $time;
    end
    else prop_fail++;

  initial forever #5 clk = ~clk;

  initial begin
    #2 start = 1;              // T = 0
    #10 start = 0; b = 1;      // T = 1
    #10 b = 0; c = 1;          // T = 2
    #10 c = 0; d = 1;          // T = 3
    #10 d = 0;                 // T = 4
    #10;
    $display("sequence instance: %0d pass, %0d fail, first at %0d",
             seq_pass, seq_fail, seq_first);
    $display("wrong order: %0d pass, %0d fail", swap_pass, swap_fail);
    $display("property instance: %0d pass, %0d fail, first at %0d",
             prop_pass, prop_fail, prop_first);
    $finish;
  end
endmodule
