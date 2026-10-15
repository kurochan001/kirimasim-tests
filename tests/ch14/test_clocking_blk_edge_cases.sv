/*
:name: test_clocking_blk_edge_cases
:description: Test: Clocking block edge cases
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.3 14.13
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_blk_edge_cases.expected
*/
// Test: Clocking block edge cases
// IEEE 1800-2023 Section 14 Clocking blocks
// Tests corner cases: clocking block sampling

`timescale 1ns/1ps

module test_clocking_blk_edge_cases;
    int passed = 0;
    int failed = 0;

    logic clk = 0;
    logic [7:0] data = 0;
    logic [7:0] sampled_data;
    logic valid = 0;

    // Clock generator
    initial begin
        forever #5 clk = ~clk;
    end

    // Simple clocking block
    clocking cb @(posedge clk);
        input data;
        input valid;
    endclocking

    // Sample data
    always_ff @(posedge clk) begin
        sampled_data <= data;
    end

    initial begin
        $display("TEST: Clocking block edge cases");

        // Test 1: Initial data
        begin
            #1;
            if (data == 0) begin
                $display("  [PASS] Initial data");
                passed++;
            end else begin
                $display("  [FAIL] Initial: %0d", data);
                failed++;
            end
        end

        // Test 2: Data change before clock
        begin
            data = 8'hAA;
            #1;
            if (data == 8'hAA) begin
                $display("  [PASS] Data change before clock");
                passed++;
            end else begin
                $display("  [FAIL] BeforeClk: %0h", data);
                failed++;
            end
        end

        // Test 3: Sampled after clock
        begin
            @(posedge clk);
            #1;
            if (sampled_data == 8'hAA) begin
                $display("  [PASS] Sampled after clock");
                passed++;
            end else begin
                $display("  [FAIL] Sampled: %0h", sampled_data);
                failed++;
            end
        end

        // Test 4: Clocking block sample
        begin
            @(cb);
            #1;
            if (cb.data == 8'hAA) begin
                $display("  [PASS] Clocking block sample");
                passed++;
            end else begin
                $display("  [FAIL] CB: %0h", cb.data);
                failed++;
            end
        end

        // Test 5: Valid signal
        begin
            valid = 1;
            @(cb);
            #1;
            if (cb.valid == 1) begin
                $display("  [PASS] Valid signal");
                passed++;
            end else begin
                $display("  [FAIL] Valid: %0d", cb.valid);
                failed++;
            end
        end

        // Test 6: Data update
        begin
            data = 8'hBB;
            @(cb);
            #1;
            if (cb.data == 8'hBB) begin
                $display("  [PASS] Data update");
                passed++;
            end else begin
                $display("  [FAIL] Update: %0h", cb.data);
                failed++;
            end
        end

        // Test 7: Multiple samples
        begin
            data = 8'hCC;
            @(cb);
            data = 8'hDD;
            @(cb);
            #1;
            if (cb.data == 8'hDD) begin
                $display("  [PASS] Multiple samples");
                passed++;
            end else begin
                $display("  [FAIL] Multi: %0h", cb.data);
                failed++;
            end
        end

        // Test 8: Zero data
        begin
            data = 0;
            @(cb);
            #1;
            if (cb.data == 0) begin
                $display("  [PASS] Zero data");
                passed++;
            end else begin
                $display("  [FAIL] Zero: %0h", cb.data);
                failed++;
            end
        end

        // Test 9: Max data
        begin
            data = 8'hFF;
            @(cb);
            #1;
            if (cb.data == 8'hFF) begin
                $display("  [PASS] Max data");
                passed++;
            end else begin
                $display("  [FAIL] Max: %0h", cb.data);
                failed++;
            end
        end

        // Test 10: Valid toggle
        begin
            valid = 0;
            @(cb);
            #1;
            if (cb.valid == 0) begin
                $display("  [PASS] Valid toggle");
                passed++;
            end else begin
                $display("  [FAIL] Toggle: %0d", cb.valid);
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
