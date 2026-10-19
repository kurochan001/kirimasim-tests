/*
:name: test_sched_contassign_zero_delay
:description: A continuous assignment is evaluated at time zero and updated in the Active region, before a process waiting on #0 resumes (IEEE 1800-2023 Section 4.9.1)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.9.1 4.4.2.2 4.4.2.3 10.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_contassign_zero_delay.expected
*/
// IEEE 1800-2023 §4.9.1: a continuous assignment is a process sensitive to the
// operands of its expression. It is evaluated at time zero, which also gives a
// constant right-hand side its value, and a change of an operand adds an update
// event to the Active region. A process that writes an operand and then waits
// with #0 is moved to the Inactive region (4.4.2.3), which runs only when the
// Active region is empty (4.4.2.2), so after #0 it sees the new value of the
// net, also through a chain of two continuous assignments. Verilator 5.052
// still prints the old values after the second #0.

module test_sched_contassign_zero_delay;
  logic [7:0] a = 8'd3;
  wire  [7:0] k;
  wire  [7:0] w;
  wire  [7:0] w2;
  assign k = 8'd42;
  assign w = a + 8'd1;
  assign w2 = w * 8'd2;

  initial begin
    #1;
    $display("t1 k=%0d w=%0d w2=%0d", k, w, w2);
    a = 8'd10;
    #0;
    $display("after #0 w=%0d w2=%0d", w, w2);
    a = 8'd20;
    #0;
    $display("after #0 w=%0d w2=%0d", w, w2);
  end
endmodule
