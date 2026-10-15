/*
:name: test_system_tasks_edge_cases
:description: Test: System tasks edge cases
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.3 20.6.2 20.7 20.8.1 20.9 21.2.1.1 21.3.3 21.3.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_tasks_edge_cases.expected
*/
// Test: System tasks edge cases
// IEEE 1800-2023 Section 20-21 System Tasks
// Tests corner cases: $display, $write, $sformat, $sscanf

`timescale 1ns/1ps

module test_system_tasks_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        $display("TEST: System tasks edge cases");

        // Test 1: $display with integer
        begin
            static int val = 42;
            $display("  [PASS] $display with integer: %0d", val);
            passed++;
        end

        // Test 2: $display with hex
        begin
            static logic [7:0] val = 8'hAB;
            $display("  [PASS] $display with hex: %h", val);
            passed++;
        end

        // Test 3: $display with binary
        begin
            static logic [3:0] val = 4'b1010;
            $display("  [PASS] $display with binary: %b", val);
            passed++;
        end

        // Test 4: $sformat string construction
        begin
            string s;
            $sformat(s, "Value: %0d", 123);
            if (s == "Value: 123") begin
                $display("  [PASS] $sformat");
                passed++;
            end else begin
                $display("  [FAIL] $sformat: %s", s);
                failed++;
            end
        end

        // Test 5: $sscanf parsing
        begin
            static string input_str = "100";
            int parsed;
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = $sscanf(input_str, "%d", parsed);
            if (result == 1 && parsed == 100) begin
                $display("  [PASS] $sscanf");
                passed++;
            end else begin
                $display("  [FAIL] $sscanf: result=%0d, parsed=%0d", result, parsed);
                failed++;
            end
        end

        // Test 6: $time returns current time
        begin
            time t;
            t = $time;
            if (t == 0) begin
                $display("  [PASS] $time returns: %0t", t);
                passed++;
            end else begin
                $display("  [FAIL] $time");
                failed++;
            end
        end

        // Test 7: $bits on type
        begin
            logic [31:0] val;
            if ($bits(val) == 32) begin
                $display("  [PASS] $bits returns 32");
                passed++;
            end else begin
                $display("  [FAIL] $bits");
                failed++;
            end
        end

        // Test 8: $size on array
        begin
            int arr[10];
            if ($size(arr) == 10) begin
                $display("  [PASS] $size returns 10");
                passed++;
            end else begin
                $display("  [FAIL] $size");
                failed++;
            end
        end

        // Test 9: $clog2
        begin
            if ($clog2(16) == 4) begin
                $display("  [PASS] $clog2(16) = 4");
                passed++;
            end else begin
                $display("  [FAIL] $clog2: %0d", $clog2(16));
                failed++;
            end
        end

        // Test 10: $countones
        begin
            static logic [7:0] val = 8'b10101010;
            if ($countones(val) == 4) begin
                $display("  [PASS] $countones = 4");
                passed++;
            end else begin
                $display("  [FAIL] $countones: %0d", $countones(val));
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
