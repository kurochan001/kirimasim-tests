/*
:name: test_udp_set_reset_edges
:description: A sequential UDP table with edge-sensitive entries on two different inputs sets the output on a rising set input and clears it on a rising reset input (IEEE 1800-2023 Section 29.6)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_udp_set_reset_edges.expected
*/
// IEEE 1800-2023 §29.6: an entry of a sequential UDP can have a transition on
// one input and values on the others, so r 0 : ? : 1 sets the output when s
// rises while r is low, and 0 r : ? : 0 clears it when r rises while s is low.
// A falling input holds the output. The output starts at x and the table lists
// no entry for the first changes of s and r, from x to 0, so it stays x until
// the rising s sets it; the test prints from that point on.

primitive udp_sr_edge (q, s, r);
  output q;
  reg q;
  input s, r;
  table
  // s r : q : q+
    f ? : ? : -;
    ? f : ? : -;
    r 0 : ? : 1;
    0 r : ? : 0;
  endtable
endprimitive

module test_udp_set_reset_edges;
  reg s, r;
  wire q;

  udp_sr_edge u (q, s, r);

  initial begin
    s = 0;
    r = 0;
    #1 s = 1;
    #1 $display("s=%b r=%b: q=%b", s, r, q);
    s = 0;
    #1 $display("s=%b r=%b: q=%b", s, r, q);
    r = 1;
    #1 $display("s=%b r=%b: q=%b", s, r, q);
    r = 0;
    #1 $display("s=%b r=%b: q=%b", s, r, q);
    s = 1;
    #1 $display("s=%b r=%b: q=%b", s, r, q);
  end
endmodule
