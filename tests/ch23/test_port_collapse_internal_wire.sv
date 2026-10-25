/*
:name: test_port_collapse_internal_wire
:description: An inout port of type wire or tri merges with the outer net into one net of the external net type, as Table 23-1 selects for wire, tri, wand, triand, wor, trior, tri0, tri1, supply0 and supply1 outside (IEEE 1800-2023 Section 23.3.3.7)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7 6.6.1 6.6.3 6.6.5 6.6.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_port_collapse_internal_wire.expected
*/
// IEEE 1800-2023 §23.3.3.7: when a port connects nets of different net
// types, the two nets can become one simulated net, whose type Table 23-1
// selects from the internal net (declared in the module) and the external
// net (in the instantiation). For an internal wire or tri the table selects
// the external net type in every column, without a warning. Each instance
// below connects an inout port of type wire or tri to an outer net of type
// wire, tri, wand, triand, wor, trior, tri0, tri1, supply0 or supply1. The
// port has a continuous assignment inside the module and the outer net one
// outside, except supply nets, which have no driver.
// The test runs five phases, written (driver inside, driver outside): (1, 0),
// (0, z), (z, z), (z, 1) and (z, z), and records after each phase the merged
// net seen from outside (the outer net) and from inside (the port, through a
// hierarchical name); both views are the same net and print the same.
// With strong drivers, the truth tables of §6.6.1, §6.6.3 and §6.6.5 and
// the supply strength of §6.6.6 give x0z1z for wire and tri, 00z1z for
// wand and triand, 10z1z for wor and trior, x0010 for tri0 and x0111 for
// tri1, and a supply0 or supply1 net is 00000 or 11111 whatever the inner
// driver does. A merged net that kept the internal type would print x0z1z,
// or 10zzz with a supply net outside, on every line whose outer net is
// not a wire or tri.

module port_collapse_internal_wire_in_wire(inout wire w, input logic [1:0] c);
  assign w = c[1] ? 1'bz : c[0];
endmodule

module port_collapse_internal_wire_in_tri(inout tri w, input logic [1:0] c);
  assign w = c[1] ? 1'bz : c[0];
endmodule

module test_port_collapse_internal_wire;
  // Codes of the driver inside the port (ci) and outside it (co):
  // 0 drives 0, 1 drives 1, 2 drives z.
  logic [1:0] ci, co;

  wire n_wire_wire;
  assign n_wire_wire = co[1] ? 1'bz : co[0];
  port_collapse_internal_wire_in_wire u_wire_wire(n_wire_wire, ci);
  logic [0:4] o_wire_wire, i_wire_wire;

  tri n_wire_tri;
  assign n_wire_tri = co[1] ? 1'bz : co[0];
  port_collapse_internal_wire_in_wire u_wire_tri(n_wire_tri, ci);
  logic [0:4] o_wire_tri, i_wire_tri;

  wire n_tri_wire;
  assign n_tri_wire = co[1] ? 1'bz : co[0];
  port_collapse_internal_wire_in_tri u_tri_wire(n_tri_wire, ci);
  logic [0:4] o_tri_wire, i_tri_wire;

  tri n_tri_tri;
  assign n_tri_tri = co[1] ? 1'bz : co[0];
  port_collapse_internal_wire_in_tri u_tri_tri(n_tri_tri, ci);
  logic [0:4] o_tri_tri, i_tri_tri;

  wand n_wire_wand;
  assign n_wire_wand = co[1] ? 1'bz : co[0];
  port_collapse_internal_wire_in_wire u_wire_wand(n_wire_wand, ci);
  logic [0:4] o_wire_wand, i_wire_wand;

  triand n_wire_triand;
  assign n_wire_triand = co[1] ? 1'bz : co[0];
  port_collapse_internal_wire_in_wire u_wire_triand(n_wire_triand, ci);
  logic [0:4] o_wire_triand, i_wire_triand;

  wand n_tri_wand;
  assign n_tri_wand = co[1] ? 1'bz : co[0];
  port_collapse_internal_wire_in_tri u_tri_wand(n_tri_wand, ci);
  logic [0:4] o_tri_wand, i_tri_wand;

  triand n_tri_triand;
  assign n_tri_triand = co[1] ? 1'bz : co[0];
  port_collapse_internal_wire_in_tri u_tri_triand(n_tri_triand, ci);
  logic [0:4] o_tri_triand, i_tri_triand;

  wor n_wire_wor;
  assign n_wire_wor = co[1] ? 1'bz : co[0];
  port_collapse_internal_wire_in_wire u_wire_wor(n_wire_wor, ci);
  logic [0:4] o_wire_wor, i_wire_wor;

  trior n_wire_trior;
  assign n_wire_trior = co[1] ? 1'bz : co[0];
  port_collapse_internal_wire_in_wire u_wire_trior(n_wire_trior, ci);
  logic [0:4] o_wire_trior, i_wire_trior;

  wor n_tri_wor;
  assign n_tri_wor = co[1] ? 1'bz : co[0];
  port_collapse_internal_wire_in_tri u_tri_wor(n_tri_wor, ci);
  logic [0:4] o_tri_wor, i_tri_wor;

  trior n_tri_trior;
  assign n_tri_trior = co[1] ? 1'bz : co[0];
  port_collapse_internal_wire_in_tri u_tri_trior(n_tri_trior, ci);
  logic [0:4] o_tri_trior, i_tri_trior;

  tri0 n_wire_tri0;
  assign n_wire_tri0 = co[1] ? 1'bz : co[0];
  port_collapse_internal_wire_in_wire u_wire_tri0(n_wire_tri0, ci);
  logic [0:4] o_wire_tri0, i_wire_tri0;

  tri0 n_tri_tri0;
  assign n_tri_tri0 = co[1] ? 1'bz : co[0];
  port_collapse_internal_wire_in_tri u_tri_tri0(n_tri_tri0, ci);
  logic [0:4] o_tri_tri0, i_tri_tri0;

  tri1 n_wire_tri1;
  assign n_wire_tri1 = co[1] ? 1'bz : co[0];
  port_collapse_internal_wire_in_wire u_wire_tri1(n_wire_tri1, ci);
  logic [0:4] o_wire_tri1, i_wire_tri1;

  tri1 n_tri_tri1;
  assign n_tri_tri1 = co[1] ? 1'bz : co[0];
  port_collapse_internal_wire_in_tri u_tri_tri1(n_tri_tri1, ci);
  logic [0:4] o_tri_tri1, i_tri_tri1;

  supply0 n_wire_supply0;
  port_collapse_internal_wire_in_wire u_wire_supply0(n_wire_supply0, ci);
  logic [0:4] o_wire_supply0, i_wire_supply0;

  supply0 n_tri_supply0;
  port_collapse_internal_wire_in_tri u_tri_supply0(n_tri_supply0, ci);
  logic [0:4] o_tri_supply0, i_tri_supply0;

  supply1 n_wire_supply1;
  port_collapse_internal_wire_in_wire u_wire_supply1(n_wire_supply1, ci);
  logic [0:4] o_wire_supply1, i_wire_supply1;

  supply1 n_tri_supply1;
  port_collapse_internal_wire_in_tri u_tri_supply1(n_tri_supply1, ci);
  logic [0:4] o_tri_supply1, i_tri_supply1;

  task automatic sample(int k);
    o_wire_wire[k] = n_wire_wire;
    i_wire_wire[k] = u_wire_wire.w;
    o_wire_tri[k] = n_wire_tri;
    i_wire_tri[k] = u_wire_tri.w;
    o_tri_wire[k] = n_tri_wire;
    i_tri_wire[k] = u_tri_wire.w;
    o_tri_tri[k] = n_tri_tri;
    i_tri_tri[k] = u_tri_tri.w;
    o_wire_wand[k] = n_wire_wand;
    i_wire_wand[k] = u_wire_wand.w;
    o_wire_triand[k] = n_wire_triand;
    i_wire_triand[k] = u_wire_triand.w;
    o_tri_wand[k] = n_tri_wand;
    i_tri_wand[k] = u_tri_wand.w;
    o_tri_triand[k] = n_tri_triand;
    i_tri_triand[k] = u_tri_triand.w;
    o_wire_wor[k] = n_wire_wor;
    i_wire_wor[k] = u_wire_wor.w;
    o_wire_trior[k] = n_wire_trior;
    i_wire_trior[k] = u_wire_trior.w;
    o_tri_wor[k] = n_tri_wor;
    i_tri_wor[k] = u_tri_wor.w;
    o_tri_trior[k] = n_tri_trior;
    i_tri_trior[k] = u_tri_trior.w;
    o_wire_tri0[k] = n_wire_tri0;
    i_wire_tri0[k] = u_wire_tri0.w;
    o_tri_tri0[k] = n_tri_tri0;
    i_tri_tri0[k] = u_tri_tri0.w;
    o_wire_tri1[k] = n_wire_tri1;
    i_wire_tri1[k] = u_wire_tri1.w;
    o_tri_tri1[k] = n_tri_tri1;
    i_tri_tri1[k] = u_tri_tri1.w;
    o_wire_supply0[k] = n_wire_supply0;
    i_wire_supply0[k] = u_wire_supply0.w;
    o_tri_supply0[k] = n_tri_supply0;
    i_tri_supply0[k] = u_tri_supply0.w;
    o_wire_supply1[k] = n_wire_supply1;
    i_wire_supply1[k] = u_wire_supply1.w;
    o_tri_supply1[k] = n_tri_supply1;
    i_tri_supply1[k] = u_tri_supply1.w;
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
    $display("wire inside, wire outside:       outside %b inside %b",
             o_wire_wire, i_wire_wire);
    $display("wire inside, tri outside:        outside %b inside %b",
             o_wire_tri, i_wire_tri);
    $display("tri inside, wire outside:        outside %b inside %b",
             o_tri_wire, i_tri_wire);
    $display("tri inside, tri outside:         outside %b inside %b",
             o_tri_tri, i_tri_tri);
    $display("wire inside, wand outside:       outside %b inside %b",
             o_wire_wand, i_wire_wand);
    $display("wire inside, triand outside:     outside %b inside %b",
             o_wire_triand, i_wire_triand);
    $display("tri inside, wand outside:        outside %b inside %b",
             o_tri_wand, i_tri_wand);
    $display("tri inside, triand outside:      outside %b inside %b",
             o_tri_triand, i_tri_triand);
    $display("wire inside, wor outside:        outside %b inside %b",
             o_wire_wor, i_wire_wor);
    $display("wire inside, trior outside:      outside %b inside %b",
             o_wire_trior, i_wire_trior);
    $display("tri inside, wor outside:         outside %b inside %b",
             o_tri_wor, i_tri_wor);
    $display("tri inside, trior outside:       outside %b inside %b",
             o_tri_trior, i_tri_trior);
    $display("wire inside, tri0 outside:       outside %b inside %b",
             o_wire_tri0, i_wire_tri0);
    $display("tri inside, tri0 outside:        outside %b inside %b",
             o_tri_tri0, i_tri_tri0);
    $display("wire inside, tri1 outside:       outside %b inside %b",
             o_wire_tri1, i_wire_tri1);
    $display("tri inside, tri1 outside:        outside %b inside %b",
             o_tri_tri1, i_tri_tri1);
    $display("wire inside, supply0 outside:    outside %b inside %b",
             o_wire_supply0, i_wire_supply0);
    $display("tri inside, supply0 outside:     outside %b inside %b",
             o_tri_supply0, i_tri_supply0);
    $display("wire inside, supply1 outside:    outside %b inside %b",
             o_wire_supply1, i_wire_supply1);
    $display("tri inside, supply1 outside:     outside %b inside %b",
             o_tri_supply1, i_tri_supply1);
  end
endmodule
