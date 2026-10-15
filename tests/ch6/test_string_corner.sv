/*
:name: test_string_corner
:description: Tests string methods, comparisons, and special characters
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16 6.16.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_corner.expected
*/
// Tests string methods, comparisons, and special characters
`timescale 1ns/1ps

module test_string_corner;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: String length
    task test_string_length();
        static string s = "Hello";

        if (s.len() == 5) begin
            $display("PASS: String length works");
            pass_count++;
        end else begin
            $display("FAIL: String length failed (len=%0d)", s.len());
            fail_count++;
        end
    endtask

    // Test 2: String concatenation
    task test_string_concat();
        static string a = "Hello";
        static string b = " World";
        string c;

        c = {a, b};

        if (c == "Hello World") begin
            $display("PASS: String concatenation works");
            pass_count++;
        end else begin
            $display("FAIL: String concatenation failed");
            fail_count++;
        end
    endtask

    // Test 3: String comparison
    task test_string_comparison();
        static string a = "abc";
        static string b = "abc";
        static string c = "abd";

        if (a == b && a != c && a < c) begin
            $display("PASS: String comparison works");
            pass_count++;
        end else begin
            $display("FAIL: String comparison failed");
            fail_count++;
        end
    endtask

    // Test 4: Substr
    task test_substr();
        static string s = "Hello World";
        string sub;

        sub = s.substr(0, 4);

        if (sub == "Hello") begin
            $display("PASS: String substr works");
            pass_count++;
        end else begin
            $display("FAIL: String substr failed (sub=%s)", sub);
            fail_count++;
        end
    endtask

    // Test 5: getc
    task test_getc();
        static string s = "ABC";
        byte c;

        c = s.getc(1);

        if (c == "B") begin
            $display("PASS: String getc works");
            pass_count++;
        end else begin
            $display("FAIL: String getc failed");
            fail_count++;
        end
    endtask

    // Test 6: toupper/tolower
    task test_case_conversion();
        static string s = "Hello World";
        string upper, lower;

        upper = s.toupper();
        lower = s.tolower();

        if (upper == "HELLO WORLD" && lower == "hello world") begin
            $display("PASS: String case conversion works");
            pass_count++;
        end else begin
            $display("FAIL: Case conversion (upper=%s)", upper);
            fail_count++;
        end
    endtask

    // Test 7: atoi/atohex
    task test_string_to_number();
        static string dec_str = "42";
        static string hex_str = "FF";
        int dec_val;
        int hex_val;

        dec_val = dec_str.atoi();
        hex_val = hex_str.atohex();

        if (dec_val == 42 && hex_val == 255) begin
            $display("PASS: String to number conversion works");
            pass_count++;
        end else begin
            $display("FAIL: String to number (dec=%0d, hex=%0d)", dec_val, hex_val);
            fail_count++;
        end
    endtask

    // Test 8: itoa
    task test_number_to_string();
        static int val = 123;
        string s;

        s.itoa(val);

        if (s == "123") begin
            $display("PASS: Number to string conversion works");
            pass_count++;
        end else begin
            $display("FAIL: Number to string failed (s=%s)", s);
            fail_count++;
        end
    endtask

    // Test 9: Empty string operations
    task test_empty_string_ops();
        static string empty = "";
        int len;
        string sub;

        len = empty.len();

        if (len == 0) begin
            $display("PASS: Empty string length is 0");
            pass_count++;
        end else begin
            $display("FAIL: Empty string length wrong");
            fail_count++;
        end
    endtask

    // Test 10: String with special characters
    task test_special_chars();
        static string s = "Tab\tNewline\nQuote\"";

        if (s.len() > 0) begin
            $display("PASS: String with special characters works");
            pass_count++;
        end else begin
            $display("FAIL: Special character string failed");
            fail_count++;
        end
    endtask

    // Test 11: String replication
    task test_string_replication();
        static string s = "ab";
        string result;

        result = {3{s}};

        if (result == "ababab") begin
            $display("PASS: String replication works");
            pass_count++;
        end else begin
            $display("FAIL: String replication failed (result=%s)", result);
            fail_count++;
        end
    endtask

    // Test 12: String assignment
    task test_string_assignment();
        static string a = "first";
        string b;

        b = a;
        a = "second";

        if (b == "first" && a == "second") begin
            $display("PASS: String assignment creates copy");
            pass_count++;
        end else begin
            $display("FAIL: String assignment failed");
            fail_count++;
        end
    endtask

    // Test 13: String in expression
    task test_string_expression();
        static string prefix = "test_";
        static string name = "module";
        string full_name;

        full_name = {prefix, name, "_v1"};

        if (full_name == "test_module_v1") begin
            $display("PASS: String expression works");
            pass_count++;
        end else begin
            $display("FAIL: String expression failed");
            fail_count++;
        end
    endtask

    // Test 14: putc
    task test_putc();
        static string s = "ABC";

        s.putc(1, "X");

        if (s == "AXC") begin
            $display("PASS: String putc works");
            pass_count++;
        end else begin
            $display("FAIL: String putc failed (s=%s)", s);
            fail_count++;
        end
    endtask

    initial begin
        $display("=== String Corner Cases Test ===");

        test_string_length();
        test_string_concat();
        test_string_comparison();
        test_substr();
        test_getc();
        test_case_conversion();
        test_string_to_number();
        test_number_to_string();
        test_empty_string_ops();
        test_special_chars();
        test_string_replication();
        test_string_assignment();
        test_string_expression();
        test_putc();

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
