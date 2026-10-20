/*
:name: test_modport_clocking_block
:description: A modport can list a clocking block of its interface, so the module that has the modport as its port drives the clocking outputs and samples the clocking inputs through it (IEEE 1800-2023 Section 25.5.5)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.5.5 14.13 14.16 25.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_modport_clocking_block.expected
*/
// IEEE 1800-2023 §25.5.5: a modport can name a clocking block of the
// interface; its directions are those seen from the module whose port the
// modport is. The tb modport gives only the clocking block cb, through which
// the tester drives data (14.16) and samples ack (14.13); the dut modport
// gives the plain signals. The tester drives 5a after the first rising edge
// of clk; the device answers with ack at a later edge, and the tester reads
// ack through cb at the fourth edge, at 35, by when it is 1 whichever edge the
// drive took effect at. The test prints nothing at the edges in between.

`timescale 1ns/1ns

interface test_modport_clocking_block_if (input logic clk);
  logic [7:0] data = 0;
  logic ack = 0;

  clocking cb @(posedge clk);
    output data;
    input ack;
  endclocking

  modport tb (clocking cb);
  modport dut (input clk, input data, output ack);
endinterface

module test_modport_clocking_block_dut (test_modport_clocking_block_if.dut b);
  always @(posedge b.clk) b.ack <= (b.data == 8'h5a);
endmodule

module test_modport_clocking_block_tester (test_modport_clocking_block_if.tb b);
  initial begin
    @(b.cb);
    b.cb.data <= 8'h5a;
    repeat (3) @(b.cb);
    $display("t=%0t: ack through the clocking block: %b", $time, b.cb.ack);
  end
endmodule

module test_modport_clocking_block;
  logic clk = 0;

  always #5 clk = ~clk;

  test_modport_clocking_block_if b(clk);
  test_modport_clocking_block_dut d(b);
  test_modport_clocking_block_tester t(b);

  initial begin
    #36 $display("data on the bus: %h", b.data);
    $finish;
  end
endmodule
