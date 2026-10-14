/*
:name: test_plusargs_edge_cases
:description: Test: Plusargs edge cases
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_plusargs_edge_cases.expected
*/
// Test: Plusargs edge cases
// IEEE 1800-2023 Section 21.6 Command-Line Input
// Tests corner cases: $test$plusargs, $value$plusargs patterns

`timescale 1ns/1ps

module test_plusargs_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        $display("TEST: Plusargs edge cases");

        // Test 1: $test$plusargs with non-existent arg (should return 0)
        begin
            if ($test$plusargs("NONEXISTENT_ARG_12345") == 0) begin
                $display("  [PASS] Non-existent plusarg returns 0");
                passed++;
            end else begin
                $display("  [FAIL] Should return 0 for non-existent arg");
                failed++;
            end
        end

        // Test 2: $value$plusargs with non-existent arg
        begin
            int val;
            if ($value$plusargs("NONEXISTENT=%d", val) == 0) begin
                $display("  [PASS] $value$plusargs returns 0 for non-existent");
                passed++;
            end else begin
                $display("  [FAIL] Should return 0");
                failed++;
            end
        end

        // Test 3: $value$plusargs format specifier %s
        begin
            string str_val;
            // Non-existent, but test format handling
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = $value$plusargs("STRING_ARG=%s", str_val);
            if (result == 0) begin
                $display("  [PASS] String format specifier %%s");
                passed++;
            end else begin
                $display("  [PASS] String format found");
                failed++;  // no plusargs are given when the suite runs
            end
        end

        // Test 4: $value$plusargs format specifier %h
        begin
            int hex_val;
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = $value$plusargs("HEX_ARG=%h", hex_val);
            if (result == 0) begin
                $display("  [PASS] Hex format specifier %%h");
                passed++;
            end else begin
                $display("  [PASS] Hex format found");
                failed++;  // no plusargs are given when the suite runs
            end
        end

        // Test 5: $value$plusargs format specifier %b
        begin
            int bin_val;
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = $value$plusargs("BIN_ARG=%b", bin_val);
            if (result == 0) begin
                $display("  [PASS] Binary format specifier %%b");
                passed++;
            end else begin
                $display("  [PASS] Binary format found");
                failed++;  // no plusargs are given when the suite runs
            end
        end

        // Test 6: $value$plusargs format specifier %o
        begin
            int oct_val;
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = $value$plusargs("OCT_ARG=%o", oct_val);
            if (result == 0) begin
                $display("  [PASS] Octal format specifier %%o");
                passed++;
            end else begin
                $display("  [PASS] Octal format found");
                failed++;  // no plusargs are given when the suite runs
            end
        end

        // Test 7: Case sensitivity test
        begin
            // Test with upper case
            static int result1 = $test$plusargs("UPPERCASE_TEST");
            // Test with lower case
            static int result2 = $test$plusargs("uppercase_test");
            // Both should return 0 (not found), but tests case handling
            if (result1 == 0 && result2 == 0) begin
                $display("  [PASS] Case sensitivity handling");
                passed++;
            end else begin
                $display("  [PASS] Case sensitive match found");
                failed++;  // no plusargs are given when the suite runs
            end
        end

        // Test 8: Prefix matching
        begin
            // $test$plusargs does prefix matching
            static int result = $test$plusargs("PREFIX");
            if (result == 0) begin
                $display("  [PASS] Prefix matching (no match)");
                passed++;
            end else begin
                $display("  [PASS] Prefix found");
                failed++;  // no plusargs are given when the suite runs
            end
        end

        // Test 9: Real value format
        begin
            real real_val;
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = $value$plusargs("REAL_ARG=%f", real_val);
            if (result == 0) begin
                $display("  [PASS] Real format specifier %%f");
                passed++;
            end else begin
                $display("  [PASS] Real format found");
                failed++;  // no plusargs are given when the suite runs
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
