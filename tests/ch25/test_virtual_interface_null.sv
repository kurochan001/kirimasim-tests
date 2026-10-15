/*
:name: test_virtual_interface_null
:description: Virtual interfaces basic test
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.9 6.8
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_interface_null.expected
*/
// IEEE 1800-2023 §25.9: Virtual interfaces basic test
// Tests virtual interface assignment and null checking

interface simple_bus;
    logic [7:0] data;
    logic valid;
endinterface

module test_virtual_interface_null;
    int pass_count = 0;
    int test_count = 0;

    // Actual interface instance
    simple_bus bus();

    // Virtual interface
    virtual simple_bus vif;

    // Class using virtual interface
    class BusUser;
        virtual simple_bus vif;

        function new(virtual simple_bus v);
            vif = v;
        endfunction

        function bit is_valid();
            return (vif != null);
        endfunction
    endclass

    initial begin
        // Test 1: Virtual interface can be assigned
        test_count++;
        // A virtual interface starts as null (6.8, 25.9)
        if (vif == null) begin
            pass_count++;
            $display("Test 1 PASS: virtual interface declared");
        end else begin
            $display("Test 1 FAIL: virtual interface is not null before assignment");
        end

        // Test 2: Virtual interface assignment
        test_count++;
        vif = bus;
        if (vif != null) begin
            pass_count++;
            $display("Test 2 PASS: vif not null after assignment");
        end else begin
            $display("Test 2 FAIL: vif should not be null");
        end

        // Test 3: Class with virtual interface
        test_count++;
        begin
            static BusUser user = new(bus);
            if (user.is_valid()) begin
                pass_count++;
                $display("Test 3 PASS: class virtual interface");
            end else begin
                $display("Test 3 FAIL: class vif invalid");
            end
        end

        // Test 4: Class with null virtual interface
        test_count++;
        begin
            static BusUser user = new(null);
            if (!user.is_valid()) begin
                pass_count++;
                $display("Test 4 PASS: class with null vif");
            end else begin
                $display("Test 4 FAIL: null vif check");
            end
        end

        // Test 5: Virtual interface in local scope
        test_count++;
        begin
            virtual simple_bus local_vif;
            local_vif = bus;
            if (local_vif != null) begin
                pass_count++;
                $display("Test 5 PASS: local virtual interface");
            end else begin
                $display("Test 5 FAIL: local vif null");
            end
        end

        // Test 6: Multiple class instances
        test_count++;
        begin
            BusUser user1, user2;
            user1 = new(bus);
            user2 = new(bus);
            if (user1.is_valid() && user2.is_valid()) begin
                pass_count++;
                $display("Test 6 PASS: multiple class instances");
            end else begin
                $display("Test 6 FAIL: multiple instances");
            end
        end

        $display("=== Virtual Interface Basic Test Results ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
