/*
:name: test_string_methods_edge_cases
:description: Test: String methods edge cases
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16 5.9
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_methods_edge_cases.expected
*/
// Test: String methods edge cases
// IEEE 1800-2023 Section 6.16 String Data Type
// Tests corner cases: len, equality, concatenation, indexing, toupper, tolower and copies

`timescale 1ns/1ps

module test_string_methods_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        $display("TEST: String methods edge cases");

        // Test 1: Empty string length
        begin
            static string s = "";
            if (s.len() == 0) begin
                $display("  [PASS] Empty string length is 0");
                passed++;
            end else begin
                $display("  [FAIL] Empty string length wrong");
                failed++;
            end
        end

        // Test 2: Non-empty string length
        begin
            static string s = "Hello";
            if (s.len() == 5) begin
                $display("  [PASS] String length 'Hello' is 5");
                passed++;
            end else begin
                $display("  [FAIL] String length is %0d", s.len());
                failed++;
            end
        end

        // Test 3: String comparison (equal)
        begin
            static string s1 = "test";
            static string s2 = "test";
            if (s1 == s2) begin
                $display("  [PASS] String equality comparison");
                passed++;
            end else begin
                $display("  [FAIL] String equality failed");
                failed++;
            end
        end

        // Test 4: String comparison (not equal)
        begin
            static string s1 = "abc";
            static string s2 = "xyz";
            if (s1 != s2) begin
                $display("  [PASS] String inequality comparison");
                passed++;
            end else begin
                $display("  [FAIL] String inequality failed");
                failed++;
            end
        end

        // Test 5: String concatenation
        begin
            static string s1 = "Hello";
            static string s2 = " World";
            static string s3;
            // Assigned here so the result does not depend on the order of static initializers.
            s3 = {s1, s2};
            if (s3 == "Hello World") begin
                $display("  [PASS] String concatenation");
                passed++;
            end else begin
                $display("  [FAIL] Concatenation result: %s", s3);
                failed++;
            end
        end

        // Test 6: Character access
        begin
            static string s = "ABCDE";
            static byte c;
            // Assigned here so the result does not depend on the order of static initializers.
            c = s[2];  // Should be 'C' = 67
            if (c == 67) begin
                $display("  [PASS] Character access s[2] = 'C'");
                passed++;
            end else begin
                $display("  [FAIL] Character access got %0d", c);
                failed++;
            end
        end

        // Test 7: toupper method
        begin
            static string s = "hello";
            static string upper;
            // Assigned here so the result does not depend on the order of static initializers.
            upper = s.toupper();
            if (upper == "HELLO") begin
                $display("  [PASS] toupper method");
                passed++;
            end else begin
                $display("  [FAIL] toupper result: %s", upper);
                failed++;
            end
        end

        // Test 8: tolower method
        begin
            static string s = "HELLO";
            static string lower;
            // Assigned here so the result does not depend on the order of static initializers.
            lower = s.tolower();
            if (lower == "hello") begin
                $display("  [PASS] tolower method");
                passed++;
            end else begin
                $display("  [FAIL] tolower result: %s", lower);
                failed++;
            end
        end

        // Test 9: String assignment
        begin
            string s1, s2;
            s1 = "initial";
            s2 = s1;
            s1 = "changed";
            if (s2 == "initial") begin
                $display("  [PASS] String value semantics");
                passed++;
            end else begin
                $display("  [FAIL] String should be copy, not reference");
                failed++;
            end
        end

        // Test 10: String with special characters
        begin
            static string s = "Tab:\tNewline:\n";
            // 4 + tab + 8 + newline = 14 characters
            if (s.len() == 14) begin
                $display("  [PASS] String with escape characters");
                passed++;
            end else begin
                $display("  [FAIL] Special char handling");
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
