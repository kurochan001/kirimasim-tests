/*
:name: test_virtual_interface_signal_access
:description: Test for Virtual Interface signal access (IEEE 1800-2023 §25.9)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.9
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_interface_signal_access.expected
*/
// Test for Virtual Interface signal access (IEEE 1800-2023 §25.9)
// Tests: vif assignment, signal read/write through vif

interface simple_if;
    logic [7:0] data;
    logic valid;
    logic ready;
endinterface

class driver;
    virtual simple_if vif;

    function new(virtual simple_if vif);
        this.vif = vif;
    endfunction

    task drive(input logic [7:0] d);
        vif.data = d;
        vif.valid = 1'b1;
    endtask

    task clear();
        vif.data = 8'h00;
        vif.valid = 1'b0;
    endtask

    function logic [7:0] read_data();
        return vif.data;
    endfunction

    function logic is_valid();
        return vif.valid;
    endfunction
endclass

module test_virtual_interface_signal_access;
    simple_if sif();
    driver drv;

    int pass_count = 0;
    int fail_count = 0;

    initial begin
        $display("=== Virtual Interface Signal Access Test ===");

        // Test 1: Create driver with virtual interface
        drv = new(sif);
        if (drv != null) begin
            $display("PASS: Driver created with virtual interface");
            pass_count++;
        end else begin
            $display("FAIL: Driver creation failed");
            fail_count++;
        end

        // Test 2: Write through virtual interface
        drv.drive(8'hAB);
        #1;
        if (sif.data == 8'hAB && sif.valid == 1'b1) begin
            $display("PASS: Write through vif works (data=0x%h, valid=%b)", sif.data, sif.valid);
            pass_count++;
        end else begin
            $display("FAIL: Write through vif failed (data=0x%h, valid=%b)", sif.data, sif.valid);
            fail_count++;
        end

        // Test 3: Read through virtual interface
        if (drv.read_data() == 8'hAB) begin
            $display("PASS: Read through vif works (read_data=0x%h)", drv.read_data());
            pass_count++;
        end else begin
            $display("FAIL: Read through vif failed (read_data=0x%h)", drv.read_data());
            fail_count++;
        end

        // Test 4: Check valid flag through vif
        if (drv.is_valid() == 1'b1) begin
            $display("PASS: is_valid() returns correct value");
            pass_count++;
        end else begin
            $display("FAIL: is_valid() returned wrong value");
            fail_count++;
        end

        // Test 5: Clear and verify
        drv.clear();
        #1;
        if (sif.data == 8'h00 && sif.valid == 1'b0) begin
            $display("PASS: Clear through vif works");
            pass_count++;
        end else begin
            $display("FAIL: Clear through vif failed");
            fail_count++;
        end

        // Summary
        $display("");
        $display("=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);

        if (fail_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        $finish;
    end
endmodule
