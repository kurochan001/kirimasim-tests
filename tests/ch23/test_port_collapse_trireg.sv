/*
:name: test_port_collapse_trireg
:description: Port connections between a trireg and a wire, tri, trireg, tri0, tri1, supply0 or supply1 merge into the net type that Table 23-1 selects for each of these cells, which have no warning (IEEE 1800-2023 Section 23.3.3.7)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7 6.6.1 6.6.4 6.6.5 6.6.6
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_port_collapse_trireg.expected
*/
// IEEE 1800-2023 §23.3.3.7: when a port connects nets of different net
// types, the two nets can become one simulated net, whose type Table 23-1
// selects from the internal net (declared in the module) and the external
// net (in the instantiation). The cells of the table that pair a trireg
// with another type and have no warning are these: a wire or tri inside
// with a trireg outside gives the external trireg; a trireg inside gives
// the internal trireg with a wire or tri outside, and the external type
// with a trireg, tri0, tri1, supply0 or supply1 outside; a tri0, tri1,
// supply0 or supply1 inside with a trireg outside gives the internal type.
// Each instance below connects an inout port to an outer net for one of
// these cells. The port has a continuous assignment inside the module and
// the outer net one outside, except supply nets, which have no driver.
// The test runs five phases, written (driver inside, driver outside): (1, 0),
// (0, z), (z, z), (z, 1) and (z, z), and records after each phase the merged
// net seen from outside (the outer net) and from inside (the port, through a
// hierarchical name); both views are the same net and print the same.
// A trireg keeps its last driven value when all its drivers are z (§6.6.4)
// and starts at x, so it gives x0011; a tri0 or tri1 gives x0010 or x0111
// (§6.6.5) and a wire or tri x0z1z (§6.6.1). A supply0 or supply1 net
// (§6.6.6) is 00000 or 11111 whatever its other driver does, where a
// trireg would give 10000 with the driver inside and 00011 with the
// driver outside. Icarus Verilog 13.0 and Verilator 5.052 do not support
// trireg nets, so this expected output follows the standard alone.

module port_collapse_trireg_in_wire(inout wire w, input logic [1:0] c);
  assign w = c[1] ? 1'bz : c[0];
endmodule

module port_collapse_trireg_in_tri(inout tri w, input logic [1:0] c);
  assign w = c[1] ? 1'bz : c[0];
endmodule

module port_collapse_trireg_in_trireg(inout trireg w, input logic [1:0] c);
  assign w = c[1] ? 1'bz : c[0];
endmodule

module port_collapse_trireg_in_tri0(inout tri0 w, input logic [1:0] c);
  assign w = c[1] ? 1'bz : c[0];
endmodule

module port_collapse_trireg_in_tri1(inout tri1 w, input logic [1:0] c);
  assign w = c[1] ? 1'bz : c[0];
endmodule

module port_collapse_trireg_in_supply0(inout supply0 w, input logic [1:0] c);
endmodule

module port_collapse_trireg_in_supply1(inout supply1 w, input logic [1:0] c);
endmodule

module test_port_collapse_trireg;
  // Codes of the driver inside the port (ci) and outside it (co):
  // 0 drives 0, 1 drives 1, 2 drives z.
  logic [1:0] ci, co;

  trireg n_wire_trireg;
  assign n_wire_trireg = co[1] ? 1'bz : co[0];
  port_collapse_trireg_in_wire u_wire_trireg(n_wire_trireg, ci);
  logic [0:4] o_wire_trireg, i_wire_trireg;

  trireg n_tri_trireg;
  assign n_tri_trireg = co[1] ? 1'bz : co[0];
  port_collapse_trireg_in_tri u_tri_trireg(n_tri_trireg, ci);
  logic [0:4] o_tri_trireg, i_tri_trireg;

  wire n_trireg_wire;
  assign n_trireg_wire = co[1] ? 1'bz : co[0];
  port_collapse_trireg_in_trireg u_trireg_wire(n_trireg_wire, ci);
  logic [0:4] o_trireg_wire, i_trireg_wire;

  tri n_trireg_tri;
  assign n_trireg_tri = co[1] ? 1'bz : co[0];
  port_collapse_trireg_in_trireg u_trireg_tri(n_trireg_tri, ci);
  logic [0:4] o_trireg_tri, i_trireg_tri;

  trireg n_trireg_trireg;
  assign n_trireg_trireg = co[1] ? 1'bz : co[0];
  port_collapse_trireg_in_trireg u_trireg_trireg(n_trireg_trireg, ci);
  logic [0:4] o_trireg_trireg, i_trireg_trireg;

  tri0 n_trireg_tri0;
  assign n_trireg_tri0 = co[1] ? 1'bz : co[0];
  port_collapse_trireg_in_trireg u_trireg_tri0(n_trireg_tri0, ci);
  logic [0:4] o_trireg_tri0, i_trireg_tri0;

  tri1 n_trireg_tri1;
  assign n_trireg_tri1 = co[1] ? 1'bz : co[0];
  port_collapse_trireg_in_trireg u_trireg_tri1(n_trireg_tri1, ci);
  logic [0:4] o_trireg_tri1, i_trireg_tri1;

  supply0 n_trireg_supply0;
  port_collapse_trireg_in_trireg u_trireg_supply0(n_trireg_supply0, ci);
  logic [0:4] o_trireg_supply0, i_trireg_supply0;

  supply1 n_trireg_supply1;
  port_collapse_trireg_in_trireg u_trireg_supply1(n_trireg_supply1, ci);
  logic [0:4] o_trireg_supply1, i_trireg_supply1;

  trireg n_tri0_trireg;
  assign n_tri0_trireg = co[1] ? 1'bz : co[0];
  port_collapse_trireg_in_tri0 u_tri0_trireg(n_tri0_trireg, ci);
  logic [0:4] o_tri0_trireg, i_tri0_trireg;

  trireg n_tri1_trireg;
  assign n_tri1_trireg = co[1] ? 1'bz : co[0];
  port_collapse_trireg_in_tri1 u_tri1_trireg(n_tri1_trireg, ci);
  logic [0:4] o_tri1_trireg, i_tri1_trireg;

  trireg n_supply0_trireg;
  assign n_supply0_trireg = co[1] ? 1'bz : co[0];
  port_collapse_trireg_in_supply0 u_supply0_trireg(n_supply0_trireg, ci);
  logic [0:4] o_supply0_trireg, i_supply0_trireg;

  trireg n_supply1_trireg;
  assign n_supply1_trireg = co[1] ? 1'bz : co[0];
  port_collapse_trireg_in_supply1 u_supply1_trireg(n_supply1_trireg, ci);
  logic [0:4] o_supply1_trireg, i_supply1_trireg;

  task automatic sample(int k);
    o_wire_trireg[k] = n_wire_trireg;
    i_wire_trireg[k] = u_wire_trireg.w;
    o_tri_trireg[k] = n_tri_trireg;
    i_tri_trireg[k] = u_tri_trireg.w;
    o_trireg_wire[k] = n_trireg_wire;
    i_trireg_wire[k] = u_trireg_wire.w;
    o_trireg_tri[k] = n_trireg_tri;
    i_trireg_tri[k] = u_trireg_tri.w;
    o_trireg_trireg[k] = n_trireg_trireg;
    i_trireg_trireg[k] = u_trireg_trireg.w;
    o_trireg_tri0[k] = n_trireg_tri0;
    i_trireg_tri0[k] = u_trireg_tri0.w;
    o_trireg_tri1[k] = n_trireg_tri1;
    i_trireg_tri1[k] = u_trireg_tri1.w;
    o_trireg_supply0[k] = n_trireg_supply0;
    i_trireg_supply0[k] = u_trireg_supply0.w;
    o_trireg_supply1[k] = n_trireg_supply1;
    i_trireg_supply1[k] = u_trireg_supply1.w;
    o_tri0_trireg[k] = n_tri0_trireg;
    i_tri0_trireg[k] = u_tri0_trireg.w;
    o_tri1_trireg[k] = n_tri1_trireg;
    i_tri1_trireg[k] = u_tri1_trireg.w;
    o_supply0_trireg[k] = n_supply0_trireg;
    i_supply0_trireg[k] = u_supply0_trireg.w;
    o_supply1_trireg[k] = n_supply1_trireg;
    i_supply1_trireg[k] = u_supply1_trireg.w;
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
    $display("wire inside, trireg outside:     outside %b inside %b",
             o_wire_trireg, i_wire_trireg);
    $display("tri inside, trireg outside:      outside %b inside %b",
             o_tri_trireg, i_tri_trireg);
    $display("trireg inside, wire outside:     outside %b inside %b",
             o_trireg_wire, i_trireg_wire);
    $display("trireg inside, tri outside:      outside %b inside %b",
             o_trireg_tri, i_trireg_tri);
    $display("trireg inside, trireg outside:   outside %b inside %b",
             o_trireg_trireg, i_trireg_trireg);
    $display("trireg inside, tri0 outside:     outside %b inside %b",
             o_trireg_tri0, i_trireg_tri0);
    $display("trireg inside, tri1 outside:     outside %b inside %b",
             o_trireg_tri1, i_trireg_tri1);
    $display("trireg inside, supply0 outside:  outside %b inside %b",
             o_trireg_supply0, i_trireg_supply0);
    $display("trireg inside, supply1 outside:  outside %b inside %b",
             o_trireg_supply1, i_trireg_supply1);
    $display("tri0 inside, trireg outside:     outside %b inside %b",
             o_tri0_trireg, i_tri0_trireg);
    $display("tri1 inside, trireg outside:     outside %b inside %b",
             o_tri1_trireg, i_tri1_trireg);
    $display("supply0 inside, trireg outside:  outside %b inside %b",
             o_supply0_trireg, i_supply0_trireg);
    $display("supply1 inside, trireg outside:  outside %b inside %b",
             o_supply1_trireg, i_supply1_trireg);
  end
endmodule
