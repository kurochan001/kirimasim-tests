/*
:name: test_clog2_2
:description: $clog2 Test
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clog2_2.expected
*/
// IEEE 1800-2023 $clog2 Test
// Target: $clog2 - Ceiling of log base 2
// IEEE 1800-2023 Section 20.3

`timescale 1ns/1ps

module test_clog2;
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

        $display("=== $clog2 Test ===");
        $display("");

        // ===== Test 1: Powers of 2 =====
        $display("Test 1: Powers of 2");
        result = $clog2(1);
        $display("  $clog2(1) = %0d (expected 0)", result);
        check("$clog2(1) = 0", result == 0);

        result = $clog2(2);
        $display("  $clog2(2) = %0d (expected 1)", result);
        check("$clog2(2) = 1", result == 1);

        result = $clog2(4);
        $display("  $clog2(4) = %0d (expected 2)", result);
        check("$clog2(4) = 2", result == 2);

        result = $clog2(8);
        $display("  $clog2(8) = %0d (expected 3)", result);
        check("$clog2(8) = 3", result == 3);

        result = $clog2(16);
        $display("  $clog2(16) = %0d (expected 4)", result);
        check("$clog2(16) = 4", result == 4);

        // ===== Test 2: Non-powers of 2 (ceiling) =====
        $display("");
        $display("Test 2: Non-powers of 2 (ceiling behavior)");
        result = $clog2(3);
        $display("  $clog2(3) = %0d (expected 2)", result);
        check("$clog2(3) = 2", result == 2);

        result = $clog2(5);
        $display("  $clog2(5) = %0d (expected 3)", result);
        check("$clog2(5) = 3", result == 3);

        result = $clog2(7);
        $display("  $clog2(7) = %0d (expected 3)", result);
        check("$clog2(7) = 3", result == 3);

        result = $clog2(9);
        $display("  $clog2(9) = %0d (expected 4)", result);
        check("$clog2(9) = 4", result == 4);

        // ===== Test 3: Edge cases =====
        $display("");
        $display("Test 3: Edge cases");
        result = $clog2(0);
        $display("  $clog2(0) = %0d (expected 0)", result);
        check("$clog2(0) = 0", result == 0);

        // ===== Test 4: Larger values =====
        $display("");
        $display("Test 4: Larger values");
        result = $clog2(256);
        $display("  $clog2(256) = %0d (expected 8)", result);
        check("$clog2(256) = 8", result == 8);

        result = $clog2(1024);
        $display("  $clog2(1024) = %0d (expected 10)", result);
        check("$clog2(1024) = 10", result == 10);

        result = $clog2(1000);
        $display("  $clog2(1000) = %0d (expected 10)", result);
        check("$clog2(1000) = 10", result == 10);

        // ===== Test 5: Typical usage - address width calculation =====
        $display("");
        $display("Test 5: Typical usage - address width calculation");
        result = $clog2(256);
        $display("  For memory depth 256, $clog2 = %0d", result);
        check("Address width for 256 depth = 8", result == 8);

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
