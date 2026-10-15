/*
:name: test_sensitivity_edge_cases
:description: Test: Sensitivity list edge cases
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2 9.2.2.4 9.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sensitivity_edge_cases.expected
*/
// Test: Sensitivity list edge cases
// IEEE 1800-2023 Section 9.4.2 Sensitivity List
// Tests corner cases: single/multi signal sensitivity

`timescale 1ns/1ps

module test_sensitivity_edge_cases;
    int passed = 0;
    int failed = 0;

    logic clk = 0;
    logic rst = 0;
    logic [7:0] a, b, c;
    logic [7:0] result_comb;
    logic [7:0] result_seq;
    int trigger_count;

    // Clock generator
    initial begin
        repeat (20) #5 clk = ~clk;
    end

    // Combinational block with sensitivity
    always_comb begin
        result_comb = a + b;
    end

    // Sequential block
    always_ff @(posedge clk) begin
        result_seq <= a;
    end

    initial begin
        $display("TEST: Sensitivity edge cases");

        // Initialize
        a = 0;
        b = 0;
        c = 0;
        trigger_count = 0;

        // Test 1: Combinational sensitivity
        begin
            a = 10;
            b = 20;
            #1;
            if (result_comb == 30) begin
                $display("  [PASS] Combinational sensitivity");
                passed++;
            end else begin
                $display("  [FAIL] Comb: %0d", result_comb);
                failed++;
            end
        end

        // Test 2: Update triggers recalculation
        begin
            a = 50;
            #1;
            if (result_comb == 70) begin
                $display("  [PASS] Update triggers");
                passed++;
            end else begin
                $display("  [FAIL] Trigger: %0d", result_comb);
                failed++;
            end
        end

        // Test 3: Sequential sensitivity
        begin
            a = 8'hAA;
            @(posedge clk);
            #1;
            if (result_seq == 8'hAA) begin
                $display("  [PASS] Sequential sensitivity");
                passed++;
            end else begin
                $display("  [FAIL] Seq: %h", result_seq);
                failed++;
            end
        end

        // Test 4: Posedge triggers
        begin
            a = 8'hBB;
            @(posedge clk);
            #1;
            if (result_seq == 8'hBB) begin
                $display("  [PASS] Posedge triggers");
                passed++;
            end else begin
                $display("  [FAIL] Pos: %h", result_seq);
                failed++;
            end
        end

        // Test 5: Multiple updates same cycle
        begin
            a = 1;
            b = 2;
            #0;
            a = 3;
            b = 4;
            #1;
            if (result_comb == 7) begin
                $display("  [PASS] Multiple updates");
                passed++;
            end else begin
                $display("  [FAIL] Multi: %0d", result_comb);
                failed++;
            end
        end

        // Test 6: Zero value sensitivity
        begin
            a = 0;
            b = 0;
            #1;
            if (result_comb == 0) begin
                $display("  [PASS] Zero value");
                passed++;
            end else begin
                $display("  [FAIL] Zero: %0d", result_comb);
                failed++;
            end
        end

        // Test 7: Sequential pipeline
        begin
            a = 8'h11;
            @(posedge clk);
            a = 8'h22;
            @(posedge clk);
            #1;
            if (result_seq == 8'h22) begin
                $display("  [PASS] Sequential pipeline");
                passed++;
            end else begin
                $display("  [FAIL] Pipe: %h", result_seq);
                failed++;
            end
        end

        // Test 8: Combinational max value
        begin
            a = 8'hFF;
            b = 8'h01;
            #1;
            if (result_comb == 8'h00) begin
                $display("  [PASS] Combinational overflow");
                passed++;
            end else begin
                $display("  [FAIL] Overflow: %h", result_comb);
                failed++;
            end
        end

        // Test 9: Value consistency
        begin
            a = 8'h77;
            @(posedge clk);
            #1;
            if (result_seq == 8'h77) begin
                $display("  [PASS] Value consistency");
                passed++;
            end else begin
                $display("  [FAIL] Consistency: %h", result_seq);
                failed++;
            end
        end

        // Test 10: Rapid updates
        begin
            a = 8'h00;
            b = 8'h00;
            #1;
            a = 8'h10;
            #1;
            b = 8'h10;
            #1;
            if (result_comb == 8'h20) begin
                $display("  [PASS] Rapid updates");
                passed++;
            end else begin
                $display("  [FAIL] Rapid: %h", result_comb);
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
        $finish;
    end
endmodule
