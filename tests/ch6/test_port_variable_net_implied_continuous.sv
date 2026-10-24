/*
:name: test_port_variable_net_implied_continuous
:description: A variable on one side of a port and a net on the other are joined by an implied continuous assignment, which drives the net with strong strength and follows every change, and a variable can be written by one continuous assignment or by one output port (IEEE 1800-2023 Section 6.5)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.5 23.3.3 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_port_variable_net_implied_continuous.expected
*/
// IEEE 1800-2023 §6.5: when a variable on one side of a port drives a net on
// the other, a continuous assignment from the variable to the net is implied
// (23.3.3). That assignment is a driver of the net like any other: it drives
// with the default strong strength, so it overrides a weak driver of the same
// net, and the net follows each later change of the variable. A variable
// itself can be written by one continuous assignment, or by one output port
// of an instance.
// The output variable o of src drives the parent wire n, which also has a weak
// driver of 0; the parent variable v drives the input net i of sink, which
// passes it on to e; the parent variable vo is connected to another src
// output and vc has a single continuous assignment. %v (21.2.1.4) shows the
// strength on n.

module test_port_variable_net_implied_continuous_src(output logic o);
  initial begin
    o = 1'b1;
    #2 o = 1'b0;
    #2 o = 1'b1;
  end
endmodule

module test_port_variable_net_implied_continuous_sink(input wire [3:0] i, output wire [3:0] echo);
  assign echo = i;
endmodule

module test_port_variable_net_implied_continuous;
  wire n;
  logic [3:0] v = 4'h5;
  wire [3:0] e;
  logic vo;
  logic [3:0] vc;

  assign (weak0, weak1) n = 1'b0;
  assign vc = v + 4'd1;

  test_port_variable_net_implied_continuous_src s1(.o(n));
  test_port_variable_net_implied_continuous_src s2(.o(vo));
  test_port_variable_net_implied_continuous_sink k(.i(v), .echo(e));

  initial begin
    #1 $display("t1: n=%v e=%h vo=%b vc=%h", n, e, vo, vc);
    v = 4'ha;
    #2 $display("t3: n=%v e=%h vo=%b vc=%h", n, e, vo, vc);
    v = 4'h3;
    #2 $display("t5: n=%v e=%h vo=%b vc=%h", n, e, vo, vc);
  end
endmodule
