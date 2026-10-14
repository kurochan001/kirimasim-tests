/*
:name: test_array_slicing_edge_cases
:description: Test: Array slicing edge cases
:tags: array_slicing
:type: simulation
:lrm: 1800-2023 7.4 11.5.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_slicing_edge_cases.expected
*/
// Test: Array slicing edge cases
// IEEE 1800-2023 Section 7.4 Packed and Unpacked Arrays
// Tests corner cases: array slicing operations

`timescale 1ns/1ps

module test_array_slicing_edge_cases;
    int passed = 0;
    int failed = 0;

    int arr[10];
    logic [31:0] data;

    initial begin
        $display("TEST: Array slicing edge cases");

        // Initialize array
        for (int i = 0; i < 10; i++) arr[i] = i * 10;

        // Test 1: Array element access
        begin
            if (arr[0] == 0 && arr[5] == 50) begin
                $display("  [PASS] Array element access");
                passed++;
            end else begin
                $display("  [FAIL] Elem: %0d %0d", arr[0], arr[5]);
                failed++;
            end
        end

        // Test 2: Array first element
        begin
            if (arr[0] == 0) begin
                $display("  [PASS] First element");
                passed++;
            end else begin
                $display("  [FAIL] First: %0d", arr[0]);
                failed++;
            end
        end

        // Test 3: Array last element
        begin
            if (arr[9] == 90) begin
                $display("  [PASS] Last element");
                passed++;
            end else begin
                $display("  [FAIL] Last: %0d", arr[9]);
                failed++;
            end
        end

        // Test 4: Packed bit slice
        begin
            data = 32'hABCD1234;
            if (data[31:24] == 8'hAB) begin
                $display("  [PASS] Packed high byte");
                passed++;
            end else begin
                $display("  [FAIL] High: %h", data[31:24]);
                failed++;
            end
        end

        // Test 5: Packed low byte
        begin
            data = 32'hABCD1234;
            if (data[7:0] == 8'h34) begin
                $display("  [PASS] Packed low byte");
                passed++;
            end else begin
                $display("  [FAIL] Low: %h", data[7:0]);
                failed++;
            end
        end

        // Test 6: Packed middle bytes
        begin
            data = 32'hABCD1234;
            if (data[23:16] == 8'hCD) begin
                $display("  [PASS] Packed middle");
                passed++;
            end else begin
                $display("  [FAIL] Mid: %h", data[23:16]);
                failed++;
            end
        end

        // Test 7: Array modify element
        begin
            arr[5] = 999;
            if (arr[5] == 999) begin
                $display("  [PASS] Modify element");
                passed++;
            end else begin
                $display("  [FAIL] Modify: %0d", arr[5]);
                failed++;
            end
            arr[5] = 50;  // Restore
        end

        // Test 8: Packed slice write
        begin
            data = 32'h00000000;
            data[15:8] = 8'hFF;
            if (data == 32'h0000FF00) begin
                $display("  [PASS] Slice write");
                passed++;
            end else begin
                $display("  [FAIL] SliceW: %h", data);
                failed++;
            end
        end

        // Test 9: Array sum via loop
        begin
            static int sum = 0;
            for (int i = 0; i < 5; i++) sum += arr[i];
            if (sum == 100) begin
                $display("  [PASS] Array sum");
                passed++;
            end else begin
                $display("  [FAIL] Sum: %0d", sum);
                failed++;
            end
        end

        // Test 10: Indexed variable
        begin
            static int idx = 3;
            if (arr[idx] == 30) begin
                $display("  [PASS] Indexed variable");
                passed++;
            end else begin
                $display("  [FAIL] Idx: %0d", arr[idx]);
                failed++;
            end
        end

        // Summary
        $display("");
        $display("Results: %0d passed, %0d failed", passed, failed);
        if (failed == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
    end
endmodule
