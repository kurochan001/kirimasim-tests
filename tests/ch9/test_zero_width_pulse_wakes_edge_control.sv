/*
:name: test_zero_width_pulse_wakes_edge_control
:description: A variable that goes from 0 to 1 and back within one time step wakes both a posedge and a negedge event control (IEEE 1800-2023 Section 9.4.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2 4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_zero_width_pulse_wakes_edge_control.expected
*/
// IEEE 1800-2023 §9.4.2: an edge event control is triggered by the update of
// the variable (4.3), not by a comparison of its value at the start and at
// the end of the time step. So "clk = 1; clk = 0;" in one process makes a
// posedge and then a negedge: a process waiting for @(posedge clk) and one
// waiting for @(negedge clk) both resume, although clk ends the time step
// with the value it had before.

module test_zero_width_pulse_wakes_edge_control;
  reg clk = 0;
  int pos = 0, neg = 0;

  always @(posedge clk) pos++;
  always @(negedge clk) neg++;

  initial begin
    #1;
    clk = 1;
    clk = 0;
    #1 $display("clk=%b posedges seen: %0d, negedges seen: %0d", clk, pos, neg);
  end
endmodule
