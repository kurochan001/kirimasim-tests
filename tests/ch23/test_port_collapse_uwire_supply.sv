/*
:name: test_port_collapse_uwire_supply
:description: A uwire port connected to an outer supply0 or supply1 net, and a supply0 or supply1 port connected to an outer uwire, merge into a supply net, as Table 23-1 selects (IEEE 1800-2023 Section 23.3.3.7)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7 6.6.2 6.6.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_port_collapse_uwire_supply.expected
*/
// IEEE 1800-2023 §23.3.3.7: when a port connects nets of different net
// types, the two nets can become one simulated net, whose type Table 23-1
// selects from the internal net (declared in the module) and the external
// net (in the instantiation). For an internal uwire and an external
// supply0 or supply1 the table selects the external type, and for an
// internal supply0 or supply1 and an external uwire it selects the internal
// type, in these cells without a warning. In both cases the merged net is
// the supply net. A uwire allows at most one driver (§6.6.2); so that the
// design is legal whether or not the supply net counts as one, neither
// side of these ports has a continuous assignment.
// The test runs five phases, written (driver inside, driver outside): (1, 0),
// (0, z), (z, z), (z, 1) and (z, z), and records after each phase the merged
// net seen from outside (the outer net) and from inside (the port, through a
// hierarchical name); both views are the same net and print the same.
// With no driver the codes change nothing: a supply0 or supply1 net has
// the value 0 or 1 (§6.6.6) in every phase, 00000 or 11111, where a
// merged uwire without a driver would be zzzzz.

module port_collapse_uwire_supply_in_uwire(inout uwire w, input logic [1:0] c);
endmodule

module port_collapse_uwire_supply_in_supply0(inout supply0 w, input logic [1:0] c);
endmodule

module port_collapse_uwire_supply_in_supply1(inout supply1 w, input logic [1:0] c);
endmodule

module test_port_collapse_uwire_supply;
  // Codes of the driver inside the port (ci) and outside it (co):
  // 0 drives 0, 1 drives 1, 2 drives z.
  logic [1:0] ci, co;

  supply0 n_uwire_supply0;
  port_collapse_uwire_supply_in_uwire u_uwire_supply0(n_uwire_supply0, ci);
  logic [0:4] o_uwire_supply0, i_uwire_supply0;

  supply1 n_uwire_supply1;
  port_collapse_uwire_supply_in_uwire u_uwire_supply1(n_uwire_supply1, ci);
  logic [0:4] o_uwire_supply1, i_uwire_supply1;

  uwire n_supply0_uwire;
  port_collapse_uwire_supply_in_supply0 u_supply0_uwire(n_supply0_uwire, ci);
  logic [0:4] o_supply0_uwire, i_supply0_uwire;

  uwire n_supply1_uwire;
  port_collapse_uwire_supply_in_supply1 u_supply1_uwire(n_supply1_uwire, ci);
  logic [0:4] o_supply1_uwire, i_supply1_uwire;

  task automatic sample(int k);
    o_uwire_supply0[k] = n_uwire_supply0;
    i_uwire_supply0[k] = u_uwire_supply0.w;
    o_uwire_supply1[k] = n_uwire_supply1;
    i_uwire_supply1[k] = u_uwire_supply1.w;
    o_supply0_uwire[k] = n_supply0_uwire;
    i_supply0_uwire[k] = u_supply0_uwire.w;
    o_supply1_uwire[k] = n_supply1_uwire;
    i_supply1_uwire[k] = u_supply1_uwire.w;
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
    $display("uwire inside, supply0 outside:   outside %b inside %b",
             o_uwire_supply0, i_uwire_supply0);
    $display("uwire inside, supply1 outside:   outside %b inside %b",
             o_uwire_supply1, i_uwire_supply1);
    $display("supply0 inside, uwire outside:   outside %b inside %b",
             o_supply0_uwire, i_supply0_uwire);
    $display("supply1 inside, uwire outside:   outside %b inside %b",
             o_supply1_uwire, i_supply1_uwire);
  end
endmodule
