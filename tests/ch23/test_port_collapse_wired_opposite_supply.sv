/*
:name: test_port_collapse_wired_opposite_supply
:description: A wand or triand connected through a port to a supply1, and a wor or trior connected to a supply0, merge into the supply net that Table 23-1 selects, whose value does not follow the wired logic of the other net (IEEE 1800-2023 Section 23.3.3.7)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7 6.6.3 6.6.6
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_port_collapse_wired_opposite_supply.expected
*/
// IEEE 1800-2023 §23.3.3.7: when a port connects nets of different net
// types, the two nets can become one simulated net, whose type Table 23-1
// selects from the internal net (declared in the module) and the external
// net (in the instantiation). For an internal wand or triand and an
// external supply1, or an internal wor or trior and an external supply0,
// the table selects the external supply net; for an internal supply0 and
// an external wor or trior, or an internal supply1 and an external wand or
// triand, it selects the internal supply net; none of these cells has a
// warning. The supply net has no driver; the wired net has a continuous
// assignment on its side of the port.
// The test runs five phases, written (driver inside, driver outside): (1, 0),
// (0, z), (z, z), (z, 1) and (z, z), and records after each phase the merged
// net seen from outside (the outer net) and from inside (the port, through a
// hierarchical name); both views are the same net and print the same.
// A driver inside the port drives 1, 0, z, z and z; a driver outside it
// drives 0, z, z, 1 and z. A supply0 or supply1 net has supply strength
// (§6.6.6), so the merged net is 00000 or 11111 whatever the other driver
// does. A merged net that stayed a wand or wor and combined the supply
// value with the driver by its wired function (§6.6.3) would follow the
// driver whenever it drives the value opposite to the supply. Icarus
// Verilog 13.0 does so and prints 10111, 10000, 00010 and 01111 for the
// four kinds of cell, where the standard requires the supply value.

module port_collapse_wired_opposite_supply_in_wand(inout wand w, input logic [1:0] c);
  assign w = c[1] ? 1'bz : c[0];
endmodule

module port_collapse_wired_opposite_supply_in_triand(inout triand w, input logic [1:0] c);
  assign w = c[1] ? 1'bz : c[0];
endmodule

module port_collapse_wired_opposite_supply_in_wor(inout wor w, input logic [1:0] c);
  assign w = c[1] ? 1'bz : c[0];
endmodule

module port_collapse_wired_opposite_supply_in_trior(inout trior w, input logic [1:0] c);
  assign w = c[1] ? 1'bz : c[0];
endmodule

module port_collapse_wired_opposite_supply_in_supply0(inout supply0 w, input logic [1:0] c);
endmodule

module port_collapse_wired_opposite_supply_in_supply1(inout supply1 w, input logic [1:0] c);
endmodule

module test_port_collapse_wired_opposite_supply;
  // Codes of the driver inside the port (ci) and outside it (co):
  // 0 drives 0, 1 drives 1, 2 drives z.
  logic [1:0] ci, co;

  supply1 n_wand_supply1;
  port_collapse_wired_opposite_supply_in_wand u_wand_supply1(n_wand_supply1, ci);
  logic [0:4] o_wand_supply1, i_wand_supply1;

  supply1 n_triand_supply1;
  port_collapse_wired_opposite_supply_in_triand u_triand_supply1(n_triand_supply1, ci);
  logic [0:4] o_triand_supply1, i_triand_supply1;

  supply0 n_wor_supply0;
  port_collapse_wired_opposite_supply_in_wor u_wor_supply0(n_wor_supply0, ci);
  logic [0:4] o_wor_supply0, i_wor_supply0;

  supply0 n_trior_supply0;
  port_collapse_wired_opposite_supply_in_trior u_trior_supply0(n_trior_supply0, ci);
  logic [0:4] o_trior_supply0, i_trior_supply0;

  wor n_supply0_wor;
  assign n_supply0_wor = co[1] ? 1'bz : co[0];
  port_collapse_wired_opposite_supply_in_supply0 u_supply0_wor(n_supply0_wor, ci);
  logic [0:4] o_supply0_wor, i_supply0_wor;

  trior n_supply0_trior;
  assign n_supply0_trior = co[1] ? 1'bz : co[0];
  port_collapse_wired_opposite_supply_in_supply0 u_supply0_trior(n_supply0_trior, ci);
  logic [0:4] o_supply0_trior, i_supply0_trior;

  wand n_supply1_wand;
  assign n_supply1_wand = co[1] ? 1'bz : co[0];
  port_collapse_wired_opposite_supply_in_supply1 u_supply1_wand(n_supply1_wand, ci);
  logic [0:4] o_supply1_wand, i_supply1_wand;

  triand n_supply1_triand;
  assign n_supply1_triand = co[1] ? 1'bz : co[0];
  port_collapse_wired_opposite_supply_in_supply1 u_supply1_triand(n_supply1_triand, ci);
  logic [0:4] o_supply1_triand, i_supply1_triand;

  task automatic sample(int k);
    o_wand_supply1[k] = n_wand_supply1;
    i_wand_supply1[k] = u_wand_supply1.w;
    o_triand_supply1[k] = n_triand_supply1;
    i_triand_supply1[k] = u_triand_supply1.w;
    o_wor_supply0[k] = n_wor_supply0;
    i_wor_supply0[k] = u_wor_supply0.w;
    o_trior_supply0[k] = n_trior_supply0;
    i_trior_supply0[k] = u_trior_supply0.w;
    o_supply0_wor[k] = n_supply0_wor;
    i_supply0_wor[k] = u_supply0_wor.w;
    o_supply0_trior[k] = n_supply0_trior;
    i_supply0_trior[k] = u_supply0_trior.w;
    o_supply1_wand[k] = n_supply1_wand;
    i_supply1_wand[k] = u_supply1_wand.w;
    o_supply1_triand[k] = n_supply1_triand;
    i_supply1_triand[k] = u_supply1_triand.w;
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
    $display("wand inside, supply1 outside:    outside %b inside %b",
             o_wand_supply1, i_wand_supply1);
    $display("triand inside, supply1 outside:  outside %b inside %b",
             o_triand_supply1, i_triand_supply1);
    $display("wor inside, supply0 outside:     outside %b inside %b",
             o_wor_supply0, i_wor_supply0);
    $display("trior inside, supply0 outside:   outside %b inside %b",
             o_trior_supply0, i_trior_supply0);
    $display("supply0 inside, wor outside:     outside %b inside %b",
             o_supply0_wor, i_supply0_wor);
    $display("supply0 inside, trior outside:   outside %b inside %b",
             o_supply0_trior, i_supply0_trior);
    $display("supply1 inside, wand outside:    outside %b inside %b",
             o_supply1_wand, i_supply1_wand);
    $display("supply1 inside, triand outside:  outside %b inside %b",
             o_supply1_triand, i_supply1_triand);
  end
endmodule
