/*
:name: test_packed_array_edge_cases
:description: Test: Packed array edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_array_edge_cases.expected
*/
// Test: Packed array edge cases
// IEEE 1800-2023 Section 7.4 Packed Arrays
// Tests corner cases: multi-dimensional, bit selection, part select

`timescale 1ns/1ps

module test_packed_array_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        $display("TEST: Packed array edge cases");

        // Test 1: 2D packed array initialization
        begin
            logic [3:0][7:0] packed2d;
            packed2d = 32'hDEADBEEF;
            if (packed2d == 32'hDEADBEEF) begin
                $display("  [PASS] 2D packed array initialization");
                passed++;
            end else begin
                $display("  [FAIL] 2D packed init failed");
                failed++;
            end
        end

        // Test 2: Packed array element access
        begin
            logic [3:0][7:0] packed2d;
            packed2d = 32'hDEADBEEF;
            // packed2d[0] is bytes [7:0] = 8'hEF
            if (packed2d[0] == 8'hEF) begin
                $display("  [PASS] Packed array element access [0]");
                passed++;
            end else begin
                $display("  [FAIL] Element access failed, got %h", packed2d[0]);
                failed++;
            end
        end

        // Test 3: Packed array high element
        begin
            logic [3:0][7:0] packed2d;
            packed2d = 32'hDEADBEEF;
            // packed2d[3] is bytes [31:24] = 8'hDE
            if (packed2d[3] == 8'hDE) begin
                $display("  [PASS] Packed array high element [3]");
                passed++;
            end else begin
                $display("  [FAIL] High element failed, got %h", packed2d[3]);
                failed++;
            end
        end

        // Test 4: Packed array element assignment
        begin
            logic [3:0][7:0] packed2d;
            packed2d = 32'h00000000;
            packed2d[1] = 8'hAB;
            if (packed2d == 32'h0000AB00) begin
                $display("  [PASS] Packed array element assignment");
                passed++;
            end else begin
                $display("  [FAIL] Element assignment failed, got %h", packed2d);
                failed++;
            end
        end

        // Test 5: Bit selection from packed array
        begin
            logic [3:0][7:0] packed2d;
            packed2d = 32'hDEADBEEF;
            // Bit 0 of the whole array
            if (packed2d[0][0] == 1'b1) begin
                $display("  [PASS] Bit selection from packed array");
                passed++;
            end else begin
                $display("  [FAIL] Bit selection failed");
                failed++;
            end
        end

        // Test 6: Part select from packed array
        begin
            logic [31:0] data;
            data = 32'hABCD1234;
            if (data[15:8] == 8'h12) begin
                $display("  [PASS] Part select [15:8]");
                passed++;
            end else begin
                $display("  [FAIL] Part select failed, got %h", data[15:8]);
                failed++;
            end
        end

        // Test 7: Packed array with wider elements
        begin
            logic [1:0][15:0] packed_wide;
            packed_wide = 32'hABCD1234;
            // packed_wide[0] is bits [15:0] = 16'h1234
            // packed_wide[1] is bits [31:16] = 16'hABCD
            if (packed_wide[0] == 16'h1234 && packed_wide[1] == 16'hABCD) begin
                $display("  [PASS] Wide packed array elements");
                passed++;
            end else begin
                $display("  [FAIL] Wide elements failed, got [0]=%h [1]=%h", packed_wide[0], packed_wide[1]);
                failed++;
            end
        end

        // Test 8: Packed array concatenation
        begin
            logic [1:0][7:0] arr1;
            logic [1:0][7:0] arr2;
            logic [3:0][7:0] result;
            arr1 = 16'hABCD;
            arr2 = 16'h1234;
            result = {arr1, arr2};
            if (result == 32'hABCD1234) begin
                $display("  [PASS] Packed array concatenation");
                passed++;
            end else begin
                $display("  [FAIL] Concatenation failed, got %h", result);
                failed++;
            end
        end

        // Test 9: Packed array slice
        begin
            logic [7:0][3:0] arr;
            arr = 32'h12345678;
            // Check multiple elements
            if (arr[0] == 4'h8 && arr[7] == 4'h1) begin
                $display("  [PASS] Packed array slice access");
                passed++;
            end else begin
                $display("  [FAIL] Slice access failed");
                failed++;
            end
        end

        // Test 10: $bits on packed array
        begin
            logic [3:0][7:0] arr;
            if ($bits(arr) == 32) begin
                $display("  [PASS] $bits on packed array = 32");
                passed++;
            end else begin
                $display("  [FAIL] $bits returned %0d", $bits(arr));
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
