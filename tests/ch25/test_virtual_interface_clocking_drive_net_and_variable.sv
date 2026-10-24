/*
:name: test_virtual_interface_clocking_drive_net_and_variable
:description: through a virtual interface whose modport lists a clocking block, synchronous drives of the clocking block assign both a net and a variable of the interface (IEEE 1800-2023 Section 25.9.1)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.9.1 25.9.2 14.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_interface_clocking_drive_net_and_variable.expected
*/
// IEEE 1800-2023 §25.9.1: clocking blocks give a procedural way to assign
// both nets and variables of an interface through a virtual interface.
// §25.9.2: a modport makes a clocking block of the interface available by
// listing it. §14.16: a synchronous drive of a clocking block output with
// the default output skew 0, made right after its clocking event, takes
// effect in that time step.
// Interface cv_if has the net n and the variable v, both outputs of the
// clocking block cb, which the modport tb lists. The test reaches the
// interface through vif, a virtual interface of type cv_if.tb, waits for
// the clocking event at 5 and drives n and v through vif.cb, then does the
// same with other values at 15. Both are printed 2 units after each drive.

`timescale 1ns/1ns

interface cv_if (input logic clk);
  wire [3:0] n;
  logic [3:0] v;
  clocking cb @(posedge clk);
    output n, v;
  endclocking
  modport tb (clocking cb);
endinterface

module test_virtual_interface_clocking_drive_net_and_variable;
  logic clk = 0;
  cv_if bus (clk);
  virtual cv_if.tb vif;

  always #5 clk = ~clk;

  initial begin
    vif = bus;
    @(vif.cb);
    vif.cb.n <= 4'h3;
    vif.cb.v <= 4'h5;
    @(vif.cb);
    vif.cb.n <= 4'ha;
    vif.cb.v <= 4'hc;
  end

  initial begin
    #7 $display("t=%0t n=%h v=%h", $time, bus.n, bus.v);
    #10 $display("t=%0t n=%h v=%h", $time, bus.n, bus.v);
    $finish;
  end
endmodule
