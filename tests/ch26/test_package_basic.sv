/*
:name: test_package_basic
:description: Package Tests
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.2 26.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_basic.expected
*/
// IEEE 1800-2023 Section 26 - Package Tests
package my_pkg;
    int pkg_var = 100;
    function int double(int x);
        return x * 2;
    endfunction
endpackage

module test_package_basic;
    import my_pkg::*;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int result;

        $display("=== IEEE 1800-2023 Package Tests ===");

        // Test 1: Package variable
        $display("Test 1: Pkg var");
        if (pkg_var == 100) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", pkg_var); fail_count++; end

        // Test 2: Package function
        $display("Test 2: Pkg func");
        result = double(5);
        if (result == 10) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", result); fail_count++; end

        // Test 3: Function chain
        $display("Test 3: Chain");
        result = double(double(3));
        if (result == 12) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", result); fail_count++; end

        // Test 4: Zero
        $display("Test 4: Zero");
        result = double(0);
        if (result == 0) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", result); fail_count++; end

        // Test 5: Negative
        $display("Test 5: Negative");
        result = double(-5);
        if (result == -10) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", result); fail_count++; end

        // Test 6: Large
        $display("Test 6: Large");
        result = double(500);
        if (result == 1000) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", result); fail_count++; end

        // Test 7: One
        $display("Test 7: One");
        result = double(1);
        if (result == 2) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", result); fail_count++; end

        // Test 8: Combined
        $display("Test 8: Combined");
        result = double(pkg_var);
        if (result == 200) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
