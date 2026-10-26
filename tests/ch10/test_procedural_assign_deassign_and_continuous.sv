/*
:name: test_procedural_assign_deassign_and_continuous
:description: A continuous assignment outside any procedure stays active for the whole simulation, and a procedural assign overrides every procedural assignment to its variable until a deassign ends it, following the right-hand side while it is in effect and leaving its last value in place after the deassign (IEEE 1800-2023 Sections 10.6 and 10.6.1, C.4.2)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6 10.6.1 C.4.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_procedural_assign_deassign_and_continuous.expected
*/
// IEEE 1800-2023 §10.6: the right-hand side of an assign procedural
// continuous assignment is treated as a continuous assignment, so the
// variable follows it while it is in effect, and §10.6.1: an assign overrides
// all procedural assignments to its variable, a deassign ends it and the
// variable keeps the value it had until a procedural assignment gives it a
// new one, and a second assign to the same variable deassigns it first.
// C.4.2: the current standard still requires tools to support the procedural
// assign and deassign statements, and a continuous assignment placed outside
// any procedure is a separate process that is active throughout simulation.
//
// y follows d through a continuous assignment at every time step, not only at
// time zero. x is driven by procedural assignments and then by assign x = d,
// which follows d while a later procedural assignment to x is ignored;
// deassign leaves the last value, and the second assign replaces the first.
// force and release, which C.4.2 names as another way to model the same
// behavior, are applied to a constant and leave the forced value after the
// release.

module test_procedural_assign_deassign_and_continuous;
  logic [7:0] d = 8'h00;
  logic [7:0] y;
  logic [7:0] x;

  assign y = d;

  initial begin
    x = 8'h11;
    #1 x = 8'h22;
    #1 assign x = d;
    #1 d = 8'h33;
    #1 x = 8'h44;
    #1 $display("x %02h y %02h", x, y);
    #1 deassign x;
    #1 $display("x %02h y %02h", x, y);
    #1 x = 8'h55;
    #1 $display("x %02h y %02h", x, y);
    #1 assign x = 8'h66;
    #1 assign x = d;
    #1 d = 8'h77;
    #1 $display("x %02h y %02h", x, y);
    #1 deassign x;
    #1 force x = 8'h88;
    #1 x = 8'h99;
    #1 d = 8'h00;
    #1 $display("x %02h y %02h", x, y);
    #1 release x;
    #1 $display("x %02h y %02h", x, y);
    #1 x = 8'haa;
    #1 $display("last x %02h y %02h", x, y);
    $finish;
  end
endmodule
