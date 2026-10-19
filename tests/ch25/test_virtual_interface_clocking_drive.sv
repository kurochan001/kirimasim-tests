/*
:name: test_virtual_interface_clocking_drive
:description: A class drives a clocking block output through a virtual interface with a modport that exports the clocking block; the drive waits for the clocking event and the signal changes after the output skew (IEEE 1800-2023 Sections 25.9, 25.5 and 14.16)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.9 25.5 14.16 14.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_interface_clocking_drive.expected
*/
// IEEE 1800-2023 §25.9: a class reaches an interface instance through a
// virtual interface, here restricted to the modport drv, which exports the
// clocking block cb (25.5). The driver waits for the clocking event with
// @(vif.cb) and then drives vif.cb.data. §14.16: the drive takes effect at
// that clocking event as modified by the output skew, 2 here (14.3), so data
// changes 2 after the rising edges at 5 and 15.

`timescale 1ns/1ns

interface vc_if(input logic clk);
  logic [7:0] data;
  clocking cb @(posedge clk);
    output #2 data;
  endclocking
  modport drv (clocking cb);
endinterface

class vc_driver;
  virtual vc_if.drv vif;

  function new(virtual vc_if.drv v);
    vif = v;
  endfunction

  task drive(logic [7:0] d);
    @(vif.cb);
    vif.cb.data <= d;
  endtask
endclass

module test_virtual_interface_clocking_drive;
  logic clk = 0;
  vc_if bif(clk);
  vc_driver drv;

  always #5 clk = ~clk;   // rising edges at 5, 15, 25

  // A two-state simulator may give data a random value at time 0; only the
  // drives are of interest.
  always @(bif.data) if ($time > 0) $display("%0d: data = %h", $time, bif.data);

  initial begin
    drv = new(bif.drv);
    drv.drive(8'h5a);
    drv.drive(8'ha5);
    #10 $finish;
  end
endmodule
