/*
:name: test_clocking_output_uses_shadowing_task_local_handle
:description: Synchronous clocking drive uses the task-local handle (IEEE 1800-2023 Section 14.16)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.16 25.9.1 6.21
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_output_uses_shadowing_task_local_handle.expected
:expected_exit: 0
*/
// A task-local handle shadows an inherited property. After a clocking
// event, the drive uses the local packet, which contains 1.

interface bus_if #(int W = 8) (input var bit clk);
  bit write;
  clocking cb @(posedge clk);
    output write;
  endclocking
endinterface

module test_clocking_output_uses_shadowing_task_local_handle;
  bit clk;
  always #5 clk = !clk;
  bus_if bus(clk);

  class packet;
    bit write;
  endclass

  class base_driver;
    packet req = new;
  endclass

  class driver #(int W = 8) extends base_driver;
    virtual bus_if #(W) vif;
    task drive(packet item);
      packet req = item;
      @(vif.cb);
      vif.cb.write <= req.write;
    endtask
  endclass

  initial begin
    automatic driver #(8) drv = new;
    automatic packet item = new;
    item.write = 1;
    drv.vif = bus;
    drv.drive(item);
    #1;
    $display("CHECK write=%0d", bus.write);
    if (bus.write != 1) $fatal(1, "clocking drive used the hidden property");
    $display("CHECK pass");
    $finish;
  end
endmodule
