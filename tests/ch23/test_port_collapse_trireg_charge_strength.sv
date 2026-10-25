/*
:name: test_port_collapse_trireg_charge_strength
:description: When Table 23-1 selects a trireg as the type of the net that a port connection becomes, the charge strength declared for that trireg is the strength of the merged net in the capacitive state (IEEE 1800-2023 Section 23.3.3.7)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7 6.6.4 21.2.1.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_port_collapse_trireg_charge_strength.expected
*/
// IEEE 1800-2023 §23.3.3.7: when a port connects nets of different net
// types, the merged (simulated) net takes the type that Table 23-1 selects,
// and when the selected net is a trireg, the charge strength declared for
// that trireg applies to the merged net. By §6.6.4 a trireg that a strong
// driver drives has strong strength, and when all its drivers are z it
// keeps its last value with its charge strength: small, medium (the
// default) or large. %v shows these as St, Sm, Me and La (§21.2.1.4).
// The cells, with the trireg that Table 23-1 selects:
//   trireg (small) inside, wire outside: the internal trireg, small;
//   trireg (large) inside, wire outside: the internal trireg, large;
//   trireg inside, wire outside: the internal trireg, medium by default;
//   wire inside, trireg (small) outside: the external trireg, small;
//   trireg (small) inside, trireg (large) outside: the external one, large;
//   trireg (large) inside, trireg (small) outside: the external one, small.
// The port nets are declared in the module bodies (non-ANSI style), where a
// charge strength can be given. A continuous assignment outside each port
// drives 1, then z, then 0, then z; after each step the test prints the
// merged net with %v from outside and from inside (through a hierarchical
// name), which are the same net. A strength taken from the other trireg,
// or the default medium, would change the second and fourth lines of a
// cell. Icarus Verilog 13.0 and Verilator 5.052 do not support trireg nets,
// so this expected output follows the standard alone.

module port_collapse_trireg_charge_strength_small(w);
  inout w;
  trireg (small) w;
endmodule

module port_collapse_trireg_charge_strength_large(w);
  inout w;
  trireg (large) w;
endmodule

module port_collapse_trireg_charge_strength_medium(w);
  inout w;
  trireg w;
endmodule

module port_collapse_trireg_charge_strength_wire(w);
  inout w;
  wire w;
endmodule

module test_port_collapse_trireg_charge_strength;
  // Code of the driver outside the ports: 0 drives 0, 1 drives 1, 2 drives z.
  logic [1:0] co;

  wire n1, n2, n3;
  trireg (small) n4;
  trireg (large) n5;
  trireg (small) n6;
  assign n1 = co[1] ? 1'bz : co[0];
  assign n2 = co[1] ? 1'bz : co[0];
  assign n3 = co[1] ? 1'bz : co[0];
  assign n4 = co[1] ? 1'bz : co[0];
  assign n5 = co[1] ? 1'bz : co[0];
  assign n6 = co[1] ? 1'bz : co[0];

  port_collapse_trireg_charge_strength_small u1(n1);
  port_collapse_trireg_charge_strength_large u2(n2);
  port_collapse_trireg_charge_strength_medium u3(n3);
  port_collapse_trireg_charge_strength_wire u4(n4);
  port_collapse_trireg_charge_strength_small u5(n5);
  port_collapse_trireg_charge_strength_large u6(n6);

  task automatic show(string step);
    $display("%s trireg (small) inside, wire outside:            outside %v inside %v",
             step, n1, u1.w);
    $display("%s trireg (large) inside, wire outside:            outside %v inside %v",
             step, n2, u2.w);
    $display("%s trireg inside, wire outside:                    outside %v inside %v",
             step, n3, u3.w);
    $display("%s wire inside, trireg (small) outside:            outside %v inside %v",
             step, n4, u4.w);
    $display("%s trireg (small) inside, trireg (large) outside:  outside %v inside %v",
             step, n5, u5.w);
    $display("%s trireg (large) inside, trireg (small) outside:  outside %v inside %v",
             step, n6, u6.w);
  endtask

  initial begin
    co = 1;
    #1 show("drive 1:");
    co = 2;
    #1 show("hold 1: ");
    co = 0;
    #1 show("drive 0:");
    co = 2;
    #1 show("hold 0: ");
  end
endmodule
