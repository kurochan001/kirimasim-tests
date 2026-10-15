/*
:name: test_dynamic_array_edge_cases
:description: Test: Dynamic array edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_dynamic_array_edge_cases.expected
*/
// Test: Dynamic array edge cases
// IEEE 1800-2023 Section 7.5 Dynamic arrays
// Tests corner cases: empty arrays, size changes, copy semantics

`timescale 1ns/1ps

module test_dynamic_array_edge_cases;
    int passed = 0;
    int failed = 0;

    // Test dynamic array of different types
    int dyn_int[];
    logic [7:0] dyn_logic[];
    string dyn_string[];

    initial begin
        $display("TEST: Dynamic array edge cases");

        // Test 1: Empty array operations
        if (dyn_int.size() == 0) begin
            $display("  [PASS] Empty array size is 0");
            passed++;
        end else begin
            $display("  [FAIL] Empty array size should be 0");
            failed++;
        end

        // Test 2: Create with new
        dyn_int = new[5];
        if (dyn_int.size() == 5) begin
            $display("  [PASS] new[5] creates array of size 5");
            passed++;
        end else begin
            $display("  [FAIL] new[5] should create size 5");
            failed++;
        end

        // Test 3: Default values after new
        if (dyn_int[0] == 0 && dyn_int[4] == 0) begin
            $display("  [PASS] Default values are 0");
            passed++;
        end else begin
            $display("  [FAIL] Default values should be 0");
            failed++;
        end

        // Test 4: Resize with preservation
        dyn_int[0] = 100;
        dyn_int[4] = 400;
        dyn_int = new[10](dyn_int);  // Resize preserving values
        if (dyn_int.size() == 10 && dyn_int[0] == 100 && dyn_int[4] == 400) begin
            $display("  [PASS] Resize with preservation works");
            passed++;
        end else begin
            $display("  [FAIL] Resize should preserve existing values");
            failed++;
        end

        // Test 5: Shrink array
        dyn_int = new[3](dyn_int);
        if (dyn_int.size() == 3 && dyn_int[0] == 100) begin
            $display("  [PASS] Shrink preserves valid indices");
            passed++;
        end else begin
            $display("  [FAIL] Shrink should preserve valid indices");
            failed++;
        end

        // Test 6: Delete array
        dyn_int.delete();
        if (dyn_int.size() == 0) begin
            $display("  [PASS] delete() sets size to 0");
            passed++;
        end else begin
            $display("  [FAIL] delete() should set size to 0");
            failed++;
        end

        // Test 7: Logic array with X/Z
        dyn_logic = new[3];
        dyn_logic[0] = 8'hFF;
        dyn_logic[1] = 8'hXX;
        dyn_logic[2] = 8'hZZ;
        if (dyn_logic[0] == 8'hFF) begin
            $display("  [PASS] Logic array stores values correctly");
            passed++;
        end else begin
            $display("  [FAIL] Logic array should store values");
            failed++;
        end

        // Test 8: String array
        dyn_string = new[2];
        dyn_string[0] = "hello";
        dyn_string[1] = "world";
        if (dyn_string[0] == "hello" && dyn_string[1] == "world") begin
            $display("  [PASS] String array works");
            passed++;
        end else begin
            $display("  [FAIL] String array should work");
            failed++;
        end

        // Test 9: Array copy semantics
        begin
            int arr1[], arr2[];
            arr1 = new[3];
            arr1[0] = 10;
            arr1[1] = 20;
            arr1[2] = 30;
            arr2 = arr1;  // Copy
            arr2[0] = 99;
            // After copy, arr1 should be unchanged (deep copy)
            if (arr1[0] == 10) begin
                $display("  [PASS] Array assignment is deep copy");
                passed++;
            end else begin
                $display("  [FAIL] Array assignment should be deep copy");
                failed++;
            end
        end

        // Test 10: Zero-size new
        dyn_int = new[0];
        if (dyn_int.size() == 0) begin
            $display("  [PASS] new[0] creates empty array");
            passed++;
        end else begin
            $display("  [FAIL] new[0] should create empty array");
            failed++;
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
