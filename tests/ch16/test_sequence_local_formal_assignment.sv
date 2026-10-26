/*
:name: test_sequence_local_formal_assignment
:description: A variable actual of a typed local formal is viewed through the formal's type, so its wider value is truncated, and an assignment to the formal is followed by an assignment from the formal to the actual (IEEE 1800-2023 Section 16.8.1)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.8.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_local_formal_assignment.expected
*/
// IEEE 1800-2023 §16.8.1: when the actual argument is a variable_lvalue,
// references to the typed formal have the formal's type, and an assignment to
// the formal is treated as though a subsequent assignment from the formal to
// the actual followed. s_add declares the local inout formal f of type
// logic [1:0]; its actual is the 8-bit variable w. At the attempt that starts
// at 5, f starts as the low two bits of w, which is 01, and f = f + 2'b11
// wraps to 00 in the two-bit type. The comparison at 15 passes, and the end
// of the match assigns f, cast to eight bits, to w, so w becomes 0. The
// attempt from 15 is vacuous because start is low; it adds one pass at 15.
// The test prints w and the counts at 18, before the tick at 25. A tool that
// views w as eight bits would not wrap f to 00 and the comparison would fail;
// a tool that does not copy the formal back leaves w at 5.

`timescale 1ns/1ns

module test_sequence_local_formal_assignment;
  logic clk = 0, start = 0;
  logic [7:0] w = 8'h05;
  int passes = 0, failures = 0;

  always #5 clk = ~clk;   // rising edges at 5, 15 and 25

  sequence s_add(local inout logic [1:0] f);
    (1'b1, f = f + 2'b11) ##1 (f == 2'b00);
  endsequence

  a_add: assert property (@(posedge clk) start |-> s_add(w))
    passes++; else failures++;

  initial begin
    #4 start = 1;
    #12 start = 0;
  end

  initial begin
    #18;
    $display("w=%0d, passes=%0d, failures=%0d", w, passes, failures);
    $finish;
  end
endmodule
