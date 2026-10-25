/*
:name: test_edge_event_vector_lsb_only
:description: posedge, negedge and edge on a 4-bit vector follow only its least significant bit, while a plain event control wakes on any change (IEEE 1800-2023 Section 9.4.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_edge_event_vector_lsb_only.expected
*/
// IEEE 1800-2023 §9.4.2: an event control without an edge keyword wakes on
// any change of the value of its expression, but an edge event (posedge,
// negedge, edge) is detected only on the least significant bit of the
// expression.
//
// The vector v changes three times, one time unit apart:
//   0000 -> 1110  only the upper bits rise; bit 0 stays 0: no edge at all
//   1110 -> 0001  the value falls, but bit 0 goes 0 -> 1: a posedge
//   0001 -> 1110  the value rises, but bit 0 goes 1 -> 0: a negedge
// An implementation that looked at the whole value, or at any bit, would
// report edges for the first change, or the wrong direction for the others.
// The plain @(v) wakes for all three changes.

module test_edge_event_vector_lsb_only;
  logic [3:0] v = 4'b0000;
  int pos = 0, neg = 0, any = 0, chg = 0;

  always @(posedge v) pos++;
  always @(negedge v) neg++;
  always @(edge v) any++;
  always @(v) chg++;

  task automatic step(logic [3:0] nv);
    int p0 = pos, n0 = neg, a0 = any, c0 = chg;
    logic [3:0] ov = v;
    v = nv;
    #1 $display("%b->%b posedge=%0d negedge=%0d edge=%0d change=%0d",
                ov, v, pos - p0, neg - n0, any - a0, chg - c0);
  endtask

  initial begin
    #1;
    step(4'b1110);
    step(4'b0001);
    step(4'b1110);
  end
endmodule
