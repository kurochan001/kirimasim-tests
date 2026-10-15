/*
:name: test_clocking_blocks_edge_cases
:description: Test: Clocking blocks edge cases
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.3 14.13 14.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_blocks_edge_cases.expected
*/
// Test: Clocking blocks edge cases
// IEEE 1800-2023 Section 14 Clocking Blocks
// Tests corner cases: clocking block basics

`timescale 1ns/1ps

module test_clocking_blocks_edge_cases;
    int passed = 0;
    int failed = 0;

    logic clk = 0;
    logic [7:0] data_in;
    logic [7:0] data_out;
    logic valid;

    // Clock generation
    initial begin
        // The checks need 18 rising edges; the test ends with $finish.
        forever #5 clk = ~clk;
    end

    // Simple clocking block
    clocking cb @(posedge clk);
        input data_in;
        output data_out;
        input valid;
    endclocking

    initial begin
        $display("TEST: Clocking blocks edge cases");

        // Initialize
        data_in = 0;
        data_out = 0;
        valid = 0;

        // Test 1: Clocking block exists
        begin
            $display("  [PASS] Clocking block defined");
            passed++;
        end

        // Test 2: Signal via clocking
        begin
            data_in = 8'hAB;
            @(posedge clk);
            @(posedge clk);
            if (cb.data_in == 8'hAB) begin
                $display("  [PASS] Clocking input");
                passed++;
            end else begin
                $display("  [FAIL] CbIn: %h", cb.data_in);
                failed++;
            end
        end

        // Test 3: Output via clocking
        begin
            cb.data_out <= 8'h55;
            @(posedge clk);
            if (data_out == 8'h55) begin
                $display("  [PASS] Clocking output");
                passed++;
            end else begin
                $display("  [FAIL] CbOut: %h", data_out);
                failed++;
            end
        end

        // Test 4: Valid signal
        begin
            valid = 1;
            @(posedge clk);
            @(posedge clk);
            if (cb.valid == 1) begin
                $display("  [PASS] Clocking valid");
                passed++;
            end else begin
                $display("  [FAIL] Valid: %b", cb.valid);
                failed++;
            end
        end

        // Test 5: Data change
        begin
            data_in = 8'h11;
            @(posedge clk);
            data_in = 8'h22;
            @(posedge clk);
            @(posedge clk);
            if (cb.data_in == 8'h22) begin
                $display("  [PASS] Data change");
                passed++;
            end else begin
                $display("  [FAIL] Change: %h", cb.data_in);
                failed++;
            end
        end

        // Test 6: Multiple outputs
        begin
            cb.data_out <= 8'hAA;
            @(posedge clk);
            cb.data_out <= 8'hBB;
            @(posedge clk);
            if (data_out == 8'hBB) begin
                $display("  [PASS] Multiple outputs");
                passed++;
            end else begin
                $display("  [FAIL] MultOut: %h", data_out);
                failed++;
            end
        end

        // Test 7: Zero data
        begin
            data_in = 8'h00;
            @(posedge clk);
            @(posedge clk);
            if (cb.data_in == 8'h00) begin
                $display("  [PASS] Zero data");
                passed++;
            end else begin
                $display("  [FAIL] Zero: %h", cb.data_in);
                failed++;
            end
        end

        // Test 8: Max data
        begin
            data_in = 8'hFF;
            @(posedge clk);
            @(posedge clk);
            if (cb.data_in == 8'hFF) begin
                $display("  [PASS] Max data");
                passed++;
            end else begin
                $display("  [FAIL] Max: %h", cb.data_in);
                failed++;
            end
        end

        // Test 9: Valid toggle
        begin
            valid = 0;
            @(posedge clk);
            @(posedge clk);
            if (cb.valid == 0) begin
                $display("  [PASS] Valid toggle");
                passed++;
            end else begin
                $display("  [FAIL] Toggle: %b", cb.valid);
                failed++;
            end
        end

        // Test 10: Combined signals
        begin
            data_in = 8'hCC;
            valid = 1;
            @(posedge clk);
            @(posedge clk);
            if (cb.data_in == 8'hCC && cb.valid == 1) begin
                $display("  [PASS] Combined signals");
                passed++;
            end else begin
                $display("  [FAIL] Combined: %h %b", cb.data_in, cb.valid);
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
