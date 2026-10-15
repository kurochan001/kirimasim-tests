/*
:name: test_string_operations
:description: String Operations Extended Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_operations.expected
*/
// IEEE 1800-2023 Section 6.16 - String Operations Extended Tests
// Tests: string methods, comparisons, conversions

module test_string_operations;
    int pass_count = 0;
    int fail_count = 0;

    string s1, s2, s3;
    int len;
    byte c;
    int result;

    initial begin
        $display("=== IEEE 1800-2023 String Operations Test ===");

        // Test 1: String assignment
        $display("Test 1: String assignment");
        s1 = "Hello";
        if (s1 == "Hello") begin
            $display("Test 1 PASS: s1 = %s", s1);
            pass_count++;
        end else begin
            $display("Test 1 FAIL");
            fail_count++;
        end

        // Test 2: String length
        $display("Test 2: String length");
        len = s1.len();
        if (len == 5) begin
            $display("Test 2 PASS: len = %0d", len);
            pass_count++;
        end else begin
            $display("Test 2 FAIL");
            fail_count++;
        end

        // Test 3: String concatenation
        $display("Test 3: String concatenation");
        s2 = " World";
        s3 = {s1, s2};
        if (s3 == "Hello World") begin
            $display("Test 3 PASS: s3 = %s", s3);
            pass_count++;
        end else begin
            $display("Test 3 FAIL");
            fail_count++;
        end

        // Test 4: String comparison
        $display("Test 4: String comparison");
        s1 = "abc";
        s2 = "abc";
        if (s1 == s2) begin
            $display("Test 4 PASS: strings equal");
            pass_count++;
        end else begin
            $display("Test 4 FAIL: strings differ");
            fail_count++;
        end

        // Test 5: String compare method
        $display("Test 5: compare method");
        s1 = "apple";
        s2 = "banana";
        result = s1.compare(s2);
        if (result < 0) begin
            $display("Test 5 PASS: compare result < 0");
            pass_count++;
        end else begin
            $display("Test 5 FAIL");
            fail_count++;
        end

        // Test 6: icompare (case insensitive)
        $display("Test 6: icompare method");
        s1 = "Hello";
        s2 = "hello";
        result = s1.icompare(s2);
        if (result == 0) begin
            $display("Test 6 PASS: icompare result == 0");
            pass_count++;
        end else begin
            $display("Test 6 FAIL");
            fail_count++;
        end

        // Test 7: getc method
        $display("Test 7: getc method");
        s1 = "Test";
        c = s1.getc(0);
        if (c == "T") begin
            $display("Test 7 PASS: first char = %c (%0d)", c, c);
            pass_count++;
        end else begin
            $display("Test 7 FAIL");
            fail_count++;
        end

        // Test 8: toupper
        $display("Test 8: toupper method");
        s1 = "hello world";
        s2 = s1.toupper();
        if (s2 == "HELLO WORLD") begin
            $display("Test 8 PASS: upper = %s", s2);
            pass_count++;
        end else begin
            $display("Test 8 FAIL");
            fail_count++;
        end

        // Test 9: tolower
        $display("Test 9: tolower method");
        s1 = "HELLO WORLD";
        s2 = s1.tolower();
        if (s2 == "hello world") begin
            $display("Test 9 PASS: lower = %s", s2);
            pass_count++;
        end else begin
            $display("Test 9 FAIL");
            fail_count++;
        end

        // Test 10: substr
        $display("Test 10: substr method");
        s1 = "Hello World";
        s2 = s1.substr(0, 4);
        if (s2 == "Hello") begin
            $display("Test 10 PASS: substr = %s", s2);
            pass_count++;
        end else begin
            $display("Test 10 FAIL");
            fail_count++;
        end

        // Test 11: putc method
        $display("Test 11: putc method");
        s1 = "Test";
        s1.putc(0, "X");
        if (s1 == "Xest") begin
            $display("Test 11 PASS: after putc = %s", s1);
            pass_count++;
        end else begin
            $display("Test 11 FAIL");
            fail_count++;
        end

        // Test 12: atoi conversion
        $display("Test 12: atoi conversion");
        s1 = "12345";
        result = s1.atoi();
        if (result == 12345) begin
            $display("Test 12 PASS: atoi = %0d", result);
            pass_count++;
        end else begin
            $display("Test 12 FAIL");
            fail_count++;
        end

        // Test 13: atohex conversion
        $display("Test 13: atohex conversion");
        s1 = "FF";
        result = s1.atohex();
        if (result == 255) begin
            $display("Test 13 PASS: atohex = %0d (0x%0h)", result, result);
            pass_count++;
        end else begin
            $display("Test 13 FAIL");
            fail_count++;
        end

        // Test 14: atobin conversion
        $display("Test 14: atobin conversion");
        s1 = "1010";
        result = s1.atobin();
        if (result == 10) begin
            $display("Test 14 PASS: atobin = %0d", result);
            pass_count++;
        end else begin
            $display("Test 14 FAIL");
            fail_count++;
        end

        // Test 15: itoa conversion
        $display("Test 15: itoa conversion");
        s1.itoa(255);
        if (s1 == "255") begin
            $display("Test 15 PASS: itoa = %s", s1);
            pass_count++;
        end else begin
            $display("Test 15 FAIL");
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
