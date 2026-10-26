/*
:name: test_a6_5_procedural_timing_control_statement
:description: A procedural statement that starts with a cycle delay waits for that many clocking events of the default clocking block, so the three statements run at the first, third and fourth posedge (IEEE 1800-2023 Sections 9.4.5 and 14.11, A.6.5)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.5 14.11 A.6.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_a6_5_procedural_timing_control_statement.expected
*/
// IEEE 1800-2023 A.6.5: a procedural timing-control statement is a delay
// control, an event control or a cycle delay control followed by a statement.
// §9.4.5: in procedural code a cycle delay ##n waits for n events of the
// default clocking block.
//
// clk rises at 5, 15, 25 and 35, and cb is the default clocking block on its
// posedge. In the first procedure the first statement waits for one clocking
// event, the posedge at 5; the second waits for two more, at 15 and 25, so it
// runs at 25; the third waits for one more, at 35, and runs there. The second
// procedure shows the delay control with 2 and the event control, which waits
// for the negedge at 10.

`timescale 1ns/1ns
module test_a6_5_procedural_timing_control_statement;
  bit clk = 0;
  always #5 clk = ~clk;
  default clocking cb @(posedge clk); endclocking

  initial begin
    ##1 $display("first %0t", $time);
    ##2 $display("second %0t", $time);
    ##1 $display("third %0t", $time);
  end

  initial begin
    #2 $display("delay %0t", $time);
    @(negedge clk) $display("event %0t", $time);
  end

  initial #40 $finish;
endmodule
