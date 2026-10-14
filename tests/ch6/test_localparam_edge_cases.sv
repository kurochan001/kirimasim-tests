/*
:name: test_localparam_edge_cases
:description: Test: Localparam edge cases
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_localparam_edge_cases.expected
*/
// Test: Localparam edge cases
// IEEE 1800-2023 Section 6.20.4 Local parameters
// Tests corner cases: localparam declarations

`timescale 1ns/1ps

module test_localparam_edge_cases;
    int passed = 0;
    int failed = 0;

    localparam WIDTH = 8;
    localparam DEPTH = 16;
    localparam SIZE = WIDTH * DEPTH;
    localparam HALF_SIZE = SIZE / 2;
    localparam string MSG = "hello";
    localparam logic [3:0] NIBBLE = 4'hA;

    initial begin
        $display("TEST: Localparam edge cases");

        // Test 1: Basic localparam
        begin
            if (WIDTH == 8) begin
                $display("  [PASS] Basic localparam");
                passed++;
            end else begin
                $display("  [FAIL] Width: %0d", WIDTH);
                failed++;
            end
        end

        // Test 2: Second localparam
        begin
            if (DEPTH == 16) begin
                $display("  [PASS] Second localparam");
                passed++;
            end else begin
                $display("  [FAIL] Depth: %0d", DEPTH);
                failed++;
            end
        end

        // Test 3: Computed localparam
        begin
            if (SIZE == 128) begin
                $display("  [PASS] Computed localparam");
                passed++;
            end else begin
                $display("  [FAIL] Size: %0d", SIZE);
                failed++;
            end
        end

        // Test 4: Division localparam
        begin
            if (HALF_SIZE == 64) begin
                $display("  [PASS] Division localparam");
                passed++;
            end else begin
                $display("  [FAIL] Half: %0d", HALF_SIZE);
                failed++;
            end
        end

        // Test 5: String localparam
        begin
            if (MSG == "hello") begin
                $display("  [PASS] String localparam");
                passed++;
            end else begin
                $display("  [FAIL] Msg: %s", MSG);
                failed++;
            end
        end

        // Test 6: Logic localparam
        begin
            if (NIBBLE == 4'hA) begin
                $display("  [PASS] Logic localparam");
                passed++;
            end else begin
                $display("  [FAIL] Nibble: %0h", NIBBLE);
                failed++;
            end
        end

        // Test 7: Localparam in expression
        begin
            static int val = WIDTH + 10;
            if (val == 18) begin
                $display("  [PASS] Localparam in expression");
                passed++;
            end else begin
                $display("  [FAIL] Expr: %0d", val);
                failed++;
            end
        end

        // Test 8: Comparison with localparam
        begin
            static int x = 128;
            if (x == SIZE) begin
                $display("  [PASS] Comparison with localparam");
                passed++;
            end else begin
                $display("  [FAIL] Compare");
                failed++;
            end
        end

        // Test 9: Localparam chain
        begin
            if (HALF_SIZE == SIZE / 2) begin
                $display("  [PASS] Localparam chain");
                passed++;
            end else begin
                $display("  [FAIL] Chain");
                failed++;
            end
        end

        // Test 10: Multiple in condition
        begin
            if (WIDTH < DEPTH && SIZE > HALF_SIZE) begin
                $display("  [PASS] Multiple in condition");
                passed++;
            end else begin
                $display("  [FAIL] MultiCond");
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
