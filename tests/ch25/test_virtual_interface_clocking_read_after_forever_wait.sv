/*
:name: test_virtual_interface_clocking_read_after_forever_wait
:description: A bound virtual interface remains usable after waiting on a clocking event (IEEE 1800-2023 Section 25.9)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.9 14.10 14.13 12.7.6
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_interface_clocking_read_after_forever_wait.expected
:expected_exit: 0
*/
// The class watches the same interface across two rising edges. The input
// bits change away from the clock edges. The two samples in time order are
// 10 and 01, and both must be visible after the corresponding clocking event.

interface sample_bus(input logic clk);
  bit rst_n, sel;
  clocking monitor @(posedge clk);
    input rst_n, sel;
  endclocking
endinterface

module test_virtual_interface_clocking_read_after_forever_wait;
  bit clk;
  always #5 clk = ~clk;
  sample_bus bus(clk);
  class watcher;
    virtual sample_bus vif;
    int samples = 0;
    logic [3:0] history = 0;
    task watch();
      forever begin
        @(vif.monitor);
        history = {history[1:0], vif.monitor.rst_n, vif.monitor.sel};
        samples++;
      end
    endtask
  endclass
  watcher w;

  initial begin
    w = new;
    w.vif = bus;
    w.watch();
  end
  initial begin
    #2 bus.rst_n = 1;
    #10;
    bus.rst_n = 0;
    bus.sel = 1;
    #9;
    $display("CHECK samples=%0d inputs=%b", w.samples, w.history);
    $finish;
  end
endmodule
