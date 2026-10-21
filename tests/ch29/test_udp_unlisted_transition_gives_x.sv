/*
:name: test_udp_unlisted_transition_gives_x
:description: In an edge-sensitive sequential UDP, an input transition that no table entry lists sets the output to x (IEEE 1800-2023 Section 29.6)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.6 29.3.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_unlisted_transition_gives_x.expected
*/
// IEEE 1800-2023 §29.6: in an edge-sensitive UDP every transition that leaves
// the output unchanged has to be listed with "-"; a transition that no entry
// lists sets the output to x. The flip-flop below lists the rising edge of the
// clock and its falling edge, but no change of the data while the clock is
// steady, so such a change makes q x until the next rising edge.

primitive test_udp_unlisted_transition_gives_x_ff(q, clk, d);
  output q;
  reg q;
  input clk, d;
  table
    (01) 0 : ? : 0;
    (01) 1 : ? : 1;
    (10) ? : ? : -;
  endtable
endprimitive

module test_udp_unlisted_transition_gives_x;
  logic clk, d;
  wire q;

  test_udp_unlisted_transition_gives_x_ff u(q, clk, d);

  initial begin
    clk = 0;
    d = 1;
    #1 clk = 1;
    #1 $display("after rising edge: q=%b", q);
    clk = 0;
    #1 $display("after falling edge: q=%b", q);
    d = 0;
    #1 $display("after data change: q=%b", q);
    clk = 1;
    #1 $display("after next rising edge: q=%b", q);
  end
endmodule
