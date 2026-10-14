/*
:name: test_cast_ops_edge_cases
:description: Test: Cast operations edge cases
:tags: cast_ops
:type: simulation
:lrm: 1800-2023 6.24
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_ops_edge_cases.expected
*/
// Test: Cast operations edge cases
// IEEE 1800-2023 Section 6.24 Cast operator
// Tests corner cases: type casting operations

`timescale 1ns/1ps

module test_cast_ops_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        int i;
        real r;
        logic [31:0] lv;
        bit [15:0] bv;
        shortint si;
        longint li;
        byte b;

        $display("TEST: Cast operations edge cases");

        // Test 1: Int to real cast
        begin
            i = 42;
            r = real'(i);
            if (r > 41.9 && r < 42.1) begin
                $display("  [PASS] Int to real cast");
                passed++;
            end else begin
                $display("  [FAIL] IntToReal: %f", r);
                failed++;
            end
        end

        // Test 2: Real to int cast
        begin
            r = 3.7;
            i = int'(r);
            if (i == 3 || i == 4) begin  // Truncation or rounding
                $display("  [PASS] Real to int cast");
                passed++;
            end else begin
                $display("  [FAIL] RealToInt: %0d", i);
                failed++;
            end
        end

        // Test 3: Logic to int cast
        begin
            lv = 32'hABCD1234;
            i = int'(lv);
            // Signed interpretation
            if (i != 0) begin
                $display("  [PASS] Logic to int cast");
                passed++;
            end else begin
                $display("  [FAIL] LogicToInt");
                failed++;
            end
        end

        // Test 4: Int to logic cast
        begin
            i = -1;
            lv = logic'(i);
            // -1 as unsigned is all 1s
            if (lv != 0) begin
                $display("  [PASS] Int to logic cast");
                passed++;
            end else begin
                $display("  [FAIL] IntToLogic");
                failed++;
            end
        end

        // Test 5: Width reduction cast
        begin
            i = 256 + 5;  // 0x105
            b = byte'(i);
            if (b == 5) begin
                $display("  [PASS] Width reduction cast");
                passed++;
            end else begin
                $display("  [FAIL] WidthRed: %0d", b);
                failed++;
            end
        end

        // Test 6: Width extension cast
        begin
            b = 100;
            li = longint'(b);
            if (li == 100) begin
                $display("  [PASS] Width extension cast");
                passed++;
            end else begin
                $display("  [FAIL] WidthExt");
                failed++;
            end
        end

        // Test 7: Signed cast
        begin
            lv = 32'hFFFFFFFF;
            i = signed'(lv);
            if (i == -1) begin
                $display("  [PASS] Signed cast");
                passed++;
            end else begin
                $display("  [FAIL] Signed: %0d", i);
                failed++;
            end
        end

        // Test 8: Unsigned cast
        begin
            i = -1;
            lv = unsigned'(i);
            if (lv == 32'hFFFFFFFF) begin
                $display("  [PASS] Unsigned cast");
                passed++;
            end else begin
                $display("  [FAIL] Unsigned: %0h", lv);
                failed++;
            end
        end

        // Test 9: Shortint cast
        begin
            i = 1000;
            si = shortint'(i);
            if (si == 1000) begin
                $display("  [PASS] Shortint cast");
                passed++;
            end else begin
                $display("  [FAIL] Short: %0d", si);
                failed++;
            end
        end

        // Test 10: Bit vector cast
        begin
            i = 16'hABCD;
            bv = bit'(i);
            // Just check it's non-zero
            if (bv != 0) begin
                $display("  [PASS] Bit vector cast");
                passed++;
            end else begin
                $display("  [FAIL] BitVec");
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
