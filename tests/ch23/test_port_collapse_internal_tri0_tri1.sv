/*
:name: test_port_collapse_internal_tri0_tri1
:description: An inout port of type tri0 or tri1 merges with an outer wire or tri into a net of the internal type, and with an outer net of the same type, supply0 or supply1 into a net of the external type, as Table 23-1 selects (IEEE 1800-2023 Section 23.3.3.7)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7 6.6.1 6.6.5 6.6.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_port_collapse_internal_tri0_tri1.expected
*/
// IEEE 1800-2023 §23.3.3.7: when a port connects nets of different net
// types, the two nets can become one simulated net, whose type Table 23-1
// selects from the internal net (declared in the module) and the external
// net (in the instantiation). For an internal tri0 or tri1 the table
// selects the internal type when the external net is a wire or tri, and
// the external type when it is a net of the same type, a supply0 or a
// supply1, in all these cells without a warning. Each instance below
// connects an inout port of type tri0 or tri1 to an outer net of one of
// these types. The port has a continuous assignment inside the module and
// the outer net one outside, except supply nets, which have no driver.
// The test runs five phases, written (driver inside, driver outside): (1, 0),
// (0, z), (z, z), (z, 1) and (z, z), and records after each phase the merged
// net seen from outside (the outer net) and from inside (the port, through a
// hierarchical name); both views are the same net and print the same.
// By §6.6.5 a tri0 is 0 and a tri1 is 1 when no driver drives it, so a
// tri0 gives x0010 and a tri1 x0111, where a wire or tri (§6.6.1) would be
// z in the third and fifth phases (x0z1z); a supply0 or supply1 net
// (§6.6.6) is 00000 or 11111 whatever the inner driver does, where a tri0
// would give 10000 and a tri1 10111.

module port_collapse_internal_tri0_tri1_in_tri0(inout tri0 w, input logic [1:0] c);
  assign w = c[1] ? 1'bz : c[0];
endmodule

module port_collapse_internal_tri0_tri1_in_tri1(inout tri1 w, input logic [1:0] c);
  assign w = c[1] ? 1'bz : c[0];
endmodule

module test_port_collapse_internal_tri0_tri1;
  // Codes of the driver inside the port (ci) and outside it (co):
  // 0 drives 0, 1 drives 1, 2 drives z.
  logic [1:0] ci, co;

  wire n_tri0_wire;
  assign n_tri0_wire = co[1] ? 1'bz : co[0];
  port_collapse_internal_tri0_tri1_in_tri0 u_tri0_wire(n_tri0_wire, ci);
  logic [0:4] o_tri0_wire, i_tri0_wire;

  tri n_tri0_tri;
  assign n_tri0_tri = co[1] ? 1'bz : co[0];
  port_collapse_internal_tri0_tri1_in_tri0 u_tri0_tri(n_tri0_tri, ci);
  logic [0:4] o_tri0_tri, i_tri0_tri;

  tri0 n_tri0_tri0;
  assign n_tri0_tri0 = co[1] ? 1'bz : co[0];
  port_collapse_internal_tri0_tri1_in_tri0 u_tri0_tri0(n_tri0_tri0, ci);
  logic [0:4] o_tri0_tri0, i_tri0_tri0;

  supply0 n_tri0_supply0;
  port_collapse_internal_tri0_tri1_in_tri0 u_tri0_supply0(n_tri0_supply0, ci);
  logic [0:4] o_tri0_supply0, i_tri0_supply0;

  supply1 n_tri0_supply1;
  port_collapse_internal_tri0_tri1_in_tri0 u_tri0_supply1(n_tri0_supply1, ci);
  logic [0:4] o_tri0_supply1, i_tri0_supply1;

  wire n_tri1_wire;
  assign n_tri1_wire = co[1] ? 1'bz : co[0];
  port_collapse_internal_tri0_tri1_in_tri1 u_tri1_wire(n_tri1_wire, ci);
  logic [0:4] o_tri1_wire, i_tri1_wire;

  tri n_tri1_tri;
  assign n_tri1_tri = co[1] ? 1'bz : co[0];
  port_collapse_internal_tri0_tri1_in_tri1 u_tri1_tri(n_tri1_tri, ci);
  logic [0:4] o_tri1_tri, i_tri1_tri;

  tri1 n_tri1_tri1;
  assign n_tri1_tri1 = co[1] ? 1'bz : co[0];
  port_collapse_internal_tri0_tri1_in_tri1 u_tri1_tri1(n_tri1_tri1, ci);
  logic [0:4] o_tri1_tri1, i_tri1_tri1;

  supply0 n_tri1_supply0;
  port_collapse_internal_tri0_tri1_in_tri1 u_tri1_supply0(n_tri1_supply0, ci);
  logic [0:4] o_tri1_supply0, i_tri1_supply0;

  supply1 n_tri1_supply1;
  port_collapse_internal_tri0_tri1_in_tri1 u_tri1_supply1(n_tri1_supply1, ci);
  logic [0:4] o_tri1_supply1, i_tri1_supply1;

  task automatic sample(int k);
    o_tri0_wire[k] = n_tri0_wire;
    i_tri0_wire[k] = u_tri0_wire.w;
    o_tri0_tri[k] = n_tri0_tri;
    i_tri0_tri[k] = u_tri0_tri.w;
    o_tri0_tri0[k] = n_tri0_tri0;
    i_tri0_tri0[k] = u_tri0_tri0.w;
    o_tri0_supply0[k] = n_tri0_supply0;
    i_tri0_supply0[k] = u_tri0_supply0.w;
    o_tri0_supply1[k] = n_tri0_supply1;
    i_tri0_supply1[k] = u_tri0_supply1.w;
    o_tri1_wire[k] = n_tri1_wire;
    i_tri1_wire[k] = u_tri1_wire.w;
    o_tri1_tri[k] = n_tri1_tri;
    i_tri1_tri[k] = u_tri1_tri.w;
    o_tri1_tri1[k] = n_tri1_tri1;
    i_tri1_tri1[k] = u_tri1_tri1.w;
    o_tri1_supply0[k] = n_tri1_supply0;
    i_tri1_supply0[k] = u_tri1_supply0.w;
    o_tri1_supply1[k] = n_tri1_supply1;
    i_tri1_supply1[k] = u_tri1_supply1.w;
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
    $display("tri0 inside, wire outside:       outside %b inside %b",
             o_tri0_wire, i_tri0_wire);
    $display("tri0 inside, tri outside:        outside %b inside %b",
             o_tri0_tri, i_tri0_tri);
    $display("tri0 inside, tri0 outside:       outside %b inside %b",
             o_tri0_tri0, i_tri0_tri0);
    $display("tri0 inside, supply0 outside:    outside %b inside %b",
             o_tri0_supply0, i_tri0_supply0);
    $display("tri0 inside, supply1 outside:    outside %b inside %b",
             o_tri0_supply1, i_tri0_supply1);
    $display("tri1 inside, wire outside:       outside %b inside %b",
             o_tri1_wire, i_tri1_wire);
    $display("tri1 inside, tri outside:        outside %b inside %b",
             o_tri1_tri, i_tri1_tri);
    $display("tri1 inside, tri1 outside:       outside %b inside %b",
             o_tri1_tri1, i_tri1_tri1);
    $display("tri1 inside, supply0 outside:    outside %b inside %b",
             o_tri1_supply0, i_tri1_supply0);
    $display("tri1 inside, supply1 outside:    outside %b inside %b",
             o_tri1_supply1, i_tri1_supply1);
  end
endmodule
