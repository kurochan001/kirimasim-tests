/*
:name: test_virtual_interface_clocking_block
:description: A task that takes a virtual interface drives the signals of whichever interface instance it is given through that instance's clocking block (IEEE 1800-2023 Section 25.9.1)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.9.1 25.9 14.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_interface_clocking_block.expected
*/
// IEEE 1800-2023 §25.9.1: clocking blocks in an interface can be used
// through a virtual interface, so one task drives any instance synchronously.
// put drives v through the clocking block cb of the instance it gets (14.16).
// The array of virtual interfaces holds s0 and s1; after the first rising edge
// of clk, at 5, s1 gets 9 and s0 gets 3. The values are printed at 17, after
// the next edge, when the drives have taken effect at either edge.

`timescale 1ns/1ns

interface test_virtual_interface_clocking_block_if (input logic clk);
  logic [3:0] v = 0;

  clocking cb @(posedge clk);
    output v;
  endclocking
endinterface

module test_virtual_interface_clocking_block;
  logic clk = 0;
  virtual test_virtual_interface_clocking_block_if vis [2];

  always #5 clk = ~clk;

  test_virtual_interface_clocking_block_if s0(clk), s1(clk);

  task automatic put(virtual test_virtual_interface_clocking_block_if vi, logic [3:0] x);
    vi.cb.v <= x;
  endtask

  initial begin
    vis = '{s0, s1};
    @(posedge clk);
    put(vis[1], 4'h9);
    put(vis[0], 4'h3);
    #12 $display("t=%0t: s0.v=%h s1.v=%h", $time, s0.v, s1.v);
    $finish;
  end
endmodule
