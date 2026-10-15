/*
:name: test_string_edge_cases_2
:description: Test: String edge cases
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_edge_cases_2.expected
*/
// Test: String edge cases
// IEEE 1800-2023 Section 6.16 String Data Type
// Tests corner cases: methods, comparison, concatenation, conversion

`timescale 1ns/1ps

module test_string_edge_cases_2;
    int passed = 0;
    int failed = 0;

    initial begin
        $display("TEST: String edge cases");

        // Test 1: Empty string
        begin
            static string s = "";
            if (s.len() == 0) begin
                $display("  [PASS] Empty string length is 0");
                passed++;
            end else begin
                $display("  [FAIL] Empty string length should be 0");
                failed++;
            end
        end

        // Test 2: String concatenation
        begin
            static string a = "hello";
            static string b = " world";
            static string c;
            // Assigned here so the result does not depend on the order of static initializers.
            c = {a, b};
            if (c == "hello world") begin
                $display("  [PASS] String concatenation works");
                passed++;
            end else begin
                $display("  [FAIL] String concatenation failed");
                failed++;
            end
        end

        // Test 3: String comparison
        begin
            static string s1 = "abc";
            static string s2 = "abc";
            static string s3 = "abd";
            if (s1 == s2 && s1 != s3) begin
                $display("  [PASS] String comparison works");
                passed++;
            end else begin
                $display("  [FAIL] String comparison failed");
                failed++;
            end
        end

        // Test 4: String len() method
        begin
            static string s = "hello";
            if (s.len() == 5) begin
                $display("  [PASS] String len() returns 5");
                passed++;
            end else begin
                $display("  [FAIL] String len() should return 5");
                failed++;
            end
        end

        // Test 5: String getc() method
        begin
            static string s = "ABC";
            static byte ch;
            // Assigned here so the result does not depend on the order of static initializers.
            ch = s.getc(0);
            if (ch == 65) begin  // 'A' = 65
                $display("  [PASS] String getc(0) returns 'A' (65)");
                passed++;
            end else begin
                $display("  [FAIL] getc(0) should return 65, got %0d", ch);
                failed++;
            end
        end

        // Test 6: String toupper() method
        begin
            static string s = "hello";
            static string upper;
            // Assigned here so the result does not depend on the order of static initializers.
            upper = s.toupper();
            if (upper == "HELLO") begin
                $display("  [PASS] String toupper() works");
                passed++;
            end else begin
                $display("  [FAIL] toupper() should return HELLO");
                failed++;
            end
        end

        // Test 7: String tolower() method
        begin
            static string s = "HELLO";
            static string lower;
            // Assigned here so the result does not depend on the order of static initializers.
            lower = s.tolower();
            if (lower == "hello") begin
                $display("  [PASS] String tolower() works");
                passed++;
            end else begin
                $display("  [FAIL] tolower() should return hello");
                failed++;
            end
        end

        // Test 8: String atoi() method
        begin
            static string s = "123";
            static int val;
            // Assigned here so the result does not depend on the order of static initializers.
            val = s.atoi();
            if (val == 123) begin
                $display("  [PASS] String atoi() returns 123");
                passed++;
            end else begin
                $display("  [FAIL] atoi() should return 123, got %0d", val);
                failed++;
            end
        end

        // Test 9: String substr() method
        begin
            static string s = "hello world";
            static string sub;
            // Assigned here so the result does not depend on the order of static initializers.
            sub = s.substr(0, 4);
            if (sub == "hello") begin
                $display("  [PASS] String substr(0,4) returns hello");
                passed++;
            end else begin
                $display("  [FAIL] substr(0,4) should return hello, got: %s", sub);
                failed++;
            end
        end

        // Test 10: String assignment
        begin
            static string a = "original";
            string b;
            b = a;
            a = "modified";
            if (b == "original") begin
                $display("  [PASS] String assignment creates copy");
                passed++;
            end else begin
                $display("  [FAIL] String assignment should create copy");
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
