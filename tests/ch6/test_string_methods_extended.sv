/*
:name: test_string_methods_extended
:description: Extended String Methods Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.8 6.16.3 6.16.2 6.16.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_methods_extended.expected
*/
// IEEE 1800-2023 Section 6.16 - Extended String Methods Tests
// Tests: substr, getc, putc, toupper, tolower, compare, icompare

module test_string_methods_extended;
    int pass_count = 0;
    int fail_count = 0;

    string s1, s2, result;
    int cmp_result;
    byte ch;

    initial begin
        $display("=== IEEE 1800-2023 Extended String Methods Tests ===");

        // Test 1: substr method (note: end index inclusive per IEEE 1800-2023)
        $display("Test 1: substr method");
        s1 = "Hello World";
        // substr(i, j) takes positions i through j (6.16.8): 6 characters
        result = s1.substr(0, 5);
        if (result == "Hello ") begin
            $display("Test 1 PASS: '%s' (len=%0d)", result, result.len());
            pass_count++;
        end else begin
            $display("Test 1 FAIL: '%s'", result);
            fail_count++;
        end

        // Test 2: getc method
        $display("Test 2: getc method");
        s1 = "ABC";
        ch = s1.getc(0);
        if (ch == 65) begin  // ASCII 'A'
            $display("Test 2 PASS: ch=%0d ('%c')", ch, ch);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: ch=%0d", ch);
            fail_count++;
        end

        // Test 3: putc method
        $display("Test 3: putc method");
        s1 = "ABC";
        s1.putc(1, "X");
        if (s1 == "AXC") begin
            $display("Test 3 PASS: '%s'", s1);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: '%s'", s1);
            fail_count++;
        end

        // Test 4: toupper method
        $display("Test 4: toupper method");
        s1 = "hello";
        result = s1.toupper();
        if (result == "HELLO") begin
            $display("Test 4 PASS: '%s'", result);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: '%s'", result);
            fail_count++;
        end

        // Test 5: tolower method
        $display("Test 5: tolower method");
        s1 = "WORLD";
        result = s1.tolower();
        if (result == "world") begin
            $display("Test 5 PASS: '%s'", result);
            pass_count++;
        end else begin
            $display("Test 5 FAIL: '%s'", result);
            fail_count++;
        end

        // Test 6: compare method
        $display("Test 6: compare method");
        s1 = "abc";
        s2 = "abc";
        cmp_result = s1.compare(s2);
        if (cmp_result == 0) begin
            $display("Test 6 PASS: compare=%0d", cmp_result);
            pass_count++;
        end else begin
            $display("Test 6 FAIL: compare=%0d", cmp_result);
            fail_count++;
        end

        // Test 7: compare different strings
        $display("Test 7: compare different strings");
        s1 = "abc";
        s2 = "abd";
        cmp_result = s1.compare(s2);
        if (cmp_result != 0) begin
            $display("Test 7 PASS: compare=%0d", cmp_result);
            pass_count++;
        end else begin
            $display("Test 7 FAIL");
            fail_count++;
        end

        // Test 8: len method
        $display("Test 8: len method");
        s1 = "Test123";
        if (s1.len() == 7) begin
            $display("Test 8 PASS: len=%0d", s1.len());
            pass_count++;
        end else begin
            $display("Test 8 FAIL");
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
