/*
:name: test_virtual_intf_edge_cases
:description: Virtual interface edge cases
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_intf_edge_cases.expected
*/
// IEEE 1800-2023 §25.9: Virtual interface edge cases
// Tests for virtual interfaces

interface simple_bus;
    logic [7:0] data;
    logic valid;
    logic ready;
endinterface

class BusDriver;
    virtual simple_bus vif;
    
    function new(virtual simple_bus v);
        vif = v;
    endfunction
    
    task drive(input logic [7:0] d);
        vif.data = d;
        vif.valid = 1;
    endtask
    
    task clear();
        vif.data = 0;
        vif.valid = 0;
    endtask
endclass

module test_virtual_intf_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    simple_bus bus();
    BusDriver drv;

    initial begin
        bus.data = 0;
        bus.valid = 0;
        bus.ready = 1;
        #1;

        // Test 1: Create driver with vif
        test_count++;
        drv = new(bus);
        if (drv != null && drv.vif != null) begin
            pass_count++;
            $display("Test 1 PASS: Driver created with vif");
        end else begin
            $display("Test 1 FAIL: Driver unexpected");
        end

        // Test 2: Drive data
        test_count++;
        drv.drive(8'hAA);
        #1;
        if (bus.data == 8'hAA) begin
            pass_count++;
            $display("Test 2 PASS: Drive data = %h", bus.data);
        end else begin
            $display("Test 2 FAIL: Drive unexpected = %h", bus.data);
        end

        // Test 3: Valid signal
        test_count++;
        if (bus.valid == 1) begin
            pass_count++;
            $display("Test 3 PASS: Valid = %b", bus.valid);
        end else begin
            $display("Test 3 FAIL: Valid unexpected = %b", bus.valid);
        end

        // Test 4: Clear bus
        test_count++;
        drv.clear();
        #1;
        if (bus.data == 0 && bus.valid == 0) begin
            pass_count++;
            $display("Test 4 PASS: Clear data=%h valid=%b", bus.data, bus.valid);
        end else begin
            $display("Test 4 FAIL: Clear unexpected");
        end

        // Test 5: Multiple drives
        test_count++;
        drv.drive(8'h11);
        #1;
        drv.drive(8'h22);
        #1;
        drv.drive(8'h33);
        #1;
        if (bus.data == 8'h33) begin
            pass_count++;
            $display("Test 5 PASS: Multi drive = %h", bus.data);
        end else begin
            $display("Test 5 FAIL: Multi unexpected = %h", bus.data);
        end

        // Test 6: Ready signal access (via bus directly)
        test_count++;
        if (bus.ready == 1) begin
            pass_count++;
            $display("Test 6 PASS: bus.ready = %b", bus.ready);
        end else begin
            $display("Test 6 FAIL: Ready unexpected");
        end

        // Test 7: Direct drive via task
        test_count++;
        drv.drive(8'hFF);
        #1;
        if (bus.data == 8'hFF) begin
            pass_count++;
            $display("Test 7 PASS: Drive vif = %h", bus.data);
        end else begin
            $display("Test 7 FAIL: Drive unexpected");
        end

        // Test 8: Read bus data
        test_count++;
        begin
            static logic [7:0] read_val;
            // Assigned here so the result does not depend on the order of static initializers.
            read_val = bus.data;
            if (read_val == 8'hFF) begin
                pass_count++;
                $display("Test 8 PASS: Read bus = %h", read_val);
            end else begin
                $display("Test 8 FAIL: Read unexpected");
            end
        end

        // Test 9: Second driver
        test_count++;
        begin
            static BusDriver drv2 = new(bus);
            drv2.drive(8'h55);
            #1;
            if (bus.data == 8'h55) begin
                pass_count++;
                $display("Test 9 PASS: Second driver = %h", bus.data);
            end else begin
                $display("Test 9 FAIL: Second unexpected");
            end
        end

        // Test 10: Null check
        test_count++;
        begin
            BusDriver drv3;
            if (drv3 == null) begin
                pass_count++;
                $display("Test 10 PASS: Null driver");
            end else begin
                $display("Test 10 FAIL: Null unexpected");
            end
        end

        $display("=== Virtual Interface Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
