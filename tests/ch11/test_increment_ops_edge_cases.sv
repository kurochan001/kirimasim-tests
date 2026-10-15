/*
:name: test_increment_ops_edge_cases
:description: Pre- and post-increment and decrement used as expressions and statements
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_increment_ops_edge_cases.expected
*/
// Pre- and post-increment and decrement used as expressions and statements
// IEEE 1800-2023 Section 11.4.2 Increment and decrement operators
// Tests corner cases: increment/decrement operations

`timescale 1ns/1ps

module test_increment_ops_edge_cases;
    int passed = 0;
    int failed = 0;

    int a;
    int r;  // value of the increment or decrement expression

    initial begin
        $display("TEST: Increment/Decrement operations edge cases");

        // Test 1: Pre-increment
        begin
            a = 5;
            // Separate statements: the order of the write and a read of a in one
            // expression is undefined (11.4.2).
            r = ++a;
            if (r == 6 && a == 6) begin
                $display("  [PASS] Pre-increment");
                passed++;
            end else begin
                $display("  [FAIL] Pre++: %0d", a);
                failed++;
            end
        end

        // Test 2: Post-increment
        begin
            a = 5;
            // Separate statements: the order of the write and a read of a in one
            // expression is undefined (11.4.2).
            r = a++;
            if (r == 5 && a == 6) begin
                $display("  [PASS] Post-increment");
                passed++;
            end else begin
                $display("  [FAIL] Post++: %0d", a);
                failed++;
            end
        end

        // Test 3: Pre-decrement
        begin
            a = 10;
            // Separate statements: the order of the write and a read of a in one
            // expression is undefined (11.4.2).
            r = --a;
            if (r == 9 && a == 9) begin
                $display("  [PASS] Pre-decrement");
                passed++;
            end else begin
                $display("  [FAIL] Pre--: %0d", a);
                failed++;
            end
        end

        // Test 4: Post-decrement
        begin
            a = 10;
            // Separate statements: the order of the write and a read of a in one
            // expression is undefined (11.4.2).
            r = a--;
            if (r == 10 && a == 9) begin
                $display("  [PASS] Post-decrement");
                passed++;
            end else begin
                $display("  [FAIL] Post--: %0d", a);
                failed++;
            end
        end

        // Test 5: Increment from zero
        begin
            a = 0;
            a++;
            if (a == 1) begin
                $display("  [PASS] Increment from zero");
                passed++;
            end else begin
                $display("  [FAIL] Inc0: %0d", a);
                failed++;
            end
        end

        // Test 6: Decrement to zero
        begin
            a = 1;
            a--;
            if (a == 0) begin
                $display("  [PASS] Decrement to zero");
                passed++;
            end else begin
                $display("  [FAIL] Dec0: %0d", a);
                failed++;
            end
        end

        // Test 7: Increment negative
        begin
            a = -5;
            a++;
            if (a == -4) begin
                $display("  [PASS] Increment negative");
                passed++;
            end else begin
                $display("  [FAIL] IncNeg: %0d", a);
                failed++;
            end
        end

        // Test 8: Decrement to negative
        begin
            a = 0;
            a--;
            if (a == -1) begin
                $display("  [PASS] Decrement to negative");
                passed++;
            end else begin
                $display("  [FAIL] DecNeg: %0d", a);
                failed++;
            end
        end

        // Test 9: Multiple increments
        begin
            a = 0;
            a++;
            a++;
            a++;
            if (a == 3) begin
                $display("  [PASS] Multiple increments");
                passed++;
            end else begin
                $display("  [FAIL] Multi++: %0d", a);
                failed++;
            end
        end

        // Test 10: Increment in loop
        begin
            static int count = 0;
            for (int i = 0; i < 5; i++) begin
                count++;
            end
            if (count == 5) begin
                $display("  [PASS] Increment in loop");
                passed++;
            end else begin
                $display("  [FAIL] Loop++: %0d", count);
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
