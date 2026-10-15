/*
:name: test_comb_string_compare
:description: Test: String comparison operators and methods
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comb_string_compare.expected
*/
// Test: String comparison operators and methods
// String equality, ordering and methods (6.16)
module test_comb_string_compare;
    int pass_count = 0;

    initial begin
        // Test 1: String equality
        begin
            static string a = "hello";
            static string b = "hello";
            if (a == b) begin
                $display("T1: PASS - identical strings are equal");
                pass_count++;
            end else begin
                $display("T1: FAIL - identical strings not equal");
            end
        end

        // Test 2: String inequality
        begin
            static string a = "hello";
            static string b = "world";
            if (a != b) begin
                $display("T2: PASS - different strings are not equal");
                pass_count++;
            end else begin
                $display("T2: FAIL - different strings reported as equal");
            end
        end

        // Test 3: String less than (lexicographic)
        begin
            static string a = "apple";
            static string b = "banana";
            if (a < b) begin
                $display("T3: PASS - 'apple' < 'banana'");
                pass_count++;
            end else begin
                $display("T3: FAIL - 'apple' not < 'banana'");
            end
        end

        // Test 4: String greater than
        begin
            static string a = "zebra";
            static string b = "aardvark";
            if (a > b) begin
                $display("T4: PASS - 'zebra' > 'aardvark'");
                pass_count++;
            end else begin
                $display("T4: FAIL - 'zebra' not > 'aardvark'");
            end
        end

        // Test 5: String compare method
        begin
            static string a = "hello";
            static string b = "hello";
            if (a.compare(b) == 0) begin
                $display("T5: PASS - compare() returns 0 for equal strings");
                pass_count++;
            end else begin
                $display("T5: FAIL - compare() = %0d (expected 0)", a.compare(b));
            end
        end

        // Test 6: String icompare (case-insensitive)
        begin
            static string a = "Hello";
            static string b = "hello";
            if (a.icompare(b) == 0) begin
                $display("T6: PASS - icompare() returns 0 for case-different strings");
                pass_count++;
            end else begin
                $display("T6: FAIL - icompare() = %0d (expected 0)", a.icompare(b));
            end
        end

        // Test 7: String concatenation
        begin
            static string a = "hello";
            static string b = " world";
            static string c;
            // Assigned here so the result does not depend on the order of static initializers.
            c = {a, b};
            if (c == "hello world") begin
                $display("T7: PASS - string concatenation works");
                pass_count++;
            end else begin
                $display("T7: FAIL - concatenation result: '%s'", c);
            end
        end

        // Test 8: String length
        begin
            static string s = "hello";
            if (s.len() == 5) begin
                $display("T8: PASS - len() = 5");
                pass_count++;
            end else begin
                $display("T8: FAIL - len() = %0d (expected 5)", s.len());
            end
        end

        // Test 9: String toupper/tolower
        begin
            static string s = "Hello World";
            static string upper;
            static string lower;
            // Assigned here so the result does not depend on the order of static initializers.
            upper = s.toupper();
            lower = s.tolower();
            if (upper == "HELLO WORLD" && lower == "hello world") begin
                $display("T9: PASS - toupper/tolower work");
                pass_count++;
            end else begin
                $display("T9: FAIL - upper='%s', lower='%s'", upper, lower);
            end
        end

        // Test 10: String substr (IEEE 1800-2023: substr(start, end) inclusive)
        begin
            static string s = "hello world";
            static string sub;
            // Assigned here so the result does not depend on the order of static initializers.
            sub = s.substr(6, 10);  // positions 6-10 inclusive = "world"
            if (sub == "world") begin
                $display("T10: PASS - substr(6,10) = 'world'");
                pass_count++;
            end else begin
                $display("T10: FAIL - substr(6,10) = '%s' (expected 'world')", sub);
            end
        end

        // Test 11: String atoi
        begin
            static string s = "42";
            static int v;
            // Assigned here so the result does not depend on the order of static initializers.
            v = s.atoi();
            if (v == 42) begin
                $display("T11: PASS - atoi('42') = 42");
                pass_count++;
            end else begin
                $display("T11: FAIL - atoi('42') = %0d", v);
            end
        end

        // Test 12: Empty string comparison
        begin
            static string a = "";
            static string b = "";
            if (a == b) begin
                $display("T12: PASS - empty strings are equal");
                pass_count++;
            end else begin
                $display("T12: FAIL - empty strings not equal");
            end
        end

        $display("pass_count = %0d", pass_count);
        if (pass_count == 12)
            $display("PASS: test_comb_string_compare");
        else
            $display("FAIL: test_comb_string_compare (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
