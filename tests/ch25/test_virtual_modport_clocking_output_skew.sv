/*
:name: test_virtual_modport_clocking_output_skew
:description: A virtual modport exposing a clocking block respects output skew before and after its drive time (IEEE 1800-2023 Section 25.5.5)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.5.5 25.9.1 14.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_modport_clocking_output_skew.expected
*/
// IEEE 1800-2023 25.5.5 25.9.1 14.16: The interface owns the initial value; the
// virtual modport drive is observed once before and once after the declared
// output delay.
// Oracle checks: Icarus Verilog 13.0 does not build this case.

`timescale 1ns/1ns
interface timed_bus(input bit clk);
  logic value = 0;
  clocking cb @(posedge clk); output #2 value; endclocking
  modport driver(clocking cb);
endinterface
module test_virtual_modport_clocking_output_skew;
  bit clk;
  timed_bus bus(clk);
  virtual timed_bus.driver handle;
  always #5 clk = ~clk;
  initial begin
    handle = bus;
    @(handle.cb); handle.cb.value <= 1;
    #1 $display("before_skew=%b", bus.value);
    #2 $display("after_skew=%b", bus.value);
    $finish;
  end
endmodule
