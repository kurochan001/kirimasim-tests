/*
:name: test_virtual_interface_2
:description: Virtual interfaces
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.9
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_interface_2.expected
*/
// IEEE 1800-2023 §25.9: Virtual interfaces
// Tests virtual interface declarations and usage
// Verifies dynamic interface binding

interface simple_if;
    logic [7:0] data;
    logic valid;
endinterface

class Driver;
    virtual simple_if vif;

    function new(virtual simple_if vif_arg);
        this.vif = vif_arg;
    endfunction

    function void drive(logic [7:0] d);
        vif.data = d;
        vif.valid = 1;
    endfunction

    function logic [7:0] read_data();
        return vif.data;
    endfunction

    function void clear();
        vif.data = 0;
        vif.valid = 0;
    endfunction
endclass

module test_virtual_interface_2;
    int pass_count = 0;
    int fail_count = 0;

    simple_if if_inst();

    initial begin
        Driver drv;
        logic [7:0] read_val;

        $display("=== IEEE 1800-2023 §25.9: Virtual Interfaces ===");

        // Test 1: Create driver with virtual interface
        drv = new(if_inst);
        if (drv != null) begin
            $display("PASS: Driver created with virtual interface");
            pass_count++;
        end else begin
            $display("FAIL: Driver creation failed");
            fail_count++;
        end

        // Test 2: Drive through virtual interface
        drv.drive(8'hAB);
        if (if_inst.data == 8'hAB) begin
            $display("PASS: Data driven through vif = 0xAB");
            pass_count++;
        end else begin
            $display("FAIL: Data = %h", if_inst.data);
            fail_count++;
        end

        // Test 3: Valid signal set
        if (if_inst.valid == 1) begin
            $display("PASS: Valid set through vif");
            pass_count++;
        end else begin
            $display("FAIL: Valid not set");
            fail_count++;
        end

        // Test 4: Read through virtual interface
        read_val = drv.read_data();
        if (read_val == 8'hAB) begin
            $display("PASS: Read through vif = 0xAB");
            pass_count++;
        end else begin
            $display("FAIL: Read returned %h", read_val);
            fail_count++;
        end

        // Test 5: Clear through class method
        drv.clear();
        if (if_inst.data == 0 && if_inst.valid == 0) begin
            $display("PASS: Clear through vif works");
            pass_count++;
        end else begin
            $display("FAIL: Clear failed");
            fail_count++;
        end

        // Test 6: Second drive
        drv.drive(8'hCD);
        if (if_inst.data == 8'hCD) begin
            $display("PASS: Second drive works");
            pass_count++;
        end else begin
            $display("FAIL: Second drive failed");
            fail_count++;
        end

        $display("");
        $display("=== Results: %0d PASS, %0d FAIL ===", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
