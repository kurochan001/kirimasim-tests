/*
:name: test_interface_array_edge_cases
:description: Interface array edge cases
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3 23.3.3.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_array_edge_cases.expected
*/
// IEEE 1800-2023 §25: Interface array edge cases
// Tests for arrays of interfaces

interface data_if;
    logic [7:0] data;
    logic valid;
endinterface

module test_interface_array_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    data_if intf_arr[4]();

    initial begin
        // Test 1: Initialize all interfaces (use constant indices)
        test_count++;
        intf_arr[0].data = 8'h00;
        intf_arr[0].valid = 0;
        intf_arr[1].data = 8'h10;
        intf_arr[1].valid = 0;
        intf_arr[2].data = 8'h20;
        intf_arr[2].valid = 0;
        intf_arr[3].data = 8'h30;
        intf_arr[3].valid = 0;
        pass_count++;
        $display("Test 1 PASS: Interface array initialized");

        // Test 2: Read first element
        test_count++;
        if (intf_arr[0].data == 8'h00) begin
            pass_count++;
            $display("Test 2 PASS: intf_arr[0].data = %h", intf_arr[0].data);
        end else begin
            $display("Test 2 FAIL: First unexpected = %h", intf_arr[0].data);
        end

        // Test 3: Read last element
        test_count++;
        if (intf_arr[3].data == 8'h30) begin
            pass_count++;
            $display("Test 3 PASS: intf_arr[3].data = %h", intf_arr[3].data);
        end else begin
            $display("Test 3 FAIL: Last unexpected = %h", intf_arr[3].data);
        end

        // Test 4: Set valid flags
        test_count++;
        intf_arr[0].valid = 1;
        intf_arr[1].valid = 1;
        intf_arr[2].valid = 1;
        intf_arr[3].valid = 1;
        if (intf_arr[0].valid && intf_arr[3].valid) begin
            pass_count++;
            $display("Test 4 PASS: All valid set");
        end else begin
            $display("Test 4 FAIL: Valid unexpected");
        end

        // Test 5: Modify middle element
        test_count++;
        intf_arr[2].data = 8'hFF;
        if (intf_arr[2].data == 8'hFF) begin
            pass_count++;
            $display("Test 5 PASS: Middle modified = %h", intf_arr[2].data);
        end else begin
            $display("Test 5 FAIL: Middle unexpected = %h", intf_arr[2].data);
        end

        // Test 6: Check independence
        test_count++;
        intf_arr[1].data = 8'hAA;
        if (intf_arr[0].data != intf_arr[1].data) begin
            pass_count++;
            $display("Test 6 PASS: Elements independent");
        end else begin
            $display("Test 6 FAIL: Independence unexpected");
        end

        // Test 7: Copy between elements
        test_count++;
        intf_arr[0].data = intf_arr[1].data;
        if (intf_arr[0].data == 8'hAA) begin
            pass_count++;
            $display("Test 7 PASS: Copy = %h", intf_arr[0].data);
        end else begin
            $display("Test 7 FAIL: Copy unexpected = %h", intf_arr[0].data);
        end

        // Test 8: Sum all data (use constant indices)
        test_count++;
        begin
            static int sum = 0;
            sum = intf_arr[0].data + intf_arr[1].data + intf_arr[2].data + intf_arr[3].data;
            pass_count++;
            $display("Test 8 PASS: Sum = %0d", sum);
        end

        // Test 9: Clear all
        test_count++;
        intf_arr[0].data = 0;
        intf_arr[0].valid = 0;
        intf_arr[1].data = 0;
        intf_arr[1].valid = 0;
        intf_arr[2].data = 0;
        intf_arr[2].valid = 0;
        intf_arr[3].data = 0;
        intf_arr[3].valid = 0;
        if (intf_arr[0].data == 0 && intf_arr[3].data == 0) begin
            pass_count++;
            $display("Test 9 PASS: All cleared");
        end else begin
            $display("Test 9 FAIL: Clear unexpected");
        end

        // Test 10: Sequential pattern
        test_count++;
        intf_arr[0].data = 0;
        intf_arr[1].data = 1;
        intf_arr[2].data = 2;
        intf_arr[3].data = 3;
        if (intf_arr[0].data == 0 && intf_arr[1].data == 1 &&
            intf_arr[2].data == 2 && intf_arr[3].data == 3) begin
            pass_count++;
            $display("Test 10 PASS: Sequential pattern");
        end else begin
            $display("Test 10 FAIL: Sequential unexpected");
        end

        $display("=== Interface Array Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
