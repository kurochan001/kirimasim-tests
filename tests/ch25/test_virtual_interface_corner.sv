/*
:name: test_virtual_interface_corner
:description: Tests virtual interface assignment, null checks, and dynamic binding
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.9 25.5
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_interface_corner.expected
*/
// Tests virtual interface assignment, null checks, and dynamic binding
`timescale 1ns/1ps

interface simple_if;
    logic clk;
    logic [7:0] data;
    logic valid;

    modport driver (
        input clk,
        output data, valid
    );

    modport monitor (
        input clk, data, valid
    );
endinterface

module test_virtual_interface_corner;
    int pass_count = 0;
    int fail_count = 0;

    logic clk = 0;
    always #5 clk = ~clk;

    // Interface instances
    simple_if if1();
    simple_if if2();

    assign if1.clk = clk;
    assign if2.clk = clk;

    // Test 1: Basic virtual interface assignment
    task test_basic_vif();
        virtual simple_if vif;
        vif = if1;

        vif.data = 8'hAB;
        vif.valid = 1;
        @(posedge clk);

        if (if1.data == 8'hAB && if1.valid == 1) begin
            $display("PASS: Basic virtual interface works");
            pass_count++;
        end else begin
            $display("FAIL: Basic virtual interface failed");
            fail_count++;
        end
    endtask

    // Test 2: Virtual interface reassignment
    task test_vif_reassignment();
        virtual simple_if vif;

        // Assign to if1
        vif = if1;
        vif.data = 8'h11;
        @(posedge clk);

        // Reassign to if2
        vif = if2;
        vif.data = 8'h22;
        @(posedge clk);

        if (if1.data == 8'h11 && if2.data == 8'h22) begin
            $display("PASS: Virtual interface reassignment works");
            pass_count++;
        end else begin
            $display("FAIL: Virtual interface reassignment failed");
            fail_count++;
        end
    endtask

    // Test 3: Virtual interface null check
    task test_vif_null();
        virtual simple_if vif;

        if (vif == null) begin
            $display("PASS: Uninitialized virtual interface is null");
            pass_count++;
        end else begin
            $display("FAIL: Uninitialized virtual interface should be null");
            fail_count++;
        end

        vif = if1;
        if (vif != null) begin
            $display("PASS: Assigned virtual interface is not null");
            pass_count++;
        end else begin
            $display("FAIL: Assigned virtual interface should not be null");
            fail_count++;
        end
    endtask

    // Test 4: Virtual interface with modport
    task test_vif_modport();
        virtual simple_if.driver vif_driver;
        virtual simple_if.monitor vif_monitor;

        vif_driver = if1;
        vif_monitor = if1;

        vif_driver.data = 8'hCD;
        vif_driver.valid = 1;
        @(posedge clk);

        if (vif_monitor.data == 8'hCD && vif_monitor.valid == 1) begin
            $display("PASS: Virtual interface with modport works");
            pass_count++;
        end else begin
            $display("FAIL: Virtual interface with modport failed");
            fail_count++;
        end
    endtask

    // Test 5: Virtual interface in class
    class Driver;
        virtual simple_if.driver vif;

        function new(virtual simple_if.driver v);
            vif = v;
        endfunction

        task drive(input logic [7:0] d);
            vif.data = d;
            vif.valid = 1;
            @(posedge vif.clk);
            vif.valid = 0;
        endtask
    endclass

    task test_vif_in_class();
        static Driver drv = new(if1);
        drv.drive(8'hEF);

        if (if1.data == 8'hEF) begin
            $display("PASS: Virtual interface in class works");
            pass_count++;
        end else begin
            $display("FAIL: Virtual interface in class failed");
            fail_count++;
        end
    endtask

    // Test 6: Multiple virtual interfaces
    task test_multiple_vif();
        virtual simple_if vifs[2];

        vifs[0] = if1;
        vifs[1] = if2;

        vifs[0].data = 8'hAA;
        vifs[1].data = 8'hBB;
        @(posedge clk);

        if (if1.data == 8'hAA && if2.data == 8'hBB) begin
            $display("PASS: Multiple virtual interfaces work");
            pass_count++;
        end else begin
            $display("FAIL: Multiple virtual interfaces failed");
            fail_count++;
        end
    endtask

    initial begin
        $display("=== Virtual Interface Corner Cases Test ===");

        // Initialize
        if1.data = 0; if1.valid = 0;
        if2.data = 0; if2.valid = 0;
        repeat (3) @(posedge clk);

        test_basic_vif();
        test_vif_reassignment();
        test_vif_null();
        test_vif_modport();
        test_vif_in_class();
        test_multiple_vif();

        repeat (3) @(posedge clk);

        $display("");
        $display("=== Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
