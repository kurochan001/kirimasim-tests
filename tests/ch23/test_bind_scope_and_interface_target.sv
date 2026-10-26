/*
:name: test_bind_scope_and_interface_target
:description: A scope-target bind without an instance list adds an instance to every instance of the target module, the bind instantiation connects to the target's items, and a bind whose target scope is an interface adds only an interface instance (IEEE 1800-2023 Sections 23.11 and A.1.4, A.10)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.11 A.1.4 A.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bind_scope_and_interface_target.expected
*/
// IEEE 1800-2023 A.1.4: a bind directive is bind bind_target_scope
// [ : bind_target_instance_list ] bind_instantiation ; or bind
// bind_target_instance bind_instantiation ;. A.10 clarification 4: when the
// bind target scope is an interface, the bind instantiation is an interface
// instantiation or a checker instantiation.
//
// The target module wA_bt has an input a, an output b and an internal net
// probed. The first bind names the module wA_bt and no instance list, so it
// adds the module instance wA_bt_probe p to each of the two instances u1 and
// u2; p connects its input to the target's a and drives the target's probed
// net. The second bind names the interface wA_bi and adds the interface
// instance wA_bi_mon m to the interface instance di; m connects to di's clk
// and v and drives di's seen net.
//
// At time 1 the test sets a to 1 and di.v to 1, so each target's probed net
// and the interface's seen net are 1, and the target outputs follow a. A
// bind that inserted the probe into only one instance, or that did not
// connect the bind instantiation's ports to the target's items, gives a 0 at
// one of the printed places. The expected output follows the standard;
// Icarus Verilog 13.0 does not parse a bind directive and Verilator 5.052
// does not support a bind with an instance list, which this test does not
// use.

`timescale 1ns/1ns

module wA_bt(input logic a, output logic b);
  logic probed;
  assign b = a;
endmodule

module wA_bt_probe(input logic a, output logic seen);
  assign seen = a;
endmodule

interface wA_bi(input logic clk);
  logic v;
  logic seen;
endinterface

interface wA_bi_mon(input logic clk, input logic v, output logic seen);
  assign seen = v;
endinterface

module test_bind_scope_and_interface_target;
  logic a = 1'b0;
  logic b1, b2;
  logic clk = 1'b0;

  wA_bt u1(.a(a), .b(b1));
  wA_bt u2(.a(a), .b(b2));
  wA_bi di(clk);

  initial begin
    #1 a = 1'b1;
    di.v = 1'b1;
    #1;
    $display("u1 probed=%b b=%b", u1.probed, b1);
    $display("u2 probed=%b b=%b", u2.probed, b2);
    $display("interface seen=%b", di.seen);
  end
endmodule

bind wA_bt wA_bt_probe p(.a(a), .seen(probed));
bind wA_bi wA_bi_mon m(.clk(clk), .v(v), .seen(seen));
