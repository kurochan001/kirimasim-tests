/*
:name: test_port_collapse_net_delay
:description: The net that a port connection between different net types becomes has the delay of the net whose type Table 23-1 selects, for a driver on either side of the port (IEEE 1800-2023 Section 23.3.3.7)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7 28.16 6.6.1 6.6.3 6.6.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_port_collapse_net_delay.expected
*/
// IEEE 1800-2023 §23.3.3.7: when a port connects nets of different net
// types, the merged (simulated) net takes the type of the dominating net,
// the one that Table 23-1 selects, and the delay declared for that net;
// the delay of the other net is not used, and the two are not added. A net
// delay is the time from a change of any driver of the net to the change
// of the net (§28.16). Each inner module declares its port net with a
// delay in the module body (non-ANSI style), and each outer net has another
// delay. Table 23-1 selects:
//   wand #3 inside, wire #7 outside: the internal wand, delay 3;
//   wire #3 inside, wand #7 outside: the external wand, delay 7;
//   tri0 #3 inside, wire #7 outside: the internal tri0, delay 3;
//   wire #3 inside, tri1 #7 outside: the external tri1, delay 7;
//   wire #3 inside, wire #7 outside: the external wire, delay 7;
//   wand #7 inside, wire #3 outside: the internal wand, delay 7.
// Every cell has two instances: one driven by a continuous assignment
// inside the module, the other by one outside. The driver goes to 1 at
// time 10 and to 0 at time 30; the net is sampled at 12, 15 and 19 and at
// 32, 35 and 39. With delay 3 this gives 011100, with delay 7 001110; the
// sum of both delays (10) would give 000111 and no delay 111000.
// Icarus Verilog 13.0 does not support net delays, and Verilator 5.052
// rejects these inout connections as an unsupported tristate construct, so
// this expected output follows the standard alone.

module port_collapse_net_delay_in_wand(w, d);
  parameter int D = 3;
  parameter bit DRIVE = 1'b1;
  inout w;
  input d;
  wand #(D) w;
  if (DRIVE) begin : g
    assign w = d;
  end
endmodule

module port_collapse_net_delay_in_wire(w, d);
  parameter int D = 3;
  parameter bit DRIVE = 1'b1;
  inout w;
  input d;
  wire #(D) w;
  if (DRIVE) begin : g
    assign w = d;
  end
endmodule

module port_collapse_net_delay_in_tri0(w, d);
  parameter int D = 3;
  parameter bit DRIVE = 1'b1;
  inout w;
  input d;
  tri0 #(D) w;
  if (DRIVE) begin : g
    assign w = d;
  end
endmodule

module test_port_collapse_net_delay;
  logic d;

  // Suffix i: driven inside the port; suffix o: driven outside it.
  wire #7 n1i, n1o;
  wand #7 n2i, n2o;
  wire #7 n3i, n3o;
  tri1 #7 n4i, n4o;
  wire #7 n5i, n5o;
  wire #3 n6i, n6o;
  assign n1o = d;
  assign n2o = d;
  assign n3o = d;
  assign n4o = d;
  assign n5o = d;
  assign n6o = d;

  port_collapse_net_delay_in_wand #(.D(3)) u1i(n1i, d);
  port_collapse_net_delay_in_wand #(.D(3), .DRIVE(1'b0)) u1o(n1o, d);
  port_collapse_net_delay_in_wire #(.D(3)) u2i(n2i, d);
  port_collapse_net_delay_in_wire #(.D(3), .DRIVE(1'b0)) u2o(n2o, d);
  port_collapse_net_delay_in_tri0 #(.D(3)) u3i(n3i, d);
  port_collapse_net_delay_in_tri0 #(.D(3), .DRIVE(1'b0)) u3o(n3o, d);
  port_collapse_net_delay_in_wire #(.D(3)) u4i(n4i, d);
  port_collapse_net_delay_in_wire #(.D(3), .DRIVE(1'b0)) u4o(n4o, d);
  port_collapse_net_delay_in_wire #(.D(3)) u5i(n5i, d);
  port_collapse_net_delay_in_wire #(.D(3), .DRIVE(1'b0)) u5o(n5o, d);
  port_collapse_net_delay_in_wand #(.D(7)) u6i(n6i, d);
  port_collapse_net_delay_in_wand #(.D(7), .DRIVE(1'b0)) u6o(n6o, d);

  logic [0:5] s1i, s1o, s2i, s2o, s3i, s3o, s4i, s4o, s5i, s5o, s6i, s6o;

  task automatic sample(int k);
    s1i[k] = n1i; s1o[k] = n1o;
    s2i[k] = n2i; s2o[k] = n2o;
    s3i[k] = n3i; s3o[k] = n3o;
    s4i[k] = n4i; s4o[k] = n4o;
    s5i[k] = n5i; s5o[k] = n5o;
    s6i[k] = n6i; s6o[k] = n6o;
  endtask

  initial begin
    d = 1'b0;
    #10 d = 1'b1;
    #2 sample(0);
    #3 sample(1);
    #4 sample(2);
    #11 d = 1'b0;
    #2 sample(3);
    #3 sample(4);
    #4 sample(5);
    $display("wand #3 inside, wire #7 outside: driven inside %b, outside %b", s1i, s1o);
    $display("wire #3 inside, wand #7 outside: driven inside %b, outside %b", s2i, s2o);
    $display("tri0 #3 inside, wire #7 outside: driven inside %b, outside %b", s3i, s3o);
    $display("wire #3 inside, tri1 #7 outside: driven inside %b, outside %b", s4i, s4o);
    $display("wire #3 inside, wire #7 outside: driven inside %b, outside %b", s5i, s5o);
    $display("wand #7 inside, wire #3 outside: driven inside %b, outside %b", s6i, s6o);
  end
endmodule
