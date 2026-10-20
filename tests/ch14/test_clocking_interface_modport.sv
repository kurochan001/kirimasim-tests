/*
:name: test_clocking_interface_modport
:description: A clocking block declared in an interface and exported through a modport drives the interface signals that a design reads through another modport (IEEE 1800-2023 Section 14.9)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.9 25.5 14.16 14.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_interface_modport.expected
*/
// IEEE 1800-2023 §14.9, §25.5: the interface declares clocking block cb, and
// modport tb gives the testbench access to it, while modport dut gives the
// design the plain signals. The testbench waits for the clocking block event
// (14.10) and drives through b.cb, so each drive takes effect in the Re-NBA
// region of that clock edge (14.16): the design, which reads data and valid
// at the clock edge, sees the values driven at the previous edge.

interface bus_if (input logic clk);
  logic [7:0] data = 0;
  logic valid = 0;
  clocking cb @(posedge clk);
    output data, valid;
  endclocking
  modport tb (clocking cb);
  modport dut (input clk, input data, input valid);
endinterface

module bus_dut (bus_if.dut b);
  always @(posedge b.clk)
    if (b.valid) $display("t=%0d: dut got %0d", $time, b.data);
endmodule

module bus_tb (bus_if.tb b);
  initial begin
    @(b.cb);             // 5
    b.cb.data <= 8'd11;
    b.cb.valid <= 1;
    @(b.cb);             // 15
    b.cb.data <= 8'd22;
    @(b.cb);             // 25
    b.cb.valid <= 0;
    @(b.cb);             // 35
    $finish;
  end
endmodule

module test_clocking_interface_modport;
  logic clk = 0;

  always #5 clk = ~clk;

  bus_if bus (clk);
  bus_dut d (bus.dut);
  bus_tb t (bus.tb);
endmodule
