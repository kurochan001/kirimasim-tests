/*
:name: test_sv_virtual_if
:description: Test: Virtual interface: interface declaration, virtual interface variable,
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.9
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sv_virtual_if.expected
*/
// Test: Virtual interface: interface declaration, virtual interface variable,
//       reading and writing signals through virtual interface
interface simple_bus;
  logic [7:0] data;
  logic       valid;
  logic       ready;
endinterface

module test_sv_virtual_if;

  reg clk = 0;
  always #5 clk = ~clk;

  simple_bus bus_inst();

  class BusDriver;
    virtual simple_bus vif;

    function new(virtual simple_bus v);
      vif = v;
    endfunction

    task drive(input logic [7:0] d, input logic v);
      vif.data  = d;
      vif.valid = v;
    endtask

    function logic [7:0] read_data();
      return vif.data;
    endfunction

    function logic read_ready();
      return vif.ready;
    endfunction
  endclass

  initial begin
    static int pass_cnt = 0;
    static int fail_cnt = 0;
    BusDriver drv;

    // Check 1: virtual interface passed to class
    drv = new(bus_inst);
    if (drv.vif != null) begin pass_cnt++; $display("PASS: vif assigned via class"); end
    else begin fail_cnt++; $display("FAIL: vif is null"); end

    // Check 2: drive data through class method using vif
    drv.drive(8'hA5, 1'b1);
    #1;
    if (drv.read_data() == 8'hA5) begin pass_cnt++; $display("PASS: drive data == 0xA5"); end
    else begin fail_cnt++; $display("FAIL: data = 0x%0h", drv.read_data()); end

    // Check 3: read ready signal set on actual instance
    bus_inst.ready = 1'b1;
    #1;
    if (drv.read_ready() == 1'b1) begin pass_cnt++; $display("PASS: read ready == 1"); end
    else begin fail_cnt++; $display("FAIL: ready = %b", drv.read_ready()); end

    // Check 4: update data and re-read
    drv.drive(8'h3C, 1'b0);
    #1;
    if (drv.read_data() == 8'h3C) begin pass_cnt++; $display("PASS: updated data == 0x3C"); end
    else begin fail_cnt++; $display("FAIL: data = 0x%0h", drv.read_data()); end

    // Check 5: drive across clock edge
    @(posedge clk);
    drv.drive(8'hFF, 1'b1);
    @(posedge clk);
    if (drv.read_data() == 8'hFF) begin pass_cnt++; $display("PASS: clocked drive data == 0xFF"); end
    else begin fail_cnt++; $display("FAIL: data = 0x%0h", drv.read_data()); end

    // Check 6: two drivers share same interface instance
    begin
      BusDriver drv2;
      drv2 = new(bus_inst);
      drv2.drive(8'h42, 1'b0);
      #1;
      if (drv.read_data() == 8'h42) begin pass_cnt++; $display("PASS: two drivers share instance"); end
      else begin fail_cnt++; $display("FAIL: data = 0x%0h", drv.read_data()); end
    end

    // Check 7: valid signal readback
    drv.drive(8'h00, 1'b1);
    #1;
    if (bus_inst.valid == 1'b1) begin pass_cnt++; $display("PASS: valid readback on instance == 1"); end
    else begin fail_cnt++; $display("FAIL: bus_inst.valid = %b", bus_inst.valid); end

    $display("Results: %0d passed, %0d failed", pass_cnt, fail_cnt);
    if (fail_cnt == 0) $display("TEST PASSED"); else $display("TEST FAILED");
    $finish;
  end

endmodule
