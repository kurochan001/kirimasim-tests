/*
:name: test_func_basic
:description: Function Basic Tests
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 13.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_func_basic.expected
*/
// IEEE 1800-2023 Section 13 - Function Basic Tests
module test_func_basic;
    int pass_count = 0;
    int fail_count = 0;

    function int add(int a, int b);
        return a + b;
    endfunction

    function int mult(int a, int b);
        return a * b;
    endfunction

    function int max(int a, int b);
        if (a > b) return a;
        else return b;
    endfunction

    // Recursive, so automatic: a static function shares n between calls (13.4.2).
    function automatic int factorial(int n);
        if (n <= 1) return 1;
        else return n * factorial(n - 1);
    endfunction

    initial begin
        int result;

        $display("=== IEEE 1800-2023 Function Basic Tests ===");

        // Test 1: Add function
        $display("Test 1: Add");
        result = add(3, 4);
        if (result == 7) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", result); fail_count++; end

        // Test 2: Mult function
        $display("Test 2: Mult");
        result = mult(5, 6);
        if (result == 30) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", result); fail_count++; end

        // Test 3: Max first
        $display("Test 3: Max first");
        result = max(10, 5);
        if (result == 10) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", result); fail_count++; end

        // Test 4: Max second
        $display("Test 4: Max second");
        result = max(3, 8);
        if (result == 8) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", result); fail_count++; end

        // Test 5: Factorial 5
        $display("Test 5: Factorial 5");
        result = factorial(5);
        if (result == 120) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", result); fail_count++; end

        // Test 6: Factorial 1
        $display("Test 6: Factorial 1");
        result = factorial(1);
        if (result == 1) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", result); fail_count++; end

        // Test 7: Nested call
        $display("Test 7: Nested");
        result = add(mult(2, 3), 4);
        if (result == 10) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", result); fail_count++; end

        // Test 8: Zero args
        $display("Test 8: Zero");
        result = add(0, 0);
        if (result == 0) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
