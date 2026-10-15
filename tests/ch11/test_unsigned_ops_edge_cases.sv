/*
:name: test_unsigned_ops_edge_cases
:description: Arithmetic and comparison of unsigned 8-bit values, with wrap-around
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.4.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unsigned_ops_edge_cases.expected
*/
// Arithmetic and comparison of unsigned 8-bit values, with wrap-around
// IEEE 1800-2023 Section 11.4 Signed and Unsigned
// Tests corner cases: unsigned operations

`timescale 1ns/1ps

module test_unsigned_ops_edge_cases;
    int passed = 0;
    int failed = 0;

    logic [7:0] ua, ub, uc;
    int unsigned ui;

    initial begin
        $display("TEST: Unsigned operations edge cases");

        // Test 1: Basic unsigned
        begin
            ua = 8'd100;
            if (ua == 100) begin
                $display("  [PASS] Basic unsigned");
                passed++;
            end else begin
                $display("  [FAIL] Basic: %0d", ua);
                failed++;
            end
        end

        // Test 2: Max unsigned
        begin
            ua = 8'd255;
            if (ua == 255) begin
                $display("  [PASS] Max unsigned");
                passed++;
            end else begin
                $display("  [FAIL] Max: %0d", ua);
                failed++;
            end
        end

        // Test 3: Unsigned addition
        begin
            ua = 8'd100;
            ub = 8'd50;
            uc = ua + ub;
            if (uc == 150) begin
                $display("  [PASS] Unsigned addition");
                passed++;
            end else begin
                $display("  [FAIL] Add: %0d", uc);
                failed++;
            end
        end

        // Test 4: Unsigned subtraction
        begin
            ua = 8'd100;
            ub = 8'd30;
            uc = ua - ub;
            if (uc == 70) begin
                $display("  [PASS] Unsigned subtraction");
                passed++;
            end else begin
                $display("  [FAIL] Sub: %0d", uc);
                failed++;
            end
        end

        // Test 5: Unsigned overflow
        begin
            ua = 8'd200;
            ub = 8'd100;
            uc = ua + ub;  // Wraps to 44
            if (uc == 44) begin
                $display("  [PASS] Unsigned overflow");
                passed++;
            end else begin
                $display("  [FAIL] Overflow: %0d", uc);
                failed++;
            end
        end

        // Test 6: Unsigned comparison
        begin
            ua = 8'd200;
            ub = 8'd100;
            if (ua > ub) begin
                $display("  [PASS] Unsigned comparison");
                passed++;
            end else begin
                $display("  [FAIL] Compare");
                failed++;
            end
        end

        // Test 7: Unsigned zero
        begin
            ua = 0;
            if (ua == 0) begin
                $display("  [PASS] Unsigned zero");
                passed++;
            end else begin
                $display("  [FAIL] Zero: %0d", ua);
                failed++;
            end
        end

        // Test 8: Unsigned multiply
        begin
            ua = 8'd10;
            ub = 8'd20;
            uc = ua * ub;
            if (uc == 200) begin
                $display("  [PASS] Unsigned multiply");
                passed++;
            end else begin
                $display("  [FAIL] Mult: %0d", uc);
                failed++;
            end
        end

        // Test 9: Unsigned divide
        begin
            ua = 8'd100;
            ub = 8'd10;
            uc = ua / ub;
            if (uc == 10) begin
                $display("  [PASS] Unsigned divide");
                passed++;
            end else begin
                $display("  [FAIL] Div: %0d", uc);
                failed++;
            end
        end

        // Test 10: Unsigned modulo
        begin
            ua = 8'd100;
            ub = 8'd30;
            uc = ua % ub;
            if (uc == 10) begin
                $display("  [PASS] Unsigned modulo");
                passed++;
            end else begin
                $display("  [FAIL] Mod: %0d", uc);
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
