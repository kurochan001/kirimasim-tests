/*
:name: test_sscanf_2
:description: $sscanf Test
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sscanf_2.expected
*/
// IEEE 1800-2023 $sscanf Test
// Target: $sscanf - String scanning/parsing
// IEEE 1800-2023 Section 21.3.4

`timescale 1ns/1ps

module test_sscanf;
    int pass_count = 0;
    int fail_count = 0;

    // Helper task
    task automatic check(input string name, input bit condition);
        if (condition) begin
            $display("  PASS: %s", name);
            pass_count++;
        end else begin
            $display("  FAIL: %s", name);
            fail_count++;
        end
    endtask

    initial begin
        int result;
        int int_val;
        int int_val2;
        real real_val;
        string str_val;
        reg [31:0] hex_val;
        reg [31:0] bin_val;

        $display("=== $sscanf Test ===");
        $display("");

        // ===== Test 1: Parse integer =====
        $display("Test 1: Parse integer");
        result = $sscanf("42", "%d", int_val);
        $display("  $sscanf(\"42\", \"%%d\") -> int_val = %0d, returned %0d", int_val, result);
        check("Integer parsed correctly", int_val == 42 && result == 1);

        result = $sscanf("-123", "%d", int_val);
        $display("  $sscanf(\"-123\", \"%%d\") -> int_val = %0d", int_val);
        check("Negative integer parsed", int_val == -123);

        // ===== Test 2: Parse multiple integers =====
        $display("");
        $display("Test 2: Parse multiple integers");
        result = $sscanf("10 20", "%d %d", int_val, int_val2);
        $display("  $sscanf(\"10 20\", \"%%d %%d\") -> %0d, %0d (returned %0d)", int_val, int_val2, result);
        check("Two integers parsed", int_val == 10 && int_val2 == 20 && result == 2);

        // ===== Test 3: Parse hexadecimal =====
        $display("");
        $display("Test 3: Parse hexadecimal");
        result = $sscanf("ff", "%x", hex_val);
        $display("  $sscanf(\"ff\", \"%%x\") -> hex_val = 0x%0h", hex_val);
        check("Hex value parsed", hex_val == 32'hff);

        result = $sscanf("DEADBEEF", "%x", hex_val);
        $display("  $sscanf(\"DEADBEEF\", \"%%x\") -> hex_val = 0x%0h", hex_val);
        check("Large hex value parsed", hex_val == 32'hDEADBEEF);

        // ===== Test 4: Parse binary =====
        $display("");
        $display("Test 4: Parse binary");
        result = $sscanf("1010", "%b", bin_val);
        $display("  $sscanf(\"1010\", \"%%b\") -> bin_val = %0d (0x%0h)", bin_val, bin_val);
        check("Binary value parsed", bin_val == 32'b1010);

        // ===== Test 5: Parse real number =====
        $display("");
        $display("Test 5: Parse real number");
        result = $sscanf("3.14159", "%f", real_val);
        $display("  $sscanf(\"3.14159\", \"%%f\") -> real_val = %0.5f", real_val);
        check("Real number parsed", real_val > 3.14 && real_val < 3.15);

        result = $sscanf("-2.5e3", "%f", real_val);
        $display("  $sscanf(\"-2.5e3\", \"%%f\") -> real_val = %0.1f", real_val);
        check("Scientific notation parsed", real_val < -2400 && real_val > -2600);

        // ===== Test 6: Parse string =====
        $display("");
        $display("Test 6: Parse string");
        result = $sscanf("hello world", "%s", str_val);
        $display("  $sscanf(\"hello world\", \"%%s\") -> str_val = \"%s\"", str_val);
        check("String parsed (first word)", str_val == "hello");

        // ===== Test 7: Mixed format =====
        $display("");
        $display("Test 7: Mixed format parsing");
        result = $sscanf("value=100", "value=%d", int_val);
        $display("  $sscanf(\"value=100\", \"value=%%d\") -> int_val = %0d", int_val);
        check("Mixed format parsed", int_val == 100);

        // ===== Test 8: Return value (number of items matched) =====
        $display("");
        $display("Test 8: Return value");
        result = $sscanf("1 2 3", "%d %d %d", int_val, int_val2, hex_val);
        $display("  $sscanf(\"1 2 3\", \"%%d %%d %%d\") returned %0d", result);
        check("Returns count of matched items", result == 3);

        result = $sscanf("abc", "%d", int_val);
        $display("  $sscanf(\"abc\", \"%%d\") returned %0d (no match)", result);
        check("Returns 0 on no match", result == 0);

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
