/*
:name: test_port_collapse_internal_supply
:description: An inout port of type supply0 or supply1 merges with an outer wire, tri, tri0 or tri1, a wand or triand outside a supply0 and a wor or trior outside a supply1 into a supply net of the internal type, and with an outer net of the same type into that type, as Table 23-1 selects (IEEE 1800-2023 Section 23.3.3.7)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7 6.6.1 6.6.3 6.6.5 6.6.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_port_collapse_internal_supply.expected
*/
// IEEE 1800-2023 §23.3.3.7: when a port connects nets of different net
// types, the two nets can become one simulated net, whose type Table 23-1
// selects from the internal net (declared in the module) and the external
// net (in the instantiation). For an internal supply0 or supply1 the table
// selects the internal type when the external net is a wire, tri, wand,
// triand, wor, trior, tri0 or tri1, and the external type when it is a net
// of the same supply type, in all these cells without a warning. Each
// instance below connects an inout port of type supply0 or supply1, which
// has no driver, to an outer net, which has a continuous assignment
// outside the module. The cells of a supply0 inside and a wor or trior
// outside, and of a supply1 inside and a wand or triand outside, are in
// test_port_collapse_wired_opposite_supply.
// The test runs five phases, written (driver inside, driver outside): (1, 0),
// (0, z), (z, z), (z, 1) and (z, z), and records after each phase the merged
// net seen from outside (the outer net) and from inside (the port, through a
// hierarchical name); both views are the same net and print the same.
// Only the outer driver is active: it drives 0, z, z, 1 and z. A supply0
// or supply1 net has supply strength (§6.6.6), which no strong driver
// overcomes, so it gives 00000 or 11111. A merged net of the external type
// would follow the outer driver instead: 0zz1z for a wire, tri, wand,
// triand, wor or trior, 00010 for a tri0 and 01111 for a tri1.

module port_collapse_internal_supply_in_supply0(inout supply0 w, input logic [1:0] c);
endmodule

module port_collapse_internal_supply_in_supply1(inout supply1 w, input logic [1:0] c);
endmodule

module test_port_collapse_internal_supply;
  // Codes of the driver inside the port (ci) and outside it (co):
  // 0 drives 0, 1 drives 1, 2 drives z.
  logic [1:0] ci, co;

  wire n_supply0_wire;
  assign n_supply0_wire = co[1] ? 1'bz : co[0];
  port_collapse_internal_supply_in_supply0 u_supply0_wire(n_supply0_wire, ci);
  logic [0:4] o_supply0_wire, i_supply0_wire;

  tri n_supply0_tri;
  assign n_supply0_tri = co[1] ? 1'bz : co[0];
  port_collapse_internal_supply_in_supply0 u_supply0_tri(n_supply0_tri, ci);
  logic [0:4] o_supply0_tri, i_supply0_tri;

  wand n_supply0_wand;
  assign n_supply0_wand = co[1] ? 1'bz : co[0];
  port_collapse_internal_supply_in_supply0 u_supply0_wand(n_supply0_wand, ci);
  logic [0:4] o_supply0_wand, i_supply0_wand;

  triand n_supply0_triand;
  assign n_supply0_triand = co[1] ? 1'bz : co[0];
  port_collapse_internal_supply_in_supply0 u_supply0_triand(n_supply0_triand, ci);
  logic [0:4] o_supply0_triand, i_supply0_triand;

  tri0 n_supply0_tri0;
  assign n_supply0_tri0 = co[1] ? 1'bz : co[0];
  port_collapse_internal_supply_in_supply0 u_supply0_tri0(n_supply0_tri0, ci);
  logic [0:4] o_supply0_tri0, i_supply0_tri0;

  tri1 n_supply0_tri1;
  assign n_supply0_tri1 = co[1] ? 1'bz : co[0];
  port_collapse_internal_supply_in_supply0 u_supply0_tri1(n_supply0_tri1, ci);
  logic [0:4] o_supply0_tri1, i_supply0_tri1;

  supply0 n_supply0_supply0;
  port_collapse_internal_supply_in_supply0 u_supply0_supply0(n_supply0_supply0, ci);
  logic [0:4] o_supply0_supply0, i_supply0_supply0;

  wire n_supply1_wire;
  assign n_supply1_wire = co[1] ? 1'bz : co[0];
  port_collapse_internal_supply_in_supply1 u_supply1_wire(n_supply1_wire, ci);
  logic [0:4] o_supply1_wire, i_supply1_wire;

  tri n_supply1_tri;
  assign n_supply1_tri = co[1] ? 1'bz : co[0];
  port_collapse_internal_supply_in_supply1 u_supply1_tri(n_supply1_tri, ci);
  logic [0:4] o_supply1_tri, i_supply1_tri;

  wor n_supply1_wor;
  assign n_supply1_wor = co[1] ? 1'bz : co[0];
  port_collapse_internal_supply_in_supply1 u_supply1_wor(n_supply1_wor, ci);
  logic [0:4] o_supply1_wor, i_supply1_wor;

  trior n_supply1_trior;
  assign n_supply1_trior = co[1] ? 1'bz : co[0];
  port_collapse_internal_supply_in_supply1 u_supply1_trior(n_supply1_trior, ci);
  logic [0:4] o_supply1_trior, i_supply1_trior;

  tri0 n_supply1_tri0;
  assign n_supply1_tri0 = co[1] ? 1'bz : co[0];
  port_collapse_internal_supply_in_supply1 u_supply1_tri0(n_supply1_tri0, ci);
  logic [0:4] o_supply1_tri0, i_supply1_tri0;

  tri1 n_supply1_tri1;
  assign n_supply1_tri1 = co[1] ? 1'bz : co[0];
  port_collapse_internal_supply_in_supply1 u_supply1_tri1(n_supply1_tri1, ci);
  logic [0:4] o_supply1_tri1, i_supply1_tri1;

  supply1 n_supply1_supply1;
  port_collapse_internal_supply_in_supply1 u_supply1_supply1(n_supply1_supply1, ci);
  logic [0:4] o_supply1_supply1, i_supply1_supply1;

  task automatic sample(int k);
    o_supply0_wire[k] = n_supply0_wire;
    i_supply0_wire[k] = u_supply0_wire.w;
    o_supply0_tri[k] = n_supply0_tri;
    i_supply0_tri[k] = u_supply0_tri.w;
    o_supply0_wand[k] = n_supply0_wand;
    i_supply0_wand[k] = u_supply0_wand.w;
    o_supply0_triand[k] = n_supply0_triand;
    i_supply0_triand[k] = u_supply0_triand.w;
    o_supply0_tri0[k] = n_supply0_tri0;
    i_supply0_tri0[k] = u_supply0_tri0.w;
    o_supply0_tri1[k] = n_supply0_tri1;
    i_supply0_tri1[k] = u_supply0_tri1.w;
    o_supply0_supply0[k] = n_supply0_supply0;
    i_supply0_supply0[k] = u_supply0_supply0.w;
    o_supply1_wire[k] = n_supply1_wire;
    i_supply1_wire[k] = u_supply1_wire.w;
    o_supply1_tri[k] = n_supply1_tri;
    i_supply1_tri[k] = u_supply1_tri.w;
    o_supply1_wor[k] = n_supply1_wor;
    i_supply1_wor[k] = u_supply1_wor.w;
    o_supply1_trior[k] = n_supply1_trior;
    i_supply1_trior[k] = u_supply1_trior.w;
    o_supply1_tri0[k] = n_supply1_tri0;
    i_supply1_tri0[k] = u_supply1_tri0.w;
    o_supply1_tri1[k] = n_supply1_tri1;
    i_supply1_tri1[k] = u_supply1_tri1.w;
    o_supply1_supply1[k] = n_supply1_supply1;
    i_supply1_supply1[k] = u_supply1_supply1.w;
  endtask

  initial begin
    ci = 1; co = 0;
    #1 sample(0);
    ci = 0; co = 2;
    #1 sample(1);
    ci = 2; co = 2;
    #1 sample(2);
    ci = 2; co = 1;
    #1 sample(3);
    ci = 2; co = 2;
    #1 sample(4);
    $display("supply0 inside, wire outside:    outside %b inside %b",
             o_supply0_wire, i_supply0_wire);
    $display("supply0 inside, tri outside:     outside %b inside %b",
             o_supply0_tri, i_supply0_tri);
    $display("supply0 inside, wand outside:    outside %b inside %b",
             o_supply0_wand, i_supply0_wand);
    $display("supply0 inside, triand outside:  outside %b inside %b",
             o_supply0_triand, i_supply0_triand);
    $display("supply0 inside, tri0 outside:    outside %b inside %b",
             o_supply0_tri0, i_supply0_tri0);
    $display("supply0 inside, tri1 outside:    outside %b inside %b",
             o_supply0_tri1, i_supply0_tri1);
    $display("supply0 inside, supply0 outside: outside %b inside %b",
             o_supply0_supply0, i_supply0_supply0);
    $display("supply1 inside, wire outside:    outside %b inside %b",
             o_supply1_wire, i_supply1_wire);
    $display("supply1 inside, tri outside:     outside %b inside %b",
             o_supply1_tri, i_supply1_tri);
    $display("supply1 inside, wor outside:     outside %b inside %b",
             o_supply1_wor, i_supply1_wor);
    $display("supply1 inside, trior outside:   outside %b inside %b",
             o_supply1_trior, i_supply1_trior);
    $display("supply1 inside, tri0 outside:    outside %b inside %b",
             o_supply1_tri0, i_supply1_tri0);
    $display("supply1 inside, tri1 outside:    outside %b inside %b",
             o_supply1_tri1, i_supply1_tri1);
    $display("supply1 inside, supply1 outside: outside %b inside %b",
             o_supply1_supply1, i_supply1_supply1);
  end
endmodule
