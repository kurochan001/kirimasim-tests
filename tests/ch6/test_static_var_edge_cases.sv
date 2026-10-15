/*
:name: test_static_var_edge_cases
:description: Module variables keep their values across statements
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.21
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_static_var_edge_cases.expected
*/
// Module variables keep their values across statements
// IEEE 1800-2023 Section 6.21 Scope and lifetime
// Tests corner cases: module-level persistent variables

`timescale 1ns/1ps

module test_static_var_edge_cases;
    int passed = 0;
    int failed = 0;

    // Module level variables (static by default)
    int counter = 0;
    int accumulator = 0;
    int flag = 0;

    initial begin
        $display("TEST: Static/Module variable edge cases");

        // Test 1: Initial counter value
        begin
            if (counter == 0) begin
                $display("  [PASS] Initial counter value");
                passed++;
            end else begin
                $display("  [FAIL] Initial: %0d", counter);
                failed++;
            end
        end

        // Test 2: First counter increment
        begin
            counter = counter + 1;
            if (counter == 1) begin
                $display("  [PASS] First counter increment");
                passed++;
            end else begin
                $display("  [FAIL] Inc1: %0d", counter);
                failed++;
            end
        end

        // Test 3: Second counter increment
        begin
            counter = counter + 1;
            if (counter == 2) begin
                $display("  [PASS] Second counter increment");
                passed++;
            end else begin
                $display("  [FAIL] Inc2: %0d", counter);
                failed++;
            end
        end

        // Test 4: Accumulator first add
        begin
            accumulator = accumulator + 5;
            if (accumulator == 5) begin
                $display("  [PASS] Accumulator first add");
                passed++;
            end else begin
                $display("  [FAIL] Add1: %0d", accumulator);
                failed++;
            end
        end

        // Test 5: Accumulator second add
        begin
            accumulator = accumulator + 10;
            if (accumulator == 15) begin
                $display("  [PASS] Accumulator second add");
                passed++;
            end else begin
                $display("  [FAIL] Add2: %0d", accumulator);
                failed++;
            end
        end

        // Test 6: Flag set
        begin
            flag = 1;
            if (flag == 1) begin
                $display("  [PASS] Flag set");
                passed++;
            end else begin
                $display("  [FAIL] Flag: %0d", flag);
                failed++;
            end
        end

        // Test 7: Flag persists
        begin
            if (flag == 1) begin
                $display("  [PASS] Flag persists");
                passed++;
            end else begin
                $display("  [FAIL] Persist: %0d", flag);
                failed++;
            end
        end

        // Test 8: Counter continues
        begin
            counter = counter + 1;
            counter = counter + 1;
            if (counter == 4) begin
                $display("  [PASS] Counter continues");
                passed++;
            end else begin
                $display("  [FAIL] Cont: %0d", counter);
                failed++;
            end
        end

        // Test 9: Multiple accumulator adds
        begin
            accumulator = accumulator + 5;
            accumulator = accumulator + 5;
            if (accumulator == 25) begin
                $display("  [PASS] Multiple accumulator adds");
                passed++;
            end else begin
                $display("  [FAIL] Multi: %0d", accumulator);
                failed++;
            end
        end

        // Test 10: All values persist
        begin
            if (counter == 4 && accumulator == 25 && flag == 1) begin
                $display("  [PASS] All values persist");
                passed++;
            end else begin
                $display("  [FAIL] All: c=%0d a=%0d f=%0d", counter, accumulator, flag);
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
