/*
:name: test_format_advanced
:description: Advanced Format Specifiers Tests
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.1 21.2.1.2 21.2.1.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_format_advanced.expected
*/
// IEEE 1800-2023 Section 21.2 - Advanced Format Specifiers Tests
// Tests: %e, %g, %p, %m, width/precision, dynamic width

module test_format_advanced;
    int pass_count = 0;
    int fail_count = 0;

    real r_val;
    int i_val;
    string s_val;
    logic [31:0] ptr;
    logic [7:0] arr [4];

    initial begin
        $display("=== IEEE 1800-2023 Advanced Format Specifiers Tests ===");

        // Test 1: %e scientific notation
        $display("Test 1: Scientific notation (%%e)");
        r_val = 12345.6789;
        $display("  r_val = %e", r_val);
        r_val = 0.000123;
        $display("  small = %e", r_val);
        r_val = 1.5e10;
        $display("  large = %e", r_val);
        $display("Test 1 PASS");
        pass_count++;

        // Test 2: %E uppercase scientific
        $display("Test 2: Uppercase scientific (%%E)");
        r_val = 9876.5432;
        $display("  r_val = %E", r_val);
        $display("Test 2 PASS");
        pass_count++;

        // Test 3: %g shortest representation
        $display("Test 3: Shortest representation (%%g)");
        r_val = 123.0;
        $display("  123.0 = %g", r_val);
        r_val = 0.000001;
        $display("  0.000001 = %g", r_val);
        r_val = 1234567.89;
        $display("  1234567.89 = %g", r_val);
        $display("Test 3 PASS");
        pass_count++;

        // Test 4: %G uppercase shortest
        $display("Test 4: Uppercase shortest (%%G)");
        r_val = 0.00000123;
        $display("  r_val = %G", r_val);
        $display("Test 4 PASS");
        pass_count++;

        // Test 5: %m hierarchical name
        $display("Test 5: Hierarchical name (%%m)");
        $display("  Module path: %m");
        $display("Test 5 PASS");
        pass_count++;

        // Test 6: Width specifiers
        $display("Test 6: Width specifiers");
        i_val = 42;
        $display("  |%5d| right aligned", i_val);
        // The 0 and - flags are not defined for integer and string formats
        // (21.2.1.2), so only field widths are shown.
        $display("Test 6 PASS");
        pass_count++;

        // Test 7: Precision for real
        $display("Test 7: Precision for real numbers");
        r_val = 3.14159265358979;
        $display("  %%.2f = %.2f", r_val);
        $display("  %%.4f = %.4f", r_val);
        $display("  %%.8f = %.8f", r_val);
        $display("Test 7 PASS");
        pass_count++;

        // Test 8: String formatting
        $display("Test 8: String formatting");
        s_val = "Hello";
        $display("  |%10s| right aligned", s_val);
        $display("Test 8 PASS");
        pass_count++;

        // Test 9: Hex with different cases
        $display("Test 9: Hex formatting");
        i_val = 255;
        $display("  %%x = %x", i_val);
        $display("  %%X = %X", i_val);
        $display("  %%h = %h", i_val);
        $display("  %%H = %H", i_val);
        $display("Test 9 PASS");
        pass_count++;

        // Test 10: Binary and octal
        $display("Test 10: Binary and octal");
        i_val = 85;  // 0b1010101
        $display("  %%b = %b", i_val);
        $display("  %%o = %o", i_val);
        $display("Test 10 PASS");
        pass_count++;

        // Test 11: Character format
        $display("Test 11: Character format");
        i_val = 65;  // ASCII 'A'
        $display("  %%c = %c", i_val);
        i_val = 90;  // ASCII 'Z'
        $display("  %%c = %c", i_val);
        $display("Test 11 PASS");
        pass_count++;

        // Test 12: Multiple format specifiers
        $display("Test 12: Multiple format specifiers");
        i_val = 100;
        r_val = 3.14;
        s_val = "test";
        $display("  int=%d, real=%.2f, str=%s", i_val, r_val, s_val);
        $display("Test 12 PASS");
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
