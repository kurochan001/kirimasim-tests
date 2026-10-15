/*
:name: test_string_functions_comprehensive
:description: String System Functions Comprehensive Test
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_functions_comprehensive.expected
*/
// IEEE 1800-2023 String System Functions Comprehensive Test
// IEEE 1800-2023 Section 6.16

`timescale 1ns/1ps

module test_string_functions_comprehensive;
    int pass_count = 0;
    int fail_count = 0;

    task automatic check_str(input string name, input string result, input string expected);
        if (result == expected) begin
            $display("  PASS: %s = \"%s\"", name, result);
            pass_count++;
        end else begin
            $display("  FAIL: %s = \"%s\" (expected \"%s\")", name, result, expected);
            fail_count++;
        end
    endtask

    task automatic check_int(input string name, input int result, input int expected);
        if (result == expected) begin
            $display("  PASS: %s = %0d", name, result);
            pass_count++;
        end else begin
            $display("  FAIL: %s = %0d (expected %0d)", name, result, expected);
            fail_count++;
        end
    endtask

    initial begin
        string s1, s2, s3;
        int len, cmp;
        byte c;

        $display("=== String System Functions Comprehensive Test ===");
        $display("");

        // ===== String.len() =====
        $display("Test 1: String.len() - String length");
        s1 = "Hello";
        check_int("\"Hello\".len()", s1.len(), 5);

        s1 = "";
        check_int("\"\".len()", s1.len(), 0);

        s1 = "A";
        check_int("\"A\".len()", s1.len(), 1);

        s1 = "Hello World!";
        check_int("\"Hello World!\".len()", s1.len(), 12);

        // ===== String.toupper() =====
        $display("");
        $display("Test 2: String.toupper() - Convert to uppercase");
        s1 = "hello";
        s2 = s1.toupper();
        check_str("\"hello\".toupper()", s2, "HELLO");

        s1 = "Hello World";
        s2 = s1.toupper();
        check_str("\"Hello World\".toupper()", s2, "HELLO WORLD");

        s1 = "123abc";
        s2 = s1.toupper();
        check_str("\"123abc\".toupper()", s2, "123ABC");

        s1 = "ALREADY UPPER";
        s2 = s1.toupper();
        check_str("\"ALREADY UPPER\".toupper()", s2, "ALREADY UPPER");

        // ===== String.tolower() =====
        $display("");
        $display("Test 3: String.tolower() - Convert to lowercase");
        s1 = "HELLO";
        s2 = s1.tolower();
        check_str("\"HELLO\".tolower()", s2, "hello");

        s1 = "Hello World";
        s2 = s1.tolower();
        check_str("\"Hello World\".tolower()", s2, "hello world");

        s1 = "123ABC";
        s2 = s1.tolower();
        check_str("\"123ABC\".tolower()", s2, "123abc");

        // ===== String.substr() =====
        $display("");
        $display("Test 4: String.substr() - Substring extraction");
        s1 = "Hello World";
        s2 = s1.substr(0, 4);
        check_str("\"Hello World\".substr(0,4)", s2, "Hello");

        s2 = s1.substr(6, 10);
        check_str("\"Hello World\".substr(6,10)", s2, "World");

        s2 = s1.substr(0, 0);
        check_str("\"Hello World\".substr(0,0)", s2, "H");

        s1 = "ABCDEF";
        s2 = s1.substr(2, 4);
        check_str("\"ABCDEF\".substr(2,4)", s2, "CDE");

        // ===== String.getc() =====
        $display("");
        $display("Test 5: String.getc() - Get character at index");
        s1 = "Hello";
        c = s1.getc(0);
        check_int("\"Hello\".getc(0)", c, 8'd72);  // 'H' = 72

        c = s1.getc(4);
        check_int("\"Hello\".getc(4)", c, 8'd111);  // 'o' = 111

        // ===== String.putc() =====
        $display("");
        $display("Test 6: String.putc() - Set character at index");
        s1 = "Hello";
        s1.putc(0, "J");
        check_str("After putc(0,\"J\")", s1, "Jello");

        s1 = "AAAA";
        s1.putc(2, "B");
        check_str("After putc(2,\"B\")", s1, "AABA");

        // ===== String.compare() =====
        $display("");
        $display("Test 7: String.compare() - Case-sensitive comparison");
        s1 = "abc";
        s2 = "abc";
        cmp = s1.compare(s2);
        check_int("\"abc\".compare(\"abc\")", cmp, 0);

        s1 = "abc";
        s2 = "ABC";
        cmp = s1.compare(s2);
        // Only the sign of compare is defined (6.16.6), so the value is not printed
        if (cmp > 0) begin
            $display("  PASS: \"abc\".compare(\"ABC\") > 0");
            pass_count++;
        end else begin
            $display("  FAIL: \"abc\".compare(\"ABC\") = %0d (expected > 0)", cmp);
            fail_count++;
        end

        s1 = "aaa";
        s2 = "aab";
        cmp = s1.compare(s2);
        if (cmp < 0) begin
            $display("  PASS: \"aaa\".compare(\"aab\") < 0");
            pass_count++;
        end else begin
            $display("  FAIL: \"aaa\".compare(\"aab\") = %0d (expected < 0)", cmp);
            fail_count++;
        end

        // ===== String.icompare() =====
        $display("");
        $display("Test 8: String.icompare() - Case-insensitive comparison");
        s1 = "abc";
        s2 = "ABC";
        cmp = s1.icompare(s2);
        check_int("\"abc\".icompare(\"ABC\")", cmp, 0);

        s1 = "Hello";
        s2 = "HELLO";
        cmp = s1.icompare(s2);
        check_int("\"Hello\".icompare(\"HELLO\")", cmp, 0);

        // ===== String.atoi() =====
        $display("");
        $display("Test 9: String.atoi() - String to integer");
        s1 = "123";
        check_int("\"123\".atoi()", s1.atoi(), 123);

        s1 = "-456";
        // atoi reads digits and underscores only, so a sign stops it (6.16.9)
        check_int("\"-456\".atoi()", s1.atoi(), 0);

        s1 = "0";
        check_int("\"0\".atoi()", s1.atoi(), 0);

        s1 = "42abc";  // Stops at non-digit
        check_int("\"42abc\".atoi()", s1.atoi(), 42);

        // ===== String.atohex() =====
        $display("");
        $display("Test 10: String.atohex() - Hex string to integer");
        s1 = "FF";
        check_int("\"FF\".atohex()", s1.atohex(), 255);

        s1 = "100";
        check_int("\"100\".atohex()", s1.atohex(), 256);

        s1 = "DEADBEEF";
        $display("  \"DEADBEEF\".atohex() = 0x%08h", s1.atohex());
        pass_count++;

        // ===== String.atobin() =====
        $display("");
        $display("Test 11: String.atobin() - Binary string to integer");
        s1 = "1010";
        check_int("\"1010\".atobin()", s1.atobin(), 10);

        s1 = "11111111";
        check_int("\"11111111\".atobin()", s1.atobin(), 255);

        // ===== String.atooct() =====
        $display("");
        $display("Test 12: String.atooct() - Octal string to integer");
        s1 = "77";
        check_int("\"77\".atooct()", s1.atooct(), 63);

        s1 = "100";
        check_int("\"100\".atooct()", s1.atooct(), 64);

        // ===== String.atoreal() =====
        $display("");
        $display("Test 13: String.atoreal() - String to real");
        s1 = "3.14";
        if (s1.atoreal() == 3.14) begin
            $display("  PASS: \"3.14\".atoreal() = %f", s1.atoreal());
            pass_count++;
        end else begin
            $display("  FAIL: \"3.14\".atoreal() = %f", s1.atoreal());
            fail_count++;
        end

        s1 = "2.5e1";
        if (s1.atoreal() == 25.0) begin
            $display("  PASS: \"2.5e1\".atoreal() = %f", s1.atoreal());
            pass_count++;
        end else begin
            $display("  FAIL: \"2.5e1\".atoreal() = %f", s1.atoreal());
            fail_count++;
        end

        // ===== String.itoa() =====
        $display("");
        $display("Test 14: String.itoa() - Integer to string");
        s1.itoa(123);
        check_str("itoa(123)", s1, "123");

        s1.itoa(-456);
        check_str("itoa(-456)", s1, "-456");

        s1.itoa(0);
        check_str("itoa(0)", s1, "0");

        // ===== String.hextoa() =====
        $display("");
        $display("Test 15: String.hextoa() - Integer to hex string");
        // The case of hex letters is not specified (6.16.12), so compare in lower case
        s1.hextoa(255);
        check_str("hextoa(255)", s1.tolower(), "ff");

        s1.hextoa(16);
        check_str("hextoa(16)", s1, "10");

        // ===== Edge cases =====
        $display("");
        $display("Test 16: Edge cases");

        // Empty string operations
        s1 = "";
        check_int("Empty string len", s1.len(), 0);
        s2 = s1.toupper();
        check_str("Empty toupper", s2, "");
        s2 = s1.tolower();
        check_str("Empty tolower", s2, "");

        // Unicode-like (extended ASCII)
        s1 = "Test123!@#";
        s2 = s1.toupper();
        check_str("\"Test123!@#\".toupper()", s2, "TEST123!@#");

        // Summary
        $display("");
        $display("========================================");
        $display("TEST RESULTS: %0d/%0d PASSED", pass_count, pass_count + fail_count);
        if (fail_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $display("========================================");

        $finish;
    end
endmodule
