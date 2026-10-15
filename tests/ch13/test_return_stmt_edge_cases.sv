/*
:name: test_return_stmt_edge_cases
:description: Test: Return statement edge cases
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_return_stmt_edge_cases.expected
*/
// Test: Return statement edge cases
// IEEE 1800-2023 Section 13.4 Function Return Values
// Tests corner cases: return in functions

`timescale 1ns/1ps

module test_return_stmt_edge_cases;
    int passed = 0;
    int failed = 0;

    // Function returning int
    function automatic int add(int a, int b);
        return a + b;
    endfunction

    // Function with early return
    function automatic int abs_val(int x);
        if (x < 0) return -x;
        return x;
    endfunction

    // Function with condition
    function automatic int max_val(int a, int b);
        if (a > b) return a;
        return b;
    endfunction

    // Function returning logic
    function automatic logic [7:0] double_val(logic [7:0] x);
        return x * 2;
    endfunction

    // Function with multiple conditions
    function automatic int sign(int x);
        if (x > 0) return 1;
        if (x < 0) return -1;
        return 0;
    endfunction

    initial begin
        $display("TEST: Return statement edge cases");

        // Test 1: Simple return
        begin
            static int result = add(10, 20);
            if (result == 30) begin
                $display("  [PASS] Simple return");
                passed++;
            end else begin
                $display("  [FAIL] Simple: %0d", result);
                failed++;
            end
        end

        // Test 2: Abs positive
        begin
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = abs_val(5);
            if (result == 5) begin
                $display("  [PASS] Abs positive");
                passed++;
            end else begin
                $display("  [FAIL] AbsP: %0d", result);
                failed++;
            end
        end

        // Test 3: Abs negative
        begin
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = abs_val(-5);
            if (result == 5) begin
                $display("  [PASS] Abs negative");
                passed++;
            end else begin
                $display("  [FAIL] AbsN: %0d", result);
                failed++;
            end
        end

        // Test 4: Max first
        begin
            static int result = max_val(10, 5);
            if (result == 10) begin
                $display("  [PASS] Max first");
                passed++;
            end else begin
                $display("  [FAIL] MaxF: %0d", result);
                failed++;
            end
        end

        // Test 5: Max second
        begin
            static int result = max_val(3, 8);
            if (result == 8) begin
                $display("  [PASS] Max second");
                passed++;
            end else begin
                $display("  [FAIL] MaxS: %0d", result);
                failed++;
            end
        end

        // Test 6: Double value
        begin
            static logic [7:0] result = double_val(8'h10);
            if (result == 8'h20) begin
                $display("  [PASS] Double value");
                passed++;
            end else begin
                $display("  [FAIL] Double: %h", result);
                failed++;
            end
        end

        // Test 7: Sign positive
        begin
            static int result = sign(100);
            if (result == 1) begin
                $display("  [PASS] Sign positive");
                passed++;
            end else begin
                $display("  [FAIL] SignP: %0d", result);
                failed++;
            end
        end

        // Test 8: Sign negative
        begin
            static int result = sign(-100);
            if (result == -1) begin
                $display("  [PASS] Sign negative");
                passed++;
            end else begin
                $display("  [FAIL] SignN: %0d", result);
                failed++;
            end
        end

        // Test 9: Sign zero
        begin
            static int result = sign(0);
            if (result == 0) begin
                $display("  [PASS] Sign zero");
                passed++;
            end else begin
                $display("  [FAIL] SignZ: %0d", result);
                failed++;
            end
        end

        // Test 10: Chained function
        begin
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = add(max_val(3, 5), abs_val(-2));
            if (result == 7) begin
                $display("  [PASS] Chained function");
                passed++;
            end else begin
                $display("  [FAIL] Chain: %0d", result);
                failed++;
            end
        end

        // Summary
        $display("");
        $display("Results: %0d passed, %0d failed", passed, failed);
        if (failed == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
    end
endmodule
