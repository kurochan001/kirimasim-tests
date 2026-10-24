/*
:name: test_elaborated_net_joins_drivers_across_hierarchy
:description: Elaboration joins a top-level net and the inout ports it is connected to, at two levels of hierarchy, into one net, so drivers in different modules resolve together and every port name reads the resolved value; a wand net connected to wire ports takes the wired-AND of the drivers inside the instances (IEEE 1800-2023 Section 3.12)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.12 23.3.3.7 6.6.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_elaborated_net_joins_drivers_across_hierarchy.expected
*/
// IEEE 1800-2023 §3.12: elaboration establishes the net connectivity of the
// design before simulation. §23.3.3.7: nets connected through a port become
// one simulated net, whose type for an internal wire and an external wand is
// wand. §6.6.1: drivers of a tri net with the same strength resolve to x
// when they disagree, and a net without an active driver is z.
// The tri net bus of the top module is connected to the inout port pin of
// u_b (nc_driver) and of u_a (nc_mid), which passes it on to the inout port
// of its own nc_driver u_drv, two levels down. Each nc_driver drives pin with
// val while en is 1 and releases it otherwise; the top module also drives
// bus. The enables are changed at even times and the values printed at odd
// times, through bus and through the port names u_a.pin, u_a.u_drv.pin and
// u_b.pin:
// - time 1: only u_a.u_drv drives 1, so all four read 1;
// - time 3: only u_b drives 0: 0;
// - time 5: u_b drives 0 and the top module 1: x;
// - time 7: no driver: z.
// The wand net wa is connected to the wire ports of two nc_driver instances
// that drive 1 and 0, so it has the wired-AND value 0.

`timescale 1ns/1ns

module nc_driver (inout wire pin, input logic en, input logic val);
  assign pin = en ? val : 1'bz;
endmodule

module nc_mid (inout wire pin, input logic en, input logic val);
  nc_driver u_drv (.pin(pin), .en(en), .val(val));
endmodule

module test_elaborated_net_joins_drivers_across_hierarchy;
  tri bus;
  wand wa;
  logic en_a = 1'b1, val_a = 1'b1;
  logic en_b = 1'b0, val_b = 1'b0;
  logic en_t = 1'b0, val_t = 1'b1;

  nc_mid u_a (.pin(bus), .en(en_a), .val(val_a));
  nc_driver u_b (.pin(bus), .en(en_b), .val(val_b));
  assign bus = en_t ? val_t : 1'bz;

  nc_driver u_w1 (.pin(wa), .en(1'b1), .val(1'b1));
  nc_driver u_w0 (.pin(wa), .en(1'b1), .val(1'b0));

  task automatic show();
    $display("t=%0t bus=%b u_a.pin=%b u_a.u_drv.pin=%b u_b.pin=%b", $time, bus, u_a.pin,
             u_a.u_drv.pin, u_b.pin);
  endtask

  initial begin
    #1 show();
    #1 en_a = 1'b0;
    en_b = 1'b1;
    #1 show();
    #1 en_t = 1'b1;
    #1 show();
    #1 en_b = 1'b0;
    en_t = 1'b0;
    #1 show();
    $display("wand: wa=%b", wa);
  end
endmodule
