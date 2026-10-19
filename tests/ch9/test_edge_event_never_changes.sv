/*
:name: test_edge_event_never_changes
:description: @(edge v) resumes only on the transitions of Table 9-2, never for a variable that keeps its initial x (IEEE 1800-2023 Section 9.4.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_edge_event_never_changes.expected
*/
// IEEE 1800-2023 §9.4.2: the edge event control waits for a posedge or a
// negedge as Table 9-2 lists them. A variable that keeps its initial x never
// makes a transition, so @(edge quiet) never resumes, not even at time 0. A
// variable that goes from x to 1 makes a posedge, and from 1 to z a negedge;
// assigning z again is no change.

module test_edge_event_never_changes;
  logic quiet, busy;
  int quiet_edges = 0, busy_edges = 0;

  always @(edge quiet) quiet_edges++;
  always @(edge busy) busy_edges++;

  initial begin
    #5 busy = 1'b1;
    #5 busy = 1'bz;
    #5 busy = 1'bz;
    #5 $display("quiet: %0d edges, busy: %0d edges", quiet_edges, busy_edges);
  end
endmodule
