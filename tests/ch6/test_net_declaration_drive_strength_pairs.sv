/*
:name: test_net_declaration_drive_strength_pairs
:description: Net declaration assignments take a drive strength of a 0 and a 1 strength from supply, strong, pull, weak or highz in either order, and every bit of a vector net carries its own four-state value and strength (IEEE 1800-2023 Section 6.7)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.7 6.7.1 10.3.4 28.12 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_declaration_drive_strength_pairs.expected
*/
// IEEE 1800-2023 §6.7: a drive strength names a strength for 0, from supply0,
// strong0, pull0 and weak0, and one for 1, from supply1, strong1, pull1 and
// weak1, in either order; one of them can instead be highz, and the driver
// then gives z for that value (10.3.4). §6.7.1: a net is made of 4-state bits,
// each with its own strength, which combine by 28.12.
// Each of the eight scalar nets has a declaration assignment from d with one
// of the strength forms; %v (21.2.1.4) shows them for d = 1 and d = 0. The
// vector net vec has a weak driver of 4'b1000 on all bits and a strong driver
// of 2'bx1 on its two low bits: bit 3 and bit 2 keep the weak values, bit 1
// gets the strong x, which covers the weak 0, and bit 0 the strong 1.

module test_net_declaration_drive_strength_pairs;
  logic d = 1'b1;
  wire (supply0, supply1) n_su = d;
  wire (strong1, strong0) n_st = d;
  wire (pull0, pull1) n_pu = d;
  wire (weak1, weak0) n_we = d;
  wire (strong0, highz1) n_0z = d;
  wire (highz0, weak1) n_z1 = d;
  wire (pull1, highz0) n_1z = d;
  wire (highz1, supply0) n_z0 = d;
  wire [3:0] vec;

  assign (weak0, weak1) vec = 4'b1000;
  assign (strong0, strong1) vec[1:0] = 2'bx1;

  task automatic show();
    $display("d=%b: %v %v %v %v | %v %v %v %v", d, n_su, n_st, n_pu, n_we, n_0z, n_z1, n_1z,
             n_z0);
  endtask

  initial begin
    #1 show();
    d = 1'b0;
    #1 show();
    $display("vec=%b bits: %v %v %v %v", vec, vec[3], vec[2], vec[1], vec[0]);
  end
endmodule
