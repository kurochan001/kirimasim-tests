/*
:name: test_scanf_comprehensive
:description: Scanf Comprehensive Tests
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_scanf_comprehensive.expected
*/
// IEEE 1800-2023 Section 21.3.4.3 - Scanf Comprehensive Tests
// Tests: $sscanf various format specifiers

module test_scanf_comprehensive;
    int pass_count = 0;
    int fail_count = 0;

    string input_str;
    int i_val1, i_val2, i_val3;
    real r_val;
    string s_val;
    logic [31:0] l_val;
    int result;

    initial begin
        $display("=== IEEE 1800-2023 Scanf Comprehensive Test ===");

        // Test 1: Multiple integers
        $display("Test 1: Multiple integers");
        input_str = "10 20 30";
        result = $sscanf(input_str, "%d %d %d", i_val1, i_val2, i_val3);
        if (result == 3 && i_val1 == 10 && i_val2 == 20 && i_val3 == 30) begin
            $display("Test 1 PASS: %0d %0d %0d (count=%0d)", i_val1, i_val2, i_val3, result);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: %0d %0d %0d (count=%0d)", i_val1, i_val2, i_val3, result);
            fail_count++;
        end

        // Test 2: Hex value
        $display("Test 2: Hex value");
        input_str = "DEADBEEF";
        result = $sscanf(input_str, "%h", l_val);
        $display("Test 2 PASS: l_val=%h (count=%0d)", l_val, result);
        pass_count++;

        // Test 3: Octal value
        $display("Test 3: Octal value");
        input_str = "777";
        result = $sscanf(input_str, "%o", i_val1);
        $display("Test 3 PASS: i_val=%0d (octal 777=%0d, count=%0d)", i_val1, 9'o777, result);
        pass_count++;

        // Test 4: Binary value
        $display("Test 4: Binary value");
        input_str = "10101010";
        result = $sscanf(input_str, "%b", l_val);
        $display("Test 4 PASS: l_val=%b (count=%0d)", l_val, result);
        pass_count++;

        // Test 5: Real value
        $display("Test 5: Real value");
        input_str = "3.14159";
        result = $sscanf(input_str, "%f", r_val);
        $display("Test 5 PASS: r_val=%f (count=%0d)", r_val, result);
        pass_count++;

        // Test 6: String value
        $display("Test 6: String value");
        input_str = "hello_world";
        result = $sscanf(input_str, "%s", s_val);
        $display("Test 6 PASS: s_val=%s (count=%0d)", s_val, result);
        pass_count++;

        // Test 7: Mixed formats
        $display("Test 7: Mixed formats");
        input_str = "42 3.14 text";
        result = $sscanf(input_str, "%d %f %s", i_val1, r_val, s_val);
        $display("Test 7 PASS: %0d %f %s (count=%0d)", i_val1, r_val, s_val, result);
        pass_count++;

        // Test 8: Character format
        $display("Test 8: Character format");
        input_str = "ABC";
        result = $sscanf(input_str, "%c%c%c", i_val1, i_val2, i_val3);
        $display("Test 8 PASS: %c%c%c (count=%0d)", i_val1, i_val2, i_val3, result);
        pass_count++;

        // Test 9: Exponential notation
        $display("Test 9: Exponential notation");
        input_str = "1.23e-4";
        result = $sscanf(input_str, "%e", r_val);
        $display("Test 9 PASS: r_val=%e (count=%0d)", r_val, result);
        pass_count++;

        // Test 10: Width specifier
        $display("Test 10: Width specifier");
        input_str = "12345678";
        result = $sscanf(input_str, "%4d%4d", i_val1, i_val2);
        $display("Test 10 PASS: %0d %0d (count=%0d)", i_val1, i_val2, result);
        pass_count++;

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
