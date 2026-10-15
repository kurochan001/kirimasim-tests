/*
:name: test_assoc_array_edge_cases_3
:description: Test: Associative array edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8 7.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_array_edge_cases_3.expected
*/
// Test: Associative array edge cases
// IEEE 1800-2023 Section 7.8 Associative Arrays
// Tests corner cases: wildcard keys, last/prev, assignment, default values

`timescale 1ns/1ps

module test_assoc_array_edge_cases;
    int passed = 0;
    int failed = 0;

    // Various associative array types
    int aa_string[string];
    int aa_int[int];
    string aa_val_str[int];  // int key, string value
    int aa_wildcard[*];      // Wildcard key type

    initial begin
        $display("TEST: Associative array edge cases");

        // Test 1: Empty array - num() vs size()
        if (aa_string.num() == 0 && aa_string.size() == 0) begin
            $display("  [PASS] Empty array: num()=size()=0");
            passed++;
        end else begin
            $display("  [FAIL] Empty array should have num()=size()=0");
            failed++;
        end

        // Test 2: Wildcard key type with int
        aa_wildcard[42] = 100;
        aa_wildcard[123] = 200;
        if (aa_wildcard[42] == 100 && aa_wildcard[123] == 200) begin
            $display("  [PASS] Wildcard key with int works");
            passed++;
        end else begin
            $display("  [FAIL] Wildcard key with int should work");
            failed++;
        end

        // Test 3: String value in associative array
        aa_val_str[1] = "first";
        aa_val_str[2] = "second";
        if (aa_val_str[1] == "first" && aa_val_str[2] == "second") begin
            $display("  [PASS] String values in associative array work");
            passed++;
        end else begin
            $display("  [FAIL] String values should work");
            failed++;
        end

        // Test 4: Assignment creates copy
        begin
            int a1[string];
            int a2[string];
            a1["key"] = 10;
            a2 = a1;
            a1["key"] = 999;  // Modify original
            if (a2["key"] == 10) begin
                $display("  [PASS] Associative array assignment is deep copy");
                passed++;
            end else begin
                $display("  [FAIL] Assignment should be deep copy");
                failed++;
            end
        end

        // Test 5: last() method
        begin
            int aa[int];
            int key;
            aa[10] = 1;
            aa[20] = 2;
            aa[30] = 3;
            if (aa.last(key) && key == 30) begin
                $display("  [PASS] last() returns highest key");
                passed++;
            end else begin
                $display("  [FAIL] last() should return highest key, got %0d", key);
                failed++;
            end
        end

        // Test 6: prev() method
        begin
            int aa[int];
            int key;
            aa[10] = 1;
            aa[20] = 2;
            aa[30] = 3;
            key = 30;
            if (aa.prev(key) && key == 20) begin
                $display("  [PASS] prev() returns previous key");
                passed++;
            end else begin
                $display("  [FAIL] prev() should return previous key");
                failed++;
            end
        end

        // Test 7: exists() on deleted key
        begin
            int aa[string];
            aa["test"] = 42;
            aa.delete("test");
            if (!aa.exists("test")) begin
                $display("  [PASS] exists() returns 0 after delete");
                passed++;
            end else begin
                $display("  [FAIL] exists() should return 0 after delete");
                failed++;
            end
        end

        // Test 8: Multiple data types with same key type
        begin
            logic [31:0] aa_logic[int];
            real aa_real[int];
            aa_logic[1] = 32'hDEADBEEF;
            aa_real[1] = 3.14159;
            if (aa_logic[1] == 32'hDEADBEEF && aa_real[1] > 3.14) begin
                $display("  [PASS] Different value types with int keys work");
                passed++;
            end else begin
                $display("  [FAIL] Different value types should work");
                failed++;
            end
        end

        // Test 9: Zero as valid key
        begin
            int aa[int];
            aa[0] = 42;
            if (aa.exists(0) && aa[0] == 42) begin
                $display("  [PASS] Zero is a valid key");
                passed++;
            end else begin
                $display("  [FAIL] Zero should be a valid key");
                failed++;
            end
        end

        // Test 10: Overwrite doesn't increase size
        begin
            int aa_test10[string];
            aa_test10["key"] = 1;
            aa_test10["key"] = 2;
            aa_test10["key"] = 3;
            if (aa_test10.size() == 1 && aa_test10["key"] == 3) begin
                $display("  [PASS] Overwrite updates value, keeps size");
                passed++;
            end else begin
                $display("  [FAIL] Overwrite should not increase size");
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
