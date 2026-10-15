/*
:name: test_system_funcs_edge_cases
:description: Test: System functions edge cases
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.1 20.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_system_funcs_edge_cases.expected
*/
// Test: System functions edge cases
// IEEE 1800-2023 Section 20 System Functions
// Tests corner cases: $clog2, $countones, $onehot

`timescale 1ns/1ps

module test_system_funcs_edge_cases;
    int passed = 0;
    int failed = 0;

    logic [7:0] val;

    initial begin
        $display("TEST: System functions edge cases");

        // Test 1: $clog2 power of 2
        begin
            if ($clog2(16) == 4) begin
                $display("  [PASS] clog2(16)");
                passed++;
            end else begin
                $display("  [FAIL] Clog16: %0d", $clog2(16));
                failed++;
            end
        end

        // Test 2: $clog2 not power of 2
        begin
            if ($clog2(17) == 5) begin
                $display("  [PASS] clog2(17)");
                passed++;
            end else begin
                $display("  [FAIL] Clog17: %0d", $clog2(17));
                failed++;
            end
        end

        // Test 3: $clog2(1)
        begin
            if ($clog2(1) == 0) begin
                $display("  [PASS] clog2(1)");
                passed++;
            end else begin
                $display("  [FAIL] Clog1: %0d", $clog2(1));
                failed++;
            end
        end

        // Test 4: $countones all zeros
        begin
            val = 8'b00000000;
            if ($countones(val) == 0) begin
                $display("  [PASS] countones(0)");
                passed++;
            end else begin
                $display("  [FAIL] Cnt0: %0d", $countones(val));
                failed++;
            end
        end

        // Test 5: $countones all ones
        begin
            val = 8'b11111111;
            if ($countones(val) == 8) begin
                $display("  [PASS] countones(FF)");
                passed++;
            end else begin
                $display("  [FAIL] CntF: %0d", $countones(val));
                failed++;
            end
        end

        // Test 6: $countones alternating
        begin
            val = 8'b10101010;
            if ($countones(val) == 4) begin
                $display("  [PASS] countones(AA)");
                passed++;
            end else begin
                $display("  [FAIL] CntA: %0d", $countones(val));
                failed++;
            end
        end

        // Test 7: $onehot true
        begin
            val = 8'b00001000;
            if ($onehot(val) == 1) begin
                $display("  [PASS] onehot true");
                passed++;
            end else begin
                $display("  [FAIL] OH1: %0d", $onehot(val));
                failed++;
            end
        end

        // Test 8: $onehot false
        begin
            val = 8'b00001100;
            if ($onehot(val) == 0) begin
                $display("  [PASS] onehot false");
                passed++;
            end else begin
                $display("  [FAIL] OH0: %0d", $onehot(val));
                failed++;
            end
        end

        // Test 9: $onehot0 zero
        begin
            val = 8'b00000000;
            if ($onehot0(val) == 1) begin
                $display("  [PASS] onehot0 zero");
                passed++;
            end else begin
                $display("  [FAIL] OH0z: %0d", $onehot0(val));
                failed++;
            end
        end

        // Test 10: $isunknown no X
        begin
            val = 8'hAB;
            if ($isunknown(val) == 0) begin
                $display("  [PASS] isunknown no X");
                passed++;
            end else begin
                $display("  [FAIL] IsUnk: %0d", $isunknown(val));
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
