/*
:name: test_port_collapse_internal_wor
:description: An inout port of type wor or trior merges with an outer wire or tri into a wor, and with an outer wor, trior or supply1 into a net of the external type, as Table 23-1 selects (IEEE 1800-2023 Section 23.3.3.7)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7 6.6.1 6.6.3 6.6.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_port_collapse_internal_wor.expected
*/
// IEEE 1800-2023 §23.3.3.7: when a port connects nets of different net
// types, the two nets can become one simulated net, whose type Table 23-1
// selects from the internal net (declared in the module) and the external
// net (in the instantiation). For an internal wor or trior the table
// selects the internal type when the external net is a wire or tri, and
// the external type when it is a wor, trior or supply1, in all these cells
// without a warning. Each instance below connects an inout port of type
// wor or trior to an outer net of one of these types. The port has a
// continuous assignment inside the module and the outer net one outside,
// except the supply1 net, which has no driver.
// The test runs five phases, written (driver inside, driver outside): (1, 0),
// (0, z), (z, z), (z, 1) and (z, z), and records after each phase the merged
// net seen from outside (the outer net) and from inside (the port, through a
// hierarchical name); both views are the same net and print the same.
// By the wired-or table of §6.6.3 a wor or trior gives 10z1z, where a wire
// or tri (§6.6.1) would give x0z1z for the conflict of the first phase; a
// supply1 net (§6.6.6) is 11111 whatever the inner driver does, where a
// wor would give 10zzz. The cell with a supply0 outside is in
// test_port_collapse_wired_opposite_supply.

module port_collapse_internal_wor_in_wor(inout wor w, input logic [1:0] c);
  assign w = c[1] ? 1'bz : c[0];
endmodule

module port_collapse_internal_wor_in_trior(inout trior w, input logic [1:0] c);
  assign w = c[1] ? 1'bz : c[0];
endmodule

module test_port_collapse_internal_wor;
  // Codes of the driver inside the port (ci) and outside it (co):
  // 0 drives 0, 1 drives 1, 2 drives z.
  logic [1:0] ci, co;

  wire n_wor_wire;
  assign n_wor_wire = co[1] ? 1'bz : co[0];
  port_collapse_internal_wor_in_wor u_wor_wire(n_wor_wire, ci);
  logic [0:4] o_wor_wire, i_wor_wire;

  tri n_wor_tri;
  assign n_wor_tri = co[1] ? 1'bz : co[0];
  port_collapse_internal_wor_in_wor u_wor_tri(n_wor_tri, ci);
  logic [0:4] o_wor_tri, i_wor_tri;

  wire n_trior_wire;
  assign n_trior_wire = co[1] ? 1'bz : co[0];
  port_collapse_internal_wor_in_trior u_trior_wire(n_trior_wire, ci);
  logic [0:4] o_trior_wire, i_trior_wire;

  tri n_trior_tri;
  assign n_trior_tri = co[1] ? 1'bz : co[0];
  port_collapse_internal_wor_in_trior u_trior_tri(n_trior_tri, ci);
  logic [0:4] o_trior_tri, i_trior_tri;

  wor n_wor_wor;
  assign n_wor_wor = co[1] ? 1'bz : co[0];
  port_collapse_internal_wor_in_wor u_wor_wor(n_wor_wor, ci);
  logic [0:4] o_wor_wor, i_wor_wor;

  trior n_wor_trior;
  assign n_wor_trior = co[1] ? 1'bz : co[0];
  port_collapse_internal_wor_in_wor u_wor_trior(n_wor_trior, ci);
  logic [0:4] o_wor_trior, i_wor_trior;

  wor n_trior_wor;
  assign n_trior_wor = co[1] ? 1'bz : co[0];
  port_collapse_internal_wor_in_trior u_trior_wor(n_trior_wor, ci);
  logic [0:4] o_trior_wor, i_trior_wor;

  trior n_trior_trior;
  assign n_trior_trior = co[1] ? 1'bz : co[0];
  port_collapse_internal_wor_in_trior u_trior_trior(n_trior_trior, ci);
  logic [0:4] o_trior_trior, i_trior_trior;

  supply1 n_wor_supply1;
  port_collapse_internal_wor_in_wor u_wor_supply1(n_wor_supply1, ci);
  logic [0:4] o_wor_supply1, i_wor_supply1;

  supply1 n_trior_supply1;
  port_collapse_internal_wor_in_trior u_trior_supply1(n_trior_supply1, ci);
  logic [0:4] o_trior_supply1, i_trior_supply1;

  task automatic sample(int k);
    o_wor_wire[k] = n_wor_wire;
    i_wor_wire[k] = u_wor_wire.w;
    o_wor_tri[k] = n_wor_tri;
    i_wor_tri[k] = u_wor_tri.w;
    o_trior_wire[k] = n_trior_wire;
    i_trior_wire[k] = u_trior_wire.w;
    o_trior_tri[k] = n_trior_tri;
    i_trior_tri[k] = u_trior_tri.w;
    o_wor_wor[k] = n_wor_wor;
    i_wor_wor[k] = u_wor_wor.w;
    o_wor_trior[k] = n_wor_trior;
    i_wor_trior[k] = u_wor_trior.w;
    o_trior_wor[k] = n_trior_wor;
    i_trior_wor[k] = u_trior_wor.w;
    o_trior_trior[k] = n_trior_trior;
    i_trior_trior[k] = u_trior_trior.w;
    o_wor_supply1[k] = n_wor_supply1;
    i_wor_supply1[k] = u_wor_supply1.w;
    o_trior_supply1[k] = n_trior_supply1;
    i_trior_supply1[k] = u_trior_supply1.w;
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
    $display("wor inside, wire outside:        outside %b inside %b",
             o_wor_wire, i_wor_wire);
    $display("wor inside, tri outside:         outside %b inside %b",
             o_wor_tri, i_wor_tri);
    $display("trior inside, wire outside:      outside %b inside %b",
             o_trior_wire, i_trior_wire);
    $display("trior inside, tri outside:       outside %b inside %b",
             o_trior_tri, i_trior_tri);
    $display("wor inside, wor outside:         outside %b inside %b",
             o_wor_wor, i_wor_wor);
    $display("wor inside, trior outside:       outside %b inside %b",
             o_wor_trior, i_wor_trior);
    $display("trior inside, wor outside:       outside %b inside %b",
             o_trior_wor, i_trior_wor);
    $display("trior inside, trior outside:     outside %b inside %b",
             o_trior_trior, i_trior_trior);
    $display("wor inside, supply1 outside:     outside %b inside %b",
             o_wor_supply1, i_wor_supply1);
    $display("trior inside, supply1 outside:   outside %b inside %b",
             o_trior_supply1, i_trior_supply1);
  end
endmodule
