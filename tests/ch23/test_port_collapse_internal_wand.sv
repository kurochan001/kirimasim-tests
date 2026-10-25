/*
:name: test_port_collapse_internal_wand
:description: An inout port of type wand or triand merges with an outer wire or tri into a wand, and with an outer wand, triand or supply0 into a net of the external type, as Table 23-1 selects (IEEE 1800-2023 Section 23.3.3.7)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7 6.6.1 6.6.3 6.6.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_port_collapse_internal_wand.expected
*/
// IEEE 1800-2023 §23.3.3.7: when a port connects nets of different net
// types, the two nets can become one simulated net, whose type Table 23-1
// selects from the internal net (declared in the module) and the external
// net (in the instantiation). For an internal wand or triand the table
// selects the internal type when the external net is a wire or tri, and
// the external type when it is a wand, triand or supply0, in all these
// cells without a warning. Each instance below connects an inout port of
// type wand or triand to an outer net of one of these types. The port has
// a continuous assignment inside the module and the outer net one outside,
// except the supply0 net, which has no driver.
// The test runs five phases, written (driver inside, driver outside): (1, 0),
// (0, z), (z, z), (z, 1) and (z, z), and records after each phase the merged
// net seen from outside (the outer net) and from inside (the port, through a
// hierarchical name); both views are the same net and print the same.
// By the wired-and table of §6.6.3 a wand or triand gives 00z1z, where a
// wire or tri (§6.6.1) would give x0z1z for the conflict of the first
// phase; a supply0 net (§6.6.6) is 00000 whatever the inner driver does,
// where a wand would give 10zzz. The cell with a supply1 outside is in
// test_port_collapse_wired_opposite_supply.

module port_collapse_internal_wand_in_wand(inout wand w, input logic [1:0] c);
  assign w = c[1] ? 1'bz : c[0];
endmodule

module port_collapse_internal_wand_in_triand(inout triand w, input logic [1:0] c);
  assign w = c[1] ? 1'bz : c[0];
endmodule

module test_port_collapse_internal_wand;
  // Codes of the driver inside the port (ci) and outside it (co):
  // 0 drives 0, 1 drives 1, 2 drives z.
  logic [1:0] ci, co;

  wire n_wand_wire;
  assign n_wand_wire = co[1] ? 1'bz : co[0];
  port_collapse_internal_wand_in_wand u_wand_wire(n_wand_wire, ci);
  logic [0:4] o_wand_wire, i_wand_wire;

  tri n_wand_tri;
  assign n_wand_tri = co[1] ? 1'bz : co[0];
  port_collapse_internal_wand_in_wand u_wand_tri(n_wand_tri, ci);
  logic [0:4] o_wand_tri, i_wand_tri;

  wire n_triand_wire;
  assign n_triand_wire = co[1] ? 1'bz : co[0];
  port_collapse_internal_wand_in_triand u_triand_wire(n_triand_wire, ci);
  logic [0:4] o_triand_wire, i_triand_wire;

  tri n_triand_tri;
  assign n_triand_tri = co[1] ? 1'bz : co[0];
  port_collapse_internal_wand_in_triand u_triand_tri(n_triand_tri, ci);
  logic [0:4] o_triand_tri, i_triand_tri;

  wand n_wand_wand;
  assign n_wand_wand = co[1] ? 1'bz : co[0];
  port_collapse_internal_wand_in_wand u_wand_wand(n_wand_wand, ci);
  logic [0:4] o_wand_wand, i_wand_wand;

  triand n_wand_triand;
  assign n_wand_triand = co[1] ? 1'bz : co[0];
  port_collapse_internal_wand_in_wand u_wand_triand(n_wand_triand, ci);
  logic [0:4] o_wand_triand, i_wand_triand;

  wand n_triand_wand;
  assign n_triand_wand = co[1] ? 1'bz : co[0];
  port_collapse_internal_wand_in_triand u_triand_wand(n_triand_wand, ci);
  logic [0:4] o_triand_wand, i_triand_wand;

  triand n_triand_triand;
  assign n_triand_triand = co[1] ? 1'bz : co[0];
  port_collapse_internal_wand_in_triand u_triand_triand(n_triand_triand, ci);
  logic [0:4] o_triand_triand, i_triand_triand;

  supply0 n_wand_supply0;
  port_collapse_internal_wand_in_wand u_wand_supply0(n_wand_supply0, ci);
  logic [0:4] o_wand_supply0, i_wand_supply0;

  supply0 n_triand_supply0;
  port_collapse_internal_wand_in_triand u_triand_supply0(n_triand_supply0, ci);
  logic [0:4] o_triand_supply0, i_triand_supply0;

  task automatic sample(int k);
    o_wand_wire[k] = n_wand_wire;
    i_wand_wire[k] = u_wand_wire.w;
    o_wand_tri[k] = n_wand_tri;
    i_wand_tri[k] = u_wand_tri.w;
    o_triand_wire[k] = n_triand_wire;
    i_triand_wire[k] = u_triand_wire.w;
    o_triand_tri[k] = n_triand_tri;
    i_triand_tri[k] = u_triand_tri.w;
    o_wand_wand[k] = n_wand_wand;
    i_wand_wand[k] = u_wand_wand.w;
    o_wand_triand[k] = n_wand_triand;
    i_wand_triand[k] = u_wand_triand.w;
    o_triand_wand[k] = n_triand_wand;
    i_triand_wand[k] = u_triand_wand.w;
    o_triand_triand[k] = n_triand_triand;
    i_triand_triand[k] = u_triand_triand.w;
    o_wand_supply0[k] = n_wand_supply0;
    i_wand_supply0[k] = u_wand_supply0.w;
    o_triand_supply0[k] = n_triand_supply0;
    i_triand_supply0[k] = u_triand_supply0.w;
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
    $display("wand inside, wire outside:       outside %b inside %b",
             o_wand_wire, i_wand_wire);
    $display("wand inside, tri outside:        outside %b inside %b",
             o_wand_tri, i_wand_tri);
    $display("triand inside, wire outside:     outside %b inside %b",
             o_triand_wire, i_triand_wire);
    $display("triand inside, tri outside:      outside %b inside %b",
             o_triand_tri, i_triand_tri);
    $display("wand inside, wand outside:       outside %b inside %b",
             o_wand_wand, i_wand_wand);
    $display("wand inside, triand outside:     outside %b inside %b",
             o_wand_triand, i_wand_triand);
    $display("triand inside, wand outside:     outside %b inside %b",
             o_triand_wand, i_triand_wand);
    $display("triand inside, triand outside:   outside %b inside %b",
             o_triand_triand, i_triand_triand);
    $display("wand inside, supply0 outside:    outside %b inside %b",
             o_wand_supply0, i_wand_supply0);
    $display("triand inside, supply0 outside:  outside %b inside %b",
             o_triand_supply0, i_triand_supply0);
  end
endmodule
