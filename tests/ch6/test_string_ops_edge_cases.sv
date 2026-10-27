/*
:name: test_string_ops_edge_cases
:description: String operations edge cases
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_ops_edge_cases.expected
*/
// IEEE 1800-2023 §6.16: String operations edge cases
// Tests for string methods and operations

module test_string_ops_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    string s1, s2, s3;
    string result;

    initial begin
        // Test 1: String assignment
        test_count++;
        s1 = "Hello";
        if (s1 == "Hello") begin
            pass_count++;
            $display("Test 1 PASS: Assignment = %s", s1);
        end else begin
            $display("Test 1 FAIL: Assignment unexpected");
        end

        // Test 2: String concatenation
        test_count++;
        s1 = "Hello";
        s2 = "World";
        s3 = {s1, " ", s2};
        if (s3 == "Hello World") begin
            pass_count++;
            $display("Test 2 PASS: Concat = %s", s3);
        end else begin
            $display("Test 2 FAIL: Concat unexpected = %s", s3);
        end

        // Test 3: String length
        test_count++;
        s1 = "Test";
        if (s1.len() == 4) begin
            pass_count++;
            $display("Test 3 PASS: len() = %0d", s1.len());
        end else begin
            $display("Test 3 FAIL: len unexpected = %0d", s1.len());
        end

        // Test 4: Empty string
        test_count++;
        s1 = "";
        if (s1.len() == 0) begin
            pass_count++;
            $display("Test 4 PASS: Empty len = 0");
        end else begin
            $display("Test 4 FAIL: Empty unexpected");
        end

        // Test 5: String compare
        test_count++;
        s1 = "abc";
        s2 = "abc";
        if (s1 == s2) begin
            pass_count++;
            $display("Test 5 PASS: Strings equal");
        end else begin
            $display("Test 5 FAIL: Compare unexpected");
        end

        // Test 6: String not equal
        test_count++;
        s1 = "abc";
        s2 = "xyz";
        if (s1 != s2) begin
            pass_count++;
            $display("Test 6 PASS: Strings not equal");
        end else begin
            $display("Test 6 FAIL: Not equal unexpected");
        end

        // Test 7: getc()
        test_count++;
        s1 = "ABCD";
        if (s1.getc(0) == "A") begin
            pass_count++;
            $display("Test 7 PASS: getc(0) = %c", s1.getc(0));
        end else begin
            $display("Test 7 FAIL: getc unexpected");
        end

        // Test 8: putc()
        test_count++;
        s1 = "ABCD";
        s1.putc(1, "X");
        if (s1 == "AXCD") begin
            pass_count++;
            $display("Test 8 PASS: putc = %s", s1);
        end else begin
            $display("Test 8 FAIL: putc unexpected = %s", s1);
        end

        // Test 9: toupper()
        test_count++;
        s1 = "hello";
        result = s1.toupper();
        if (result == "HELLO") begin
            pass_count++;
            $display("Test 9 PASS: toupper = %s", result);
        end else begin
            $display("Test 9 FAIL: toupper unexpected = %s", result);
        end

        // Test 10: tolower()
        test_count++;
        s1 = "HELLO";
        result = s1.tolower();
        if (result == "hello") begin
            pass_count++;
            $display("Test 10 PASS: tolower = %s", result);
        end else begin
            $display("Test 10 FAIL: tolower unexpected = %s", result);
        end

        // Test 11: substr()
        test_count++;
        s1 = "Hello World";
        result = s1.substr(0, 4);
        if (result == "Hello") begin
            pass_count++;
            $display("Test 11 PASS: substr = %s", result);
        end else begin
            $display("Test 11 FAIL: substr unexpected = %s", result);
        end

        // Test 12: atoi()
        test_count++;
        s1 = "123";
        begin
            static int val;
            // Assigned here so the result does not depend on the order of static initializers.
            val = s1.atoi();
            if (val == 123) begin
                pass_count++;
                $display("Test 12 PASS: atoi = %0d", val);
            end else begin
                $display("Test 12 FAIL: atoi unexpected = %0d", val);
            end
        end

        // Test 13: atohex()
        test_count++;
        s1 = "FF";
        begin
            static int val;
            // Assigned here so the result does not depend on the order of static initializers.
            val = s1.atohex();
            if (val == 255) begin
                pass_count++;
                $display("Test 13 PASS: atohex = %0d", val);
            end else begin
                $display("Test 13 FAIL: atohex unexpected = %0d", val);
            end
        end

        // Test 14: itoa()
        test_count++;
        begin
            static int val = 456;
            s1.itoa(val);
            if (s1 == "456") begin
                pass_count++;
                $display("Test 14 PASS: itoa = %s", s1);
            end else begin
                $display("Test 14 FAIL: itoa unexpected = %s", s1);
            end
        end

        // Test 15: hextoa()
        test_count++;
        begin
            static int val = 255;
            s1.hextoa(val);
            if (s1 == "ff" || s1 == "FF") begin
                pass_count++;
                $display("Test 15 PASS: hextoa = %s", s1);
            end else begin
                $display("Test 15 FAIL: hextoa unexpected = %s", s1);
            end
        end

        // Test 16: whether atoi reads a leading minus is not settled: 6.16.9
        // names the sign among the parts of the literal syntax it does not
        // parse, and tools differ. So "-100" may give 0 or -100.
        test_count++;
        s1 = "-100";
        begin
            static int val;
            // Assigned here so the result does not depend on the order of static initializers.
            val = s1.atoi();
            if (val == 0 || val == -100) begin
                pass_count++;
                $display("Test 16 PASS: atoi of \"-100\" is 0 or -100");
            end else begin
                $display("Test 16 FAIL: atoi of \"-100\" = %0d (expected 0 or -100)", val);
            end
        end

        $display("=== String Ops Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
