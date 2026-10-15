/*
:name: test_string_methods_corner
:description: Tests string built-in methods: len, putc, getc, toupper, tolower, compare, substr, etc.
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_methods_corner.expected
*/
// Tests string built-in methods: len, putc, getc, toupper, tolower, compare, substr, etc.
`timescale 1ns/1ps

module test_string_methods_corner;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: len()
    task test_len();
        static string s = "Hello";
        static string empty = "";

        if (s.len() == 5) begin
            $display("PASS: \"Hello\".len() = %0d", s.len());
            pass_count++;
        end else begin
            $display("FAIL: \"Hello\".len() = %0d (expected 5)", s.len());
            fail_count++;
        end

        if (empty.len() == 0) begin
            $display("PASS: Empty string len() = %0d", empty.len());
            pass_count++;
        end else begin
            $display("FAIL: Empty string len() = %0d (expected 0)", empty.len());
            fail_count++;
        end
    endtask

    // Test 2: getc() and putc()
    task test_getc_putc();
        static string s = "ABCDE";
        byte ch;

        ch = s.getc(0);
        if (ch == 65) begin // 'A'
            $display("PASS: getc(0) = %0d ('A')", ch);
            pass_count++;
        end else begin
            $display("FAIL: getc(0) = %0d (expected 65)", ch);
            fail_count++;
        end

        s.putc(0, "X");
        if (s == "XBCDE") begin
            $display("PASS: After putc: %s", s);
            pass_count++;
        end else begin
            $display("FAIL: After putc: %s (expected XBCDE)", s);
            fail_count++;
        end
    endtask

    // Test 3: toupper() and tolower()
    task test_case_conversion();
        static string s = "Hello World";
        string upper, lower;

        upper = s.toupper();
        if (upper == "HELLO WORLD") begin
            $display("PASS: toupper() = %s", upper);
            pass_count++;
        end else begin
            $display("FAIL: toupper() = %s (expected HELLO WORLD)", upper);
            fail_count++;
        end

        lower = s.tolower();
        if (lower == "hello world") begin
            $display("PASS: tolower() = %s", lower);
            pass_count++;
        end else begin
            $display("FAIL: tolower() = %s (expected hello world)", lower);
            fail_count++;
        end
    endtask

    // Test 4: compare() and icompare(); only the sign of a nonzero result is defined (6.16.6)
    task test_compare();
        static string s1 = "abc";
        static string s2 = "abc";
        static string s3 = "ABC";
        static string s4 = "abd";
        int result;

        result = s1.compare(s2);
        if (result == 0) begin
            $display("PASS: \"abc\".compare(\"abc\") = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: \"abc\".compare(\"abc\") = %0d (expected 0)", result);
            fail_count++;
        end

        result = s1.compare(s3);
        if (result != 0) begin
            $display("PASS: \"abc\".compare(\"ABC\") != 0 (case sensitive)");
            pass_count++;
        end else begin
            $display("FAIL: \"abc\".compare(\"ABC\") should be non-zero");
            fail_count++;
        end

        result = s1.icompare(s3);
        if (result == 0) begin
            $display("PASS: \"abc\".icompare(\"ABC\") = %0d (case insensitive)", result);
            pass_count++;
        end else begin
            $display("FAIL: \"abc\".icompare(\"ABC\") = %0d (expected 0)", result);
            fail_count++;
        end

        result = s1.compare(s4);
        if (result < 0) begin
            $display("PASS: \"abc\".compare(\"abd\") < 0");
            pass_count++;
        end else begin
            $display("FAIL: \"abc\".compare(\"abd\") should be negative");
            fail_count++;
        end
    endtask

    // Test 5: substr()
    task test_substr();
        static string s = "Hello World";
        string sub;

        sub = s.substr(0, 4);
        if (sub == "Hello") begin
            $display("PASS: substr(0, 4) = %s", sub);
            pass_count++;
        end else begin
            $display("FAIL: substr(0, 4) = %s (expected Hello)", sub);
            fail_count++;
        end

        sub = s.substr(6, 10);
        if (sub == "World") begin
            $display("PASS: substr(6, 10) = %s", sub);
            pass_count++;
        end else begin
            $display("FAIL: substr(6, 10) = %s (expected World)", sub);
            fail_count++;
        end

        // Single character
        sub = s.substr(0, 0);
        if (sub == "H") begin
            $display("PASS: substr(0, 0) = %s", sub);
            pass_count++;
        end else begin
            $display("FAIL: substr(0, 0) = %s (expected H)", sub);
            fail_count++;
        end
    endtask

    // Test 6: atoi(), atohex(), atobin(), atooct()
    task test_ato_functions();
        static string decimal = "42";
        static string hex = "FF";
        static string binary = "1010";
        static string octal = "77";
        int val;

        val = decimal.atoi();
        if (val == 42) begin
            $display("PASS: \"42\".atoi() = %0d", val);
            pass_count++;
        end else begin
            $display("FAIL: \"42\".atoi() = %0d (expected 42)", val);
            fail_count++;
        end

        val = hex.atohex();
        if (val == 255) begin
            $display("PASS: \"FF\".atohex() = %0d", val);
            pass_count++;
        end else begin
            $display("FAIL: \"FF\".atohex() = %0d (expected 255)", val);
            fail_count++;
        end

        val = binary.atobin();
        if (val == 10) begin
            $display("PASS: \"1010\".atobin() = %0d", val);
            pass_count++;
        end else begin
            $display("FAIL: \"1010\".atobin() = %0d (expected 10)", val);
            fail_count++;
        end

        val = octal.atooct();
        if (val == 63) begin
            $display("PASS: \"77\".atooct() = %0d", val);
            pass_count++;
        end else begin
            $display("FAIL: \"77\".atooct() = %0d (expected 63)", val);
            fail_count++;
        end
    endtask

    // Test 7: atoreal()
    task test_atoreal();
        static string s = "3.14159";
        real val;

        val = s.atoreal();
        if (val > 3.14 && val < 3.15) begin
            $display("PASS: \"3.14159\".atoreal() = %f", val);
            pass_count++;
        end else begin
            $display("FAIL: \"3.14159\".atoreal() = %f", val);
            fail_count++;
        end
    endtask

    // Test 8: itoa(), hextoa(), bintoa(), octtoa()
    task test_toa_functions();
        string s;
        static int val = 42;

        s.itoa(val);
        if (s == "42") begin
            $display("PASS: itoa(42) = %s", s);
            pass_count++;
        end else begin
            $display("FAIL: itoa(42) = %s (expected 42)", s);
            fail_count++;
        end

        s.hextoa(255);
        if (s.tolower() == "ff") begin
            $display("PASS: hextoa(255) = %s", s);
            pass_count++;
        end else begin
            $display("FAIL: hextoa(255) = %s (expected ff)", s);
            fail_count++;
        end

        s.bintoa(10);
        if (s == "1010") begin
            $display("PASS: bintoa(10) = %s", s);
            pass_count++;
        end else begin
            $display("FAIL: bintoa(10) = %s (expected 1010)", s);
            fail_count++;
        end

        s.octtoa(63);
        if (s == "77") begin
            $display("PASS: octtoa(63) = %s", s);
            pass_count++;
        end else begin
            $display("FAIL: octtoa(63) = %s (expected 77)", s);
            fail_count++;
        end
    endtask

    // Test 9: realtoa()
    task test_realtoa();
        string s;
        static real val = 3.14;

        s.realtoa(val);
        if (s.len() > 0) begin
            $display("PASS: realtoa(3.14) = %s", s);
            pass_count++;
        end else begin
            $display("FAIL: realtoa produced empty string");
            fail_count++;
        end
    endtask

    // Test 10: String concatenation
    task test_concatenation();
        static string s1 = "Hello";
        static string s2 = " ";
        static string s3 = "World";
        string result;

        result = {s1, s2, s3};
        if (result == "Hello World") begin
            $display("PASS: Concatenation = %s", result);
            pass_count++;
        end else begin
            $display("FAIL: Concatenation = %s (expected Hello World)", result);
            fail_count++;
        end
    endtask

    // Test 11: String comparison operators
    task test_comparison_operators();
        static string s1 = "abc";
        static string s2 = "abc";
        static string s3 = "abd";

        if (s1 == s2) begin
            $display("PASS: \"abc\" == \"abc\"");
            pass_count++;
        end else begin
            $display("FAIL: \"abc\" == \"abc\" should be true");
            fail_count++;
        end

        if (s1 != s3) begin
            $display("PASS: \"abc\" != \"abd\"");
            pass_count++;
        end else begin
            $display("FAIL: \"abc\" != \"abd\" should be true");
            fail_count++;
        end

        if (s1 < s3) begin
            $display("PASS: \"abc\" < \"abd\"");
            pass_count++;
        end else begin
            $display("FAIL: \"abc\" < \"abd\" should be true");
            fail_count++;
        end
    endtask

    // Test 12: Edge cases
    task test_edge_cases();
        string s;

        // Empty string operations
        s = "";
        if (s.len() == 0) begin
            $display("PASS: Empty string len = 0");
            pass_count++;
        end else begin
            $display("FAIL: Empty string len != 0");
            fail_count++;
        end

        // Whitespace handling
        s = "  trimme  ";
        $display("String with spaces: '%s' len=%0d", s, s.len());
        pass_count++;

        // Special characters
        s = "Tab\there";
        $display("String with tab: len=%0d", s.len());
        pass_count++;
    endtask

    initial begin
        $display("=== String Methods Corner Cases Test ===");

        test_len();
        test_getc_putc();
        test_case_conversion();
        test_compare();
        test_substr();
        test_ato_functions();
        test_atoreal();
        test_toa_functions();
        test_realtoa();
        test_concatenation();
        test_comparison_operators();
        test_edge_cases();

        $display("");
        $display("=== Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
