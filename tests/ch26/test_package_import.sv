/*
:name: test_package_import
:description: Package and Import Tests
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_import.expected
*/
// IEEE 1800-2023 Section 26 - Package and Import Tests
// Tests: packages, imports, exports

package math_pkg;
    function int add(int a, int b);
        return a + b;
    endfunction

    function int multiply(int a, int b);
        return a * b;
    endfunction

    parameter int PI_INT = 3;
    parameter int MAX_VALUE = 255;
endpackage

package util_pkg;
    function int clamp(int value, int min_val, int max_val);
        if (value < min_val) return min_val;
        if (value > max_val) return max_val;
        return value;
    endfunction

    function int abs_val(int value);
        return (value < 0) ? -value : value;
    endfunction
endpackage

module test_package_import;
    import math_pkg::*;
    import util_pkg::clamp;
    import util_pkg::abs_val;

    int pass_count = 0;
    int fail_count = 0;

    int result;

    initial begin
        $display("=== IEEE 1800-2023 Package and Import Test ===");

        // Test 1: Package function call
        $display("Test 1: Package function - add");
        result = add(10, 20);
        $display("  add(10, 20) = %0d", result);
        $display("Test 1 PASS");
        pass_count++;

        // Test 2: Another package function
        $display("Test 2: Package function - multiply");
        result = multiply(5, 7);
        $display("  multiply(5, 7) = %0d", result);
        $display("Test 2 PASS");
        pass_count++;

        // Test 3: Package parameter
        $display("Test 3: Package parameter");
        $display("  PI_INT = %0d", PI_INT);
        $display("  MAX_VALUE = %0d", MAX_VALUE);
        $display("Test 3 PASS");
        pass_count++;

        // Test 4: Selective import
        $display("Test 4: Selective import - clamp");
        result = clamp(150, 0, 100);
        $display("  clamp(150, 0, 100) = %0d", result);
        result = clamp(-10, 0, 100);
        $display("  clamp(-10, 0, 100) = %0d", result);
        $display("Test 4 PASS");
        pass_count++;

        // Test 5: abs_val function
        $display("Test 5: abs_val function");
        result = abs_val(-42);
        $display("  abs_val(-42) = %0d", result);
        result = abs_val(42);
        $display("  abs_val(42) = %0d", result);
        $display("Test 5 PASS");
        pass_count++;

        // Test 6: Combined operations
        $display("Test 6: Combined package operations");
        result = add(multiply(3, 4), multiply(2, 5));
        $display("  add(multiply(3,4), multiply(2,5)) = %0d", result);
        $display("Test 6 PASS");
        pass_count++;

        // Test 7: Clamp with package parameter
        $display("Test 7: Clamp with MAX_VALUE");
        result = clamp(300, 0, MAX_VALUE);
        $display("  clamp(300, 0, MAX_VALUE) = %0d", result);
        $display("Test 7 PASS");
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
