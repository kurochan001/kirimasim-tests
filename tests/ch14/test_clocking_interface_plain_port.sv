/*
:name: test_clocking_interface_plain_port
:description: A clocking block declared in an interface drives and samples through an interface port that is not a modport, and the design on the other side sees a drive at the next clock edge (IEEE 1800-2023 Section 14.9)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.9 14.13 14.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_interface_plain_port.expected
*/
// IEEE 1800-2023 §14.9: an interface can declare clocking blocks, and a module
// whose port is the interface reaches them as port.cb, without a modport.
// §14.16: a drive through an output clockvar matures at the clocking event, so
// the design that reads the interface signal at the next rising edge sees the
// value driven at the previous one. §14.13: an input clockvar returns the
// value sampled at the last clocking event; ack is set at 25 and sampled at
// 35, after the design has changed it again in the same step.

`timescale 1ns/1ns

interface plain_bus_if (input logic clk);
  logic [7:0] data = 0;
  logic ack = 0;

  clocking cb @(posedge clk);
    output data;
    input ack;
  endclocking
endinterface

module plain_bus_dut (plain_bus_if b);
  always @(posedge b.clk)
    if (b.data != 0) $display("dut t=%0t data=%0d", $time, b.data);

  always @(posedge b.clk)
    b.ack <= (b.data == 8'd22);
endmodule

module plain_bus_tb (plain_bus_if b);
  initial begin
    @(b.cb);                       // 5
    b.cb.data <= 8'd11;
    @(b.cb);                       // 15
    b.cb.data <= 8'd22;
    @(b.cb);                       // 25
    b.cb.data <= 8'd33;
    @(b.cb);                       // 35
    #1 $display("tb t=%0t ack=%b", $time, b.cb.ack);
    $finish;
  end
endmodule

module test_clocking_interface_plain_port;
  logic clk = 0;

  always #5 clk = ~clk;

  plain_bus_if bus (clk);
  plain_bus_dut d (bus);
  plain_bus_tb t (bus);
endmodule
