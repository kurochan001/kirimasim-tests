/*
:name: test_interface_named_bundle_ports_share_variable_and_net
:description: Modules connected to one named-bundle interface instance, by position or by name, access its variable as a ref, all reading and writing the same variable, and its net as an inout, each driving it and reading the resolved value (IEEE 1800-2023 Section 25.3.2)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3.2
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_interface_named_bundle_ports_share_variable_and_net.expected
*/
// IEEE 1800-2023 §25.3.2: an interface can be a named bundle of variables and
// nets, and when it is referenced as a port, its variables are assumed to have
// ref access and its nets inout access. nbs_bus has the variable count and the
// net line. nbs_a is connected by position and nbs_b by name, both without a
// modport.
//   Variable: a sets count to 3 at 1, b adds 4 to it at 2 and a doubles it at
//   3; each step reads the value the other module left, and the top reads 14
//   at 4.
//   Net: a drives line with 1 while ea is 1 and b drives it with 0 while eb is
//   1, each driver being z otherwise. The top sets the enables at 10, 20 and
//   30 and reads line one step later: 1 from a alone, 0 from b alone, and z
//   with neither driving. b reads line through its port at 22 (0).
// Icarus Verilog 13.0 does not support interface ports, and the 5.052 release
// of Verilator is a two-state simulator, which cannot show the z.

`timescale 1ns/1ns

interface nbs_bus;
  logic [7:0] count;
  wire line;
endinterface

module nbs_a(nbs_bus p, input logic ea);
  assign p.line = ea ? 1'b1 : 1'bz;
  initial begin
    #1 p.count = 8'd3;
    #2 p.count = p.count * 2;
  end
endmodule

module nbs_b(nbs_bus q, input logic eb);
  assign q.line = eb ? 1'b0 : 1'bz;
  initial #2 q.count = q.count + 8'd4;
  initial #22 $display("b sees line=%b", q.line);
endmodule

module test_interface_named_bundle_ports_share_variable_and_net;
  logic ea = 1'b0, eb = 1'b0;
  nbs_bus bus ();
  nbs_a a (bus, ea);
  nbs_b b (.q(bus), .eb(eb));
  initial begin
    #4 $display("count=%0d", bus.count);
    #6 ea = 1'b1;
    #1 $display("ea=1 eb=0: line=%b", bus.line);
    #9 ea = 1'b0; eb = 1'b1;
    #1 $display("ea=0 eb=1: line=%b", bus.line);
    #9 eb = 1'b0;
    #1 $display("ea=0 eb=0: line=%b", bus.line);
  end
endmodule
